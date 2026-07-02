## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (simulates the broken system state)
2. Investigate using standard Linux tools: `df`, `ps`, `ss`, `dmesg`, `journalctl`
3. Identify the root cause from system output
4. Apply the fix (the README hints at what's wrong)
5. Verify the system is healthy
6. Cleanup: `./cleanup.sh`. Check `solution.md` if stuck

---

# Lab 12: Network Namespace Leak — Orphaned Container Namespaces

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

A Kubernetes worker node running containerd has been in production for 60 days without restart. Over time, the node has accumulated **500+ orphaned network namespaces** from containers that were killed but whose network namespaces were never cleaned up due to a buggy CNI plugin version.

**Impact:**
- IPAM (IP Address Management) has exhausted its /24 subnet (254 usable IPs)
- New pods fail to start with `failed to allocate IP` errors
- `ip link` shows hundreds of orphaned `veth` pairs still attached to `cni0` bridge
- Host routing table has 500+ stale routes

The platform team needs to identify the leak, reclaim IPs, and clean up without disrupting running workloads.

## Environment

- **OS**: Ubuntu 22.04 LTS (Kernel 5.15)
- **Container Runtime**: containerd 1.7.2
- **CNI Plugin**: bridge + host-local IPAM (v1.2.0 — buggy)
- **Network**: 10.244.1.0/24 (Pod CIDR for this node)
- **Kubernetes**: v1.28

## Symptoms Observed

### kubelet logs:
```
Jul 01 09:14:23 worker-3 kubelet[1423]: E0701 09:14:23.123456  1423 cni.go:342]
  Error adding pod "web-server-7f8b9d4c5-x2k1l_default" to network "cni0":
  failed to allocate for range 0: no IP addresses available in range set: 10.244.1.1-10.244.1.254
Jul 01 09:14:23 worker-3 kubelet[1423]: E0701 09:14:23.123789  1423 cni.go:369]
  Error: failed to set up sandbox container networking: [/etc/cni/net.d/10-bridge.conflist]:
  error getting ClusterInformation: connection refused
```

### ip netns list (truncated):
```
cni-5a2b3c4d-1234-5678-9abc-def012345678
cni-6b3c4d5e-2345-6789-abcd-ef0123456789
cni-7c4d5e6f-3456-7890-bcde-f01234567890
cni-8d5e6f70-4567-8901-cdef-012345678901
... (523 total namespaces)
cni-ff9e8d7c-9876-5432-1098-765432109876
```

### ip link show type veth (truncated):
```
1847: veth3a2b1c0d@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master cni0 state UP
1849: veth4b3c2d1e@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master cni0 state UP
1851: veth5c4d3e2f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master cni0 state UP
... (500+ veth pairs)
```

### IPAM state (/var/lib/cni/networks/cni0/):
```
$ ls /var/lib/cni/networks/cni0/ | wc -l
254
$ cat /var/lib/cni/networks/cni0/10.244.1.15
cni-5a2b3c4d-1234-5678-9abc-def012345678
$ # But this container no longer exists!
$ crictl ps -a | grep -c "Exited"
12
$ crictl ps | wc -l
45   # Only 44 running containers, but 254 IPs allocated
```

### bridge fdb and routing:
```
$ ip route | grep "10.244.1" | wc -l
254
$ bridge link show | grep cni0 | wc -l
512
$ arp -a | grep "10.244.1" | wc -l
254
```

### cni0 bridge status:
```
$ ip -d link show cni0
5: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 2e:4f:8a:1b:3c:5d brd ff:ff:ff:ff:ff:ff promiscuity 0 minmtu 68 maxmtu 65535
    bridge forward_delay 1500 hello_time 200 max_age 2000 ageing_time 30000 stp_state 0
    numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
$ brctl show cni0
bridge name    bridge id          STP enabled    interfaces
cni0           8000.2e4f8a1b3c5d  no             veth3a2b1c0d
                                                 veth4b3c2d1e
                                                 veth5c4d3e2f
                                                 ... (500+ interfaces)
```

## Your Task

1. Identify which network namespaces are orphaned (no associated running container)
2. Cross-reference IPAM allocations with actually running containers
3. Clean up orphaned namespaces without disrupting running pods
4. Reclaim IP addresses from the IPAM store
5. Remove stale veth pairs from the bridge
6. Identify the root cause (missing DEL call from container runtime to CNI)
7. Verify new pods can now get IP addresses

## Useful Commands

```bash
# List all network namespaces
ip netns list | wc -l

# List running containers
crictl ps --output json | jq -r '.containers[].id'

# Check IPAM allocations
ls /var/lib/cni/networks/cni0/
cat /var/lib/cni/networks/cni0/last_reserved_ip.0

# Cross-reference: find orphaned namespaces
for ns in $(ip netns list | awk '{print $1}'); do
    if ! crictl ps -a --output json | jq -r '.containers[].id' | grep -q "${ns#cni-}"; then
        echo "ORPHANED: $ns"
    fi
done

# Check veth pairs and their namespace association
ip link show type veth
ip netns exec <namespace> ip addr show

# View bridge members
bridge link show
brctl show cni0

# Check available IPs in IPAM range
ls /var/lib/cni/networks/cni0/ | grep -E "^10\." | wc -l

# Safely delete an orphaned namespace
ip netns del <namespace-name>
rm /var/lib/cni/networks/cni0/<ip-address>

# Monitor namespace count
watch -n1 'ip netns list | wc -l'

# Check containerd events for missed DEL calls
journalctl -u containerd --since "7 days ago" | grep -i "delete\|cleanup\|cni"
```

## Hints

<details>
<summary>Hint 1</summary>
The IPAM state is stored in <code>/var/lib/cni/networks/cni0/</code>. Each file is named with an IP address and contains the container ID that owns it. Compare this with <code>crictl ps -a</code> output to find IPs allocated to containers that no longer exist.
</details>

<details>
<summary>Hint 2</summary>
Each orphaned namespace has a veth pair — one end in the namespace, one end on the <code>cni0</code> bridge. When you delete the namespace (<code>ip netns del</code>), the kernel automatically cleans up the veth pair. But you MUST also remove the IPAM allocation file or the IP won't be reclaimed.
</details>

<details>
<summary>Hint 3</summary>
The root cause is that the CNI DEL command was never called when containers were killed. This can happen if: (a) containerd killed containers with SIGKILL bypassing cleanup hooks, (b) the CNI binary crashed during DEL, (c) the network namespace file was leaked because the CNI plugin returned success before cleanup was complete. Check <code>journalctl -u containerd</code> for patterns.
</details>

## Root Causes

This lab demonstrates **CNI plugin resource leaking**, caused by:

1. **CNI DEL never called** — When containers are force-killed or the kubelet is restarted during pod teardown, the CNI DEL operation may be skipped entirely, leaving namespace + IPAM allocation orphaned.

2. **IPAM store not reconciled** — The `host-local` IPAM plugin stores allocations on disk but has no garbage collection. Dead containers keep their IP reservations forever.

3. **veth pairs never cleaned** — Without namespace deletion, the host-side veth remains attached to `cni0`, consuming kernel memory and bridge FDB entries.

4. **No periodic reconciliation** — Unlike Calico or Cilium, the basic bridge CNI has no daemon that periodically reconciles state. It relies entirely on proper ADD/DEL lifecycle.
