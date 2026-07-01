# Lab 01: Pipeline Syntax Errors

## Difficulty: ⭐ Easy

## Scenario

A developer wrote a declarative Jenkins pipeline but it fails immediately without executing any stage. The pipeline has multiple syntax violations.

## Console Error Output

```
org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
WorkflowScript: 1: Not a valid section definition: "stages". Some extra configuration is required. @ line 1, column 1.
   stages {
   ^

WorkflowScript: 15: Expected a stage @ line 15, column 5.
       stage('Test') {
       ^

WorkflowScript: 17: Variable definitions not allowed here. @ line 17, column 13.
               def testResult = sh(script: 'echo "running tests"', returnStdout: true)
               ^

3 errors
```

## Hints

1. In declarative pipelines, `stages` must be inside `pipeline { }` — not outside
2. `def` (variable definitions) are not allowed in declarative `steps` blocks — use `script { }` wrapper
3. Individual `stage` blocks must be nested inside a `stages` block
4. Check all braces are balanced

## What to Fix

- Move all stages inside `pipeline { stages { ... } }`
- Wrap `def` in a `script { }` block
- Fix missing closing braces
