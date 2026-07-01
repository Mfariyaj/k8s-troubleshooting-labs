# Solution: Lab 13 - eBPF Program Loading Failure

## Problem

eBPF programs fail to load with errors related to memory locking limits, stack size
violations, or missing BTF (BPF Type Format) information.

## Diagnosis

```bash
# Try loading the BPF program and observe errors
sudo bpftool prog load broken-bpf.o /sys/fs/bpf/test

# Check current RLIMIT_MEMLOCK
ulimit -l

# Check if BTF is available
ls /sys/kernel/btf/vmlinux
cat /proc/config.gz | gunzip | grep CONFIG_DEBUG_INFO_BTF

# Check kernel version supports BPF features
uname -r
bpftool feature
```

## Root Cause

Three issues prevent eBPF program loading:

1. **RLIMIT_MEMLOCK too low**: BPF maps and programs need locked memory.
2. **Stack size exceeded**: BPF programs have a 512-byte stack limit.
3. **BTF not enabled**: CO-RE (Compile Once, Run Everywhere) requires BTF in kernel.

## Fix

### Step 1: Increase RLIMIT_MEMLOCK

```bash
# Temporarily increase for current session
ulimit -l unlimited

# Permanently via limits.conf
echo "* - memlock unlimited" | sudo tee -a /etc/security/limits.d/99-bpf.conf

# Or set in systemd service:
# [Service]
# LimitMEMLOCK=infinity
```

### Step 2: Fix stack size in BPF program

```c
// In the BPF C source, reduce stack usage:
// - Move large arrays to BPF maps instead of stack variables
// - Use per-CPU arrays for temporary storage
// - Keep local variables under 512 bytes total
```

### Step 3: Enable BTF in kernel

```bash
# Check if CONFIG_DEBUG_INFO_BTF is enabled
zcat /proc/config.gz | grep BTF

# If not available, install kernel with BTF support
# For Ubuntu: sudo apt install linux-image-generic (5.4+)

# Or generate BTF from DWARF:
# pahole --btf_encode_detached vmlinux.btf vmlinux
```

## Verification

```bash
# Verify memlock is unlimited
ulimit -l

# Verify BTF exists
ls -la /sys/kernel/btf/vmlinux

# Load the fixed BPF program
sudo bpftool prog load fixed-bpf.o /sys/fs/bpf/test
sudo bpftool prog list
```

## Prevention

- Set `LimitMEMLOCK=infinity` in all BPF-related service units
- Use kernels 5.8+ which remove the memlock requirement
- Keep BPF program stack usage well under 512 bytes
- Ensure production kernels are built with `CONFIG_DEBUG_INFO_BTF=y`
