## 🎯 How to Use This Lab

1. Start Jenkins: `./deploy.sh` (or use an already-running Jenkins instance)
2. Open **http://localhost:8080** → **New Item** → **Pipeline**
3. Paste the `Jenkinsfile` contents into "Pipeline script"
4. Click **Save** → **Build Now**
5. Click **Console Output** on the failed build to see the error
6. Diagnose and fix! Check `solution.md` if stuck.

---

# Lab 15: Pipeline Memory Leak — CPS Serialization & Groovy Anti-Patterns

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

A long-running data processing pipeline has been crashing the Jenkins master every few days. The operations team noticed that memory usage steadily climbs during certain pipeline executions until the JVM runs out of heap space, triggering an OOM kill. The pipeline processes files, generates reports, and aggregates results — all common operations that shouldn't cause memory issues.

The root cause is a combination of CPS (Continuation Passing Style) serialization behavior unique to Jenkins Pipeline and Groovy memory management anti-patterns. Each stage introduces a different leak pattern that compounds until OOM.

## What You'll Observe

Initial memory state:
```
$ docker stats jenkins-memory-lab --no-stream
CONTAINER ID   NAME                  CPU %   MEM USAGE / LIMIT    MEM %
abc123def456   jenkins-memory-lab    2.5%    180MiB / 384MiB      46.88%
```

After pipeline starts Stage 2:
```
$ docker stats jenkins-memory-lab --no-stream
CONTAINER ID   NAME                  CPU %   MEM USAGE / LIMIT    MEM %
abc123def456   jenkins-memory-lab    45.2%   310MiB / 384MiB      80.73%
```

GC log showing pressure:
```
[2026-07-01T14:35:22.100+0000] GC(142) Pause Full (G1 Humongous Allocation)
[2026-07-01T14:35:22.500+0000] GC(142) 245M->240M(256M) 400.123ms
[2026-07-01T14:35:23.100+0000] GC(143) Pause Full (G1 Humongous Allocation)
[2026-07-01T14:35:23.600+0000] GC(143) 250M->248M(256M) 500.456ms
```

Jenkins crash:
```
java.lang.OutOfMemoryError: Java heap space
    at java.lang.AbstractStringBuilder.ensureCapacityInternal(AbstractStringBuilder.java:172)
    at java.lang.StringBuilder.append(StringBuilder.java:136)
    at org.codehaus.groovy.runtime.InvokerHelper.formatMap(InvokerHelper.java:649)
    at org.jenkinsci.plugins.workflow.cps.CpsFlowExecution.crankOrAbort(CpsFlowExecution.java:603)
    at org.jenkinsci.plugins.workflow.cps.CpsFlowExecution$2.run(CpsFlowExecution.java:265)
    
Dumping heap to /var/jenkins_home/heapdumps/java_pid1.hprof ...
Heap dump file created [268435456 bytes in 12.345 secs]
```

Build log before crash:
```
[Pipeline] // script
[Pipeline] script
[Pipeline] {
Processed chunk of 10 files. Total report size: 1523456
Processed chunk of 10 files. Total report size: 3045789
Processed chunk of 10 files. Total report size: 4567123
Processed chunk of 10 files. Total report size: 6089456
...
ERROR: script returned exit code 137 (OOM killed)
Finished: ABORTED
```

## Your Task

Identify and fix all 5 memory leak patterns in the Jenkinsfile:
1. **CPS closure capturing large List** — `fileList` captured in CPS-serialized scope
2. **Missing @NonCPS** — Large data processing (split, collect, join) in CPS context
3. **readFile() in loop** — Accumulating String references that survive GC due to CPS
4. **GString interpolation** — Creating massive String copies via `"${content}"` in CPS
5. **StringBuilder growth** — Unbounded growth of serialized state across CPS checkpoints

## Hints

<details>
<summary>Hint 1</summary>
The CPS (Continuation Passing Style) transform used by Jenkins Pipeline serializes the ENTIRE local variable state at every suspension point (every step call like `sh`, `sleep`, `echo`, `readFile`). If you have a 5MB String in a local variable and call `echo "done"`, the 5MB string is serialized to disk. Then when you modify it, both old and new versions may be in memory. Use `@NonCPS` for data processing methods or break large operations into separate methods that don't hold references.
</details>

