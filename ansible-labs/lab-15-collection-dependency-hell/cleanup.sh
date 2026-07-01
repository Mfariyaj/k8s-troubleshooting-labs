#!/bin/bash
# Lab 15: Cleanup

echo "Cleaning up Lab 15: Collection Dependency Hell..."

rm -rf /tmp/ansible-lab15
rm -rf "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/collections/ansible_collections"

echo "Cleanup complete."
