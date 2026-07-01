# Solution: Lab 03 - Matrix Strategy Issues

## Problem

The matrix build creates too many combinations, some jobs fail on wrong runner OS,
and the `exclude` syntax doesn't work as intended.

## Diagnosis

```bash
# Check the workflow
cat .github/workflows/ci.yml

# Look for:
# - Matrix that generates excessive combinations (combinatorial explosion)
# - exclude syntax errors
# - Jobs running on wrong runner type for the OS
```

## Root Cause

1. **Too many combinations**: Large matrix dimensions multiply (e.g., 4 OS × 5 versions
   × 3 flags = 60 jobs), exhausting runner capacity.
2. **Wrong `exclude` syntax**: Exclude entries must exactly match matrix dimension values.
3. **Wrong runners for OS**: Using `ubuntu-latest` for Windows builds or vice versa.

## Fix

```yaml
jobs:
  test:
    strategy:
      # FIXED: Reduce combinations with explicit includes
      matrix:
        os: [ubuntu-latest, windows-latest]
        node: [18, 20]
        # BROKEN: exclude didn't match due to type mismatch
        # exclude:
        #   - os: windows-latest
        #     node: "18"    # String vs number mismatch!
        # FIXED: Match types exactly
        exclude:
          - os: windows-latest
            node: 18

      # Limit concurrent jobs
      max-parallel: 4
      fail-fast: false

    # FIXED: Use the matrix OS for the runner
    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
      - run: npm ci
      - run: npm test
```

## Key Fixes

| Issue | Fix |
|-------|-----|
| Too many combos | Reduce dimensions, use `max-parallel` |
| Exclude syntax | Match value types (string vs number) exactly |
| Wrong runner | Use `runs-on: ${{ matrix.os }}` |

## Verification

```bash
# Count expected jobs (should be manageable)
# 2 OS × 2 Node versions - 1 exclude = 3 jobs

# Push and verify in Actions tab:
# - Correct number of matrix jobs spawn
# - Each job runs on the right OS
# - Excluded combination doesn't run
```

## Key Takeaways

- Matrix values are type-sensitive: `18` (number) ≠ `"18"` (string)
- Use `max-parallel` to limit resource consumption
- Match `runs-on` to the OS in your matrix
- Prefer `include` for specific combinations over large matrix products
