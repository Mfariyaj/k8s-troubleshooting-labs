#!/bin/bash
#
# simulate.sh — Simulates eBPF program loading failures
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo " Lab 13: eBPF Program Loading Failures"
echo "============================================"
echo ""

# Check prerequisites
echo "[Prerequisites Check]"
echo ""

# 1. Check kernel version
KERNEL_VERSION=$(uname -r)
echo "  Kernel: $KERNEL_VERSION"

# 2. Check BTF support
echo -n "  BTF support: "
if [[ -f /sys/kernel/btf/vmlinux ]]; then
    echo "YES (/sys/kernel/btf/vmlinux exists)"
else
    echo "NO — CONFIG_DEBUG_INFO_BTF not enabled!"
    echo "  ⚠️  BPF CO-RE and tp_btf programs will FAIL to load"
fi

# 3. Check bpf filesystem
echo -n "  BPF filesystem: "
if mount | grep -q "type bpf"; then
    echo "mounted"
else
    echo "NOT MOUNTED"
    echo "  Mount with: mount -t bpf bpf /sys/fs/bpf"
fi

# 4. Check RLIMIT_MEMLOCK
MEMLOCK=$(ulimit -l)
echo "  RLIMIT_MEMLOCK: ${MEMLOCK} KB"
if [[ "$MEMLOCK" != "unlimited" && "$MEMLOCK" -lt 65536 ]]; then
    echo "  ⚠️  Too low for large BPF maps! Need unlimited or ≥65536 KB"
fi

# 5. Check bpftool
echo -n "  bpftool: "
if command -v bpftool &>/dev/null; then
    echo "$(bpftool version 2>/dev/null | head -1)"
else
    echo "NOT INSTALLED"
fi

# 6. Check clang
echo -n "  clang: "
if command -v clang &>/dev/null; then
    echo "$(clang --version 2>/dev/null | head -1)"
else
    echo "NOT INSTALLED — needed to compile BPF programs"
fi

echo ""
echo "============================================"
echo " Attempting to compile and load broken BPF program..."
echo "============================================"
echo ""

# Step 1: Set low RLIMIT_MEMLOCK to trigger map creation failure
echo "[BUG TRIGGER] Setting RLIMIT_MEMLOCK to 64KB (too low for maps)..."
ulimit -l 64 2>/dev/null || echo "  (Could not set ulimit — may need non-root shell)"

# Step 2: Try to compile
if command -v clang &>/dev/null; then
    echo ""
    echo "[Compiling] clang -O2 -target bpf -c broken-bpf.c -o /tmp/broken-bpf.o"
    echo ""
    
    cd "$SCRIPT_DIR"
    # This will likely fail due to missing headers, which is expected
    clang -O2 -target bpf \
        -I /usr/include \
        -I /usr/include/x86_64-linux-gnu \
        -c broken-bpf.c -o /tmp/broken-bpf.o 2>&1 || {
        echo ""
        echo "Compilation failed (expected — missing BPF headers or issues in code)"
        echo ""
        echo "Even if compilation succeeds, loading would fail with:"
        echo "============================================"
        echo ""
        # Show what the verifier errors would look like
        cat << 'VERIFIER_OUTPUT'
Attempting: bpftool prog load /tmp/broken-bpf.o /sys/fs/bpf/broken_prog

Error: failed to load program
Verifier log:
  func#0 @0
  0: R1=ctx(off=0,imm=0) R10=fp0
  ; struct event_data data = {};
  1: (bf) r6 = r1                       ; R1=ctx(off=0,imm=0) R6_w=ctx(off=0,imm=0)
  2: (b7) r1 = 0                        ; R1_w=0
  3: (7b) *(u64 *)(r10 -656) = r1
  ...
  ERROR: stack frame size (656) exceeds maximum (512)
  
  processed 1234 insns (limit 1000000) max_states_per_insn 12 total_states 89
  peak_states 89 mark_read 34
  
libbpf: prog 'trace_open': BPF program load failed: Permission denied
libbpf: prog 'trace_open': failed to load: -13
libbpf: failed to load object '/tmp/broken-bpf.o'
Error: failed to load BPF object file

Additional errors if BTF not available:
  libbpf: prog 'handle_exec': BPF program load failed: Invalid argument
  libbpf: prog 'handle_exec': -- BEGIN PROG LOAD LOG --
  program type 'tp_btf' requires CONFIG_DEBUG_INFO_BTF=y kernel config
  -- END PROG LOAD LOG --

RLIMIT_MEMLOCK error for map creation:
  libbpf: map 'events': failed to create: Operation not permitted
  libbpf: Error: map creation failed for events (Operation not permitted)
  Hint: The 'events' map requires ~660MB of locked memory.
        Current RLIMIT_MEMLOCK: 65536 bytes
        Increase with: ulimit -l unlimited
        Or use kernel >=5.11 with CAP_BPF (no memlock needed)

kprobe attachment failure (kernel >=5.18):
  libbpf: prog 'trace_open': failed to attach to kprobe 'do_sys_open': No such file or directory
  Hint: 'do_sys_open' was renamed to 'do_sys_openat2' in kernel 5.18
        Use: SEC("kprobe/do_sys_openat2") or SEC("kprobe/__x64_sys_openat")
VERIFIER_OUTPUT
    }
else
    echo "clang not installed. Showing expected errors from loading broken BPF program:"
    echo ""
    cat << 'ERRORS'
Error #1 — Stack size exceeded:
  ERROR: stack frame size (656) exceeds maximum (512)
  CAUSE: struct event_data is 656 bytes, kernel allows max 512 per stack frame
  FIX: Use BPF_MAP_TYPE_PERCPU_ARRAY as scratch space, or split into smaller structs

Error #2 — Map creation failed (RLIMIT_MEMLOCK):
  libbpf: map 'events': failed to create: Operation not permitted (EPERM)
  CAUSE: RLIMIT_MEMLOCK=64KB, map needs ~660MB for 1M entries
  FIX: ulimit -l unlimited (or use kernel >=5.11 with unprivileged_bpf_disabled=0)

Error #3 — kprobe not found (kernel >=5.18):
  failed to attach to kprobe 'do_sys_open': No such file or directory
  CAUSE: Function renamed to do_sys_openat2 in newer kernels
  FIX: Use SEC("kprobe/do_sys_openat2") or check /proc/kallsyms

Error #4 — BTF not available:
  program type 'tp_btf' requires CONFIG_DEBUG_INFO_BTF=y
  CAUSE: Kernel compiled without BTF (type information for CO-RE)
  FIX: Install kernel with CONFIG_DEBUG_INFO_BTF=y, or use legacy tracepoints

Error #5 — Instruction complexity:
  BPF program is too complex (processed 1048577 insns, limit 1000000)
  CAUSE: Nested loops + map lookups create exponential verifier states
  FIX: Reduce loop iterations, use bounded loops, simplify branching
ERRORS
fi

echo ""
echo "============================================"
echo " YOUR TASK: Fix all eBPF loading issues"
echo "============================================"
echo "  1. Fix stack overflow (struct too large)"
echo "  2. Fix RLIMIT_MEMLOCK for map creation"
echo "  3. Fix kprobe attachment point name"
echo "  4. Enable BTF or use alternative program type"
echo "  5. Reduce program complexity"
echo "============================================"
