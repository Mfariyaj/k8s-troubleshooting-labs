# Lab 13: eBPF Program Loading Failures — Verifier Rejections

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your security team deployed a new eBPF-based runtime security agent (similar to Falco/Tetragon) across your Kubernetes cluster. On 30% of nodes, the agent fails to start with cryptic BPF verifier errors. The agent pods are in `CrashLoopBackOff` and the security team has no kernel experience.

You need to diagnose why the BPF programs won't load, identify the kernel/environment issues, and implement fixes or workarounds.

## Environment

- **Nodes that work**: Ubuntu 22.04, kernel 5.15.0-91-generic, 128GB RAM
- **Nodes that fail**: Ubuntu 20.04, kernel 5.4.0-167-generic, 32GB RAM
- **Agent**: Custom BPF programs using CO-RE (Compile Once, Run Everywhere)
- **Language**: C → compiled with clang targeting BPF
- **Loader**: libbpf 1.2

## Symptoms Observed

### Agent pod logs (failing nodes):
```
2024-03-15T14:23:45Z ERR Failed to load BPF program error="load program: permission denied"
2024-03-15T14:23:45Z ERR  → Verifier: func#0 stack size 656 exceeds maximum 512
2024-03-15T14:23:46Z ERR Failed to create BPF map "events": Operation not permitted (RLIMIT_MEMLOCK=64KB)
2024-03-15T14:23:46Z ERR Failed to load BPF program error="load program: invalid argument"
2024-03-15T14:23:46Z ERR  → Verifier: program type 'tp_btf' requires CONFIG_DEBUG_INFO_BTF=y
2024-03-15T14:23:47Z ERR Failed to attach kprobe error="attach kprobe: open /sys/kernel/debug/tracing/kprobe_events: no such file or directory"
2024-03-15T14:23:47Z WRN Falling back to legacy kprobe attachment
2024-03-15T14:23:47Z ERR Failed to attach kprobe to do_sys_open error="create perf event: no such file or directory"
2024-03-15T14:23:47Z ERR  → Hint: symbol 'do_sys_open' not found in /proc/kallsyms
2024-03-15T14:23:48Z FTL All BPF program loads failed, exiting
```

### bpftool prog load attempt:
```
$ sudo bpftool prog load /opt/agent/probe.o /sys/fs/bpf/security_probe
libbpf: elf: skipping unrecognized data section(6) .rodata.str1.1
libbpf: prog 'trace_open': BPF program load failed: Permission denied
libbpf: prog 'trace_open': -- BEGIN PROG LOAD LOG --
func#0 @0
0: R1=ctx(off=0,imm=0) R10=fp0
; struct event_data data = {};
1: (bf) r6 = r1
2: (b7) r1 = 0  
3: (7b) *(u64 *)(r10 -8) = r1
4: (7b) *(u64 *)(r10 -16) = r1
...
82: (7b) *(u64 *)(r10 -656) = r1
combined stack size of 2 calls is 784. Too large
-- END PROG LOAD LOG --
libbpf: prog 'trace_open': failed to load: -1 (Permission denied)
libbpf: failed to load object '/opt/agent/probe.o'
Error: failed to load BPF object file
```

### Map creation failure:
```
$ sudo bpftool map create /sys/fs/bpf/events type hash key 4 value 656 entries 1048576 name events
Error: failed to create map (Operation not permitted)
$ ulimit -l
64
```

### BTF check:
```
$ ls /sys/kernel/btf/vmlinux
ls: cannot access '/sys/kernel/btf/vmlinux': No such file or directory
$ grep CONFIG_DEBUG_INFO_BTF /boot/config-$(uname -r)
# CONFIG_DEBUG_INFO_BTF is not set
```

### kprobe availability:
```
$ grep do_sys_open /proc/kallsyms
(no output — function does not exist in this kernel)
$ grep do_sys_openat /proc/kallsyms
ffffffff812e4530 T do_sys_openat2
ffffffff812e4780 T __x64_sys_openat
```

### Kernel capabilities and config:
```
$ cat /proc/sys/kernel/unprivileged_bpf_disabled
2
$ sysctl kernel.unprivileged_bpf_disabled
kernel.unprivileged_bpf_disabled = 2
$ grep -E "CONFIG_BPF|CONFIG_DEBUG_INFO" /boot/config-$(uname -r)
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_BPF_JIT_ALWAYS_ON=y
# CONFIG_DEBUG_INFO_BTF is not set
# CONFIG_DEBUG_INFO_BTF_MODULES is not set
```

