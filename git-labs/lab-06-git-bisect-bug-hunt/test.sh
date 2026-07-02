#!/bin/bash
# Test script for Lab 06: Git Bisect
# Returns 0 (good) if calculator.py is correct
# Returns 1 (bad) if calculator.py has the bug

cd "$(dirname "$0")"

if [ ! -f calculator.py ]; then
    echo "ERROR: calculator.py not found"
    exit 1
fi

# Test: calculate_total with items totaling $100 should give $110 (10% tax)
RESULT=$(python3 -c "
import sys
sys.path.insert(0, '.')
from calculator import calculate_total
items = [{'price': 50, 'quantity': 1}, {'price': 25, 'quantity': 2}]
total = calculate_total(items)
# Expected: 100 + 10 = 110 (10% tax on $100)
if abs(total - 110.0) < 0.01:
    sys.exit(0)
else:
    print(f'FAIL: expected 110.0, got {total}')
    sys.exit(1)
" 2>&1)

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "PASS: calculate_total works correctly"
else
    echo "FAIL: $RESULT"
fi

exit $EXIT_CODE
