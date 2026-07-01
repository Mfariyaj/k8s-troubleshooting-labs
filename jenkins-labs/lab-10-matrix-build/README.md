# Lab 10: Matrix Build

## Difficulty: ⭐⭐⭐ Hard

## Scenario

A matrix pipeline should build across multiple platforms and Java versions, but it fails with axis parsing errors, invalid exclude syntax, and stages that don't execute properly.

## Console Error Output

```
org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
WorkflowScript: 37: Invalid axis value in exclude: "notValues" is not a recognized directive @ line 37, column 25.
                        notValues 'linux amd64'
                        ^

WorkflowScript: 12: Axis value 'linux amd64' contains whitespace which may cause 
unexpected behavior @ line 12, column 25.
                        values 'linux amd64', 'windows amd64', 'darwin arm64'
                        ^

WorkflowScript: 30: In "exclude" block: "value" should be "values" @ line 30, column 25.
                            value '8'
                            ^

3 errors
```

## Hints

1. Axis values should not contain spaces — use underscores or separate axes for OS and arch
2. In `exclude` blocks, use `values` (plural) not `value` (singular)
3. `notValues` is not a valid directive — use separate exclude blocks with positive matching
4. Consider splitting `PLATFORM` into two axes: `OS` and `ARCH`
5. Each exclude block matches a complete combination to exclude

## What to Fix

- Replace spaces in axis values: `'linux_amd64'` or split into `OS` and `ARCH` axes
- Fix `value '8'` → `values '8'`
- Remove `notValues` and restructure excludes to use valid `values` directives
- Each `exclude` must specify all axes that form the combination to skip
