// broken-bpf.c — Intentionally broken eBPF program
// Simulates common eBPF verifier rejection scenarios
//
// This program has multiple issues that prevent it from loading:
// 1. Stack size exceeds 512 bytes (kernel limit)
// 2. Too many instructions (exceeds complexity limit)
// 3. References a kprobe that was renamed in newer kernels
// 4. Uses helper that requires CAP_SYS_ADMIN without it
//
// Compile with:
//   clang -O2 -target bpf -c broken-bpf.c -o broken-bpf.o
//
// Attempt to load with:
//   sudo bpftool prog load broken-bpf.o /sys/fs/bpf/broken_prog
//

#include <linux/bpf.h>
#include <linux/ptrace.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

// BUG #1: Stack frame exceeds 512 bytes
// The BPF verifier enforces a maximum of 512 bytes of stack per function
struct event_data {
    char comm[256];          // 256 bytes
    char filename[256];      // 256 bytes  
    __u64 timestamps[16];   // 128 bytes
    __u32 pid;
    __u32 tgid;
    __u32 uid;
    __u32 flags;
};  // Total: ~656 bytes — EXCEEDS 512-byte stack limit

// BUG #2: Map creation will fail if RLIMIT_MEMLOCK is too low
// Default is 64KB, this map requires ~4MB
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 1048576);   // 1M entries — large allocation
    __type(key, __u32);
    __type(value, struct event_data);
} events SEC(".maps");

struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 16 * 1024 * 1024);  // 16MB ring buffer
} ringbuf SEC(".maps");

// BUG #3: Attaches to kprobe that was renamed in kernel 5.18+
// In older kernels: do_sys_open
// In newer kernels: do_sys_openat2
SEC("kprobe/do_sys_open")
int trace_open(struct pt_regs *ctx)
{
    // BUG #1 manifests here: stack allocation too large
    struct event_data data = {};
    
    __u32 pid = bpf_get_current_pid_tgid() >> 32;
    data.pid = pid;
    data.tgid = bpf_get_current_pid_tgid() & 0xFFFFFFFF;
    data.uid = bpf_get_current_uid_gid() & 0xFFFFFFFF;
    
    bpf_get_current_comm(&data.comm, sizeof(data.comm));
    
    // BUG #4: bpf_probe_read_user on kernel address — will be rejected by verifier
    // or produce undefined behavior
    const char *filename = (const char *)PT_REGS_PARM2(ctx);
    bpf_probe_read_user_str(&data.filename, sizeof(data.filename), filename);
    
    // Simulated complex logic that generates too many instructions
    // BUG #2 (complexity): Nested loops that blow up instruction count
    #pragma unroll
    for (int i = 0; i < 16; i++) {
        data.timestamps[i] = bpf_ktime_get_ns();
        
        // Each iteration reads more data, compounding complexity
        struct event_data *existing = bpf_map_lookup_elem(&events, &pid);
        if (existing) {
            existing->timestamps[i] = data.timestamps[i];
            // Nested condition chains increase verifier states exponentially
            if (existing->pid > 1000) {
                if (existing->uid == 0) {
                    if (existing->flags & 0x1) {
                        data.flags |= (1 << i);
                    }
                }
            }
        }
    }
    
    // Update map
    bpf_map_update_elem(&events, &pid, &data, BPF_ANY);
    
    // Ring buffer submission
    struct event_data *rb_data = bpf_ringbuf_reserve(&ringbuf, sizeof(*rb_data), 0);
    if (rb_data) {
        __builtin_memcpy(rb_data, &data, sizeof(data));
        bpf_ringbuf_submit(rb_data, 0);
    }
    
    return 0;
}

// BUG #5: This program type (tracing) requires CONFIG_DEBUG_INFO_BTF
// Without BTF, the kernel cannot resolve type information for CO-RE
SEC("tp_btf/sched_process_exec")
int handle_exec(void *ctx)
{
    struct event_data data = {};
    __u32 pid = bpf_get_current_pid_tgid() >> 32;
    bpf_get_current_comm(&data.comm, sizeof(data.comm));
    bpf_map_update_elem(&events, &pid, &data, BPF_ANY);
    return 0;
}

char LICENSE[] SEC("license") = "GPL";