### Memory lock limits:
```
$ cat /proc/$(pidof agent)/limits | grep "locked"
Max locked memory     65536     65536     bytes
$ systemctl show agent-daemonset | grep LimitMEMLOCK
LimitMEMLOCK=65536
```

## Your Task

1. Identify ALL reasons the BPF program fails to load
2. Fix the stack size issue (struct too large for BPF stack)
3. Fix the RLIMIT_MEMLOCK issue for map creation
4. Resolve the missing BTF problem (kernel without CONFIG_DEBUG_INFO_BTF)
5. Fix the kprobe attachment point (renamed function)
6. Reduce program complexity to pass the verifier
7. Provide a comprehensive fix that works across both kernel versions

## Useful Commands

```bash
# Check kernel BPF support
cat /boot/config-$(uname -r) | grep -E "CONFIG_BPF|CONFIG_BTF"

# Check BTF availability
ls -la /sys/kernel/btf/vmlinux
bpftool btf show

# Check available kprobes
cat /proc/kallsyms | grep sys_open
cat /sys/kernel/debug/tracing/available_filter_functions | grep open

# Check memory lock limits
ulimit -l
cat /proc/self/limits

# Set unlimited memlock (fix #1)
ulimit -l unlimited
# Or for systemd services:
# LimitMEMLOCK=infinity in unit file

# Inspect BPF program
bpftool prog show
bpftool prog dump xlated id <id>
bpftool prog dump jited id <id>

# Check BPF filesystem
mount | grep bpf
ls /sys/fs/bpf/

# Inspect compiled BPF object
llvm-objdump -d broken-bpf.o
llvm-readelf -S broken-bpf.o

# Check verifier log verbosity
bpftool -d prog load broken-bpf.o /sys/fs/bpf/test

# Trace BPF syscalls
strace -e bpf bpftool prog load broken-bpf.o /sys/fs/bpf/test 2>&1

# Check loaded BPF programs
bpftool prog list
bpftool map list

# Verify kprobe exists
grep do_sys_open /proc/kallsyms
cat /sys/kernel/debug/tracing/available_filter_functions | grep -w do_sys_open
```

## Hints

<details>
<summary>Hint 1</summary>
The stack size limit in BPF is 512 bytes per function (hard kernel limit). The <code>struct event_data</code> is 656 bytes. Fix by allocating it from a <code>BPF_MAP_TYPE_PERCPU_ARRAY</code> map instead of the stack, or split the struct into smaller pieces passed via separate maps.
</details>

<details>
<summary>Hint 2</summary>
On kernels < 5.11, BPF map memory is charged against <code>RLIMIT_MEMLOCK</code>. A map with 1M entries × 656 bytes/entry needs ~660MB of locked memory. Either increase the limit (<code>ulimit -l unlimited</code> or <code>LimitMEMLOCK=infinity</code> in systemd), reduce map size, or upgrade to kernel ≥5.11 where memcg accounting replaces memlock.
</details>

<details>
<summary>Hint 3</summary>
For BTF: install <code>linux-image-*-dbgsym</code> package or use a BTF-enabled kernel. Without BTF, <code>tp_btf</code> program types won't load. Fallback to raw tracepoints (<code>SEC("raw_tracepoint/sched_process_exec")</code>) or use <code>pahole</code> to generate BTF from DWARF. For the kprobe rename: check <code>/proc/kallsyms</code> for the actual function name and update the SEC() attachment point.
</details>

## Root Causes

This lab demonstrates **five independent eBPF loading failures**:

1. **Stack overflow (656 > 512 bytes)** — BPF programs have a hard 512-byte stack limit per function. Large structs must be allocated from maps.

2. **RLIMIT_MEMLOCK too low** — Map creation fails with EPERM when the process can't lock enough memory. Fixed by increasing the limit or using kernel ≥5.11.

3. **Missing BTF (CONFIG_DEBUG_INFO_BTF=n)** — CO-RE and `tp_btf` programs require BTF type information baked into the kernel. Without it, programs using these features won't load.

4. **Renamed kprobe target** — `do_sys_open` was refactored to `do_sys_openat2` in kernel 5.18. Programs must check `/proc/kallsyms` and attach to the correct symbol.

5. **Program complexity** — Nested loops with map lookups and conditionals create exponential verifier states. BPF verifier has a 1M instruction processing limit; complex programs must be restructured.
