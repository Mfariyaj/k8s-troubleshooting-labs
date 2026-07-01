#!/bin/bash
# Creates zombie processes by forking children that exit
# but the parent never calls wait() to reap them

MARKER="/tmp/.lab02-zombie-running"
touch "$MARKER"

create_zombie() {
    # Fork a child that immediately exits
    # Parent doesn't wait(), so child becomes zombie
    (
        exit 0
    ) &
    # Intentionally NOT calling: wait $!
}

echo "PID $$ creating zombie processes..."

# Create multiple zombie processes
for i in $(seq 1 15); do
    create_zombie
    sleep 0.2
done

echo "Created 15 zombie children. Parent PID: $$"
echo "$$" > /tmp/.lab02-parent-pid

# Keep parent alive so zombies persist
while [ -f "$MARKER" ]; do
    # Periodically create more zombies
    create_zombie
    sleep 10
done