<details>
<summary>Hint 2</summary>
Mark data-processing functions with `@NonCPS` annotation. This tells Jenkins NOT to CPS-transform the method — it runs as normal Groovy without serialization checkpoints. But `@NonCPS` methods CANNOT call CPS-transformed steps (like `sh`, `readFile`, `echo`). Split your pipeline into: (1) CPS steps that READ data into variables, then (2) `@NonCPS` helper methods that PROCESS the data, then (3) CPS steps that WRITE results. Never mix them.
</details>

<details>
<summary>Hint 3</summary>
Avoid holding large data in pipeline variables. Instead: (1) Use `sh` to process files (awk, sed, jq) and only capture small results, (2) Write intermediate results to files and read only summaries, (3) If you must process in Groovy, use `@NonCPS` methods and null-out references explicitly (`content = null`), (4) Process files one at a time instead of loading all into memory, (5) Use `writeFile`/`readFile` as a swap mechanism instead of in-memory accumulation.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Monitor memory in real-time
docker stats jenkins-memory-lab

# Check JVM heap info
docker exec jenkins-memory-lab jcmd 1 GC.heap_info
docker exec jenkins-memory-lab jcmd 1 GC.run

# View GC log
docker exec jenkins-memory-lab cat /var/jenkins_home/gc.log | tail -50

# Check for heap dumps (created on OOM)
docker exec jenkins-memory-lab ls -la /var/jenkins_home/heapdumps/

# Analyze heap dump (if you have jhat/MAT locally)
docker cp jenkins-memory-lab:/var/jenkins_home/heapdumps/ ./heapdumps/
# jhat heapdumps/java_pid1.hprof

# View JVM memory pools
docker exec jenkins-memory-lab jcmd 1 VM.native_memory summary 2>/dev/null || echo "NMT not enabled"

# Check if container was OOM-killed
docker inspect jenkins-memory-lab --format='{{.State.OOMKilled}}'
docker inspect jenkins-memory-lab --format='{{.State.ExitCode}}'

# View thread dump to see CPS serialization
docker exec jenkins-memory-lab jcmd 1 Thread.print | grep -A 5 "CpsVmExecutorService"

# Check pipeline flownode storage (CPS serialization files)
docker exec jenkins-memory-lab find /var/jenkins_home/jobs -name "*.xml" -path "*/builds/*/workflow/*" | head -10
docker exec jenkins-memory-lab du -sh /var/jenkins_home/jobs/*/builds/*/workflow/ 2>/dev/null

# View program.dat (serialized pipeline state) size
docker exec jenkins-memory-lab find /var/jenkins_home/jobs -name "program.dat" -exec ls -la {} \;

# Force GC and check memory
docker exec jenkins-memory-lab curl -s -X POST http://localhost:8080/gc/
docker exec jenkins-memory-lab jcmd 1 GC.heap_info
```

## Key Concepts

### CPS (Continuation Passing Style) in Jenkins Pipeline

Jenkins Pipeline uses CPS transformation to allow pipelines to survive restarts. Every local variable, closure, and object reachable from the pipeline script is serialized to `program.dat` at every suspension point (each step call). This means:

```groovy
// This allocates ~10MB that is serialized at EACH echo/sh/sleep call:
def bigData = sh(script: 'cat hugefile.txt', returnStdout: true)
echo "size: ${bigData.length()}"  // serializes 10MB to program.dat
sh "echo done"                     // serializes 10MB again
sleep 1                            // serializes 10MB again
```

### @NonCPS Annotation

```groovy
// This method runs WITHOUT CPS serialization
// It processes data in normal Groovy memory management
@NonCPS
def processData(String content) {
    // Can do heavy processing here without serialization overhead
    return content.split('\n').collect { it.toUpperCase() }.join('\n')
}

// But @NonCPS methods CANNOT call pipeline steps:
@NonCPS
def broken() {
    sh "echo hello"  // ERROR: CPS-transformed step in @NonCPS context
}
```

## Clean Up

```bash
./cleanup.sh
```
