## Solution: lab-07-latency-injection

### Root Cause
Add 5s latency: do timeouts fire? Does canary detect it?

### Fix
1. Identify the misconfiguration from the error message
2. Fix the broken config file (check for typos, wrong values, missing fields)
3. Restart/re-apply the configuration
4. Verify the error is resolved

### Key Takeaway
Always read error messages carefully — they usually point directly to the problem.
Check configuration syntax, paths, and connectivity before diving deeper.
