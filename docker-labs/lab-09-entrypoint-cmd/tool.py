#!/usr/bin/env python3
"""Multi-purpose CLI tool that should accept command-line arguments."""

import sys
import json
from datetime import datetime

def show_help():
    print("""
Usage: tool.py <command> [options]

Commands:
  process --all       Process all items
  process --id <id>   Process a specific item
  list                List all items
  list --format json  List items in JSON format
  --version           Show version
  help                Show this help message
""")

def process_items(args):
    if '--all' in args:
        print("Processing all items...")
        print("  - Item 1: processed ✓")
        print("  - Item 2: processed ✓")
        print("  - Item 3: processed ✓")
        print("Done.")
    elif '--id' in args:
        idx = args.index('--id')
        item_id = args[idx + 1] if idx + 1 < len(args) else 'unknown'
        print(f"Processing item {item_id}...")
        print("Done.")
    else:
        print("Error: process requires --all or --id <id>")
        sys.exit(1)

def list_items(args):
    items = [
        {"id": 1, "name": "Widget", "status": "active"},
        {"id": 2, "name": "Gadget", "status": "active"},
        {"id": 3, "name": "Doohickey", "status": "inactive"},
    ]
    if '--format' in args and 'json' in args:
        print(json.dumps(items, indent=2))
    else:
        for item in items:
            print(f"  [{item['id']}] {item['name']} ({item['status']})")

def main():
    args = sys.argv[1:]
    
    print("Starting CLI tool...")
    
    if not args:
        # Default command when no args provided
        print("Running default command: process --all")
        process_items(['--all'])
        return
    
    command = args[0]
    
    if command == '--version':
        print("tool.py version 2.4.1")
    elif command == 'help' or command == '--help':
        show_help()
    elif command == 'process':
        process_items(args[1:])
    elif command == 'list':
        list_items(args[1:])
    else:
        print(f"Unknown command: {command}")
        print("Run 'tool.py help' for usage information")
        sys.exit(1)

if __name__ == '__main__':
    main()
