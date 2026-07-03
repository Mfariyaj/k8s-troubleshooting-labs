## Solution: lab-07-cloudformation-rollback

### Root Cause
Stack ROLLBACK_COMPLETE: circular dependency, resource limit hit

### Fix
1. Identify the misconfiguration from the error message
2. Fix the broken config file (check for typos, wrong values, missing fields)
3. Restart/re-apply the configuration
4. Verify the error is resolved

### Key Takeaway
Always read error messages carefully — they usually point directly to the problem.
Check configuration syntax, paths, and connectivity before diving deeper.
