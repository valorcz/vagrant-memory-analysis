import { readFileSync, writeFileSync } from 'node:fs'
import { parseSync } from '@slidev/parser'

const filePath = 'slides.md'
const md = readFileSync(filePath, 'utf-8')
const lines = md.split('\n')
const data = parseSync(md, filePath)

console.log(`Loaded ${data.slides.length} slides from ${filePath}`)

// Map of slide index to replacement text
const replacements = new Map()

// 1. Slide 2: Why Memory Analysis? (XKCD #1328)
replacements.set(2, `---
layout: two-cols
title: Why Memory Analysis?
kicker: The Human Factor
---

::left::

* **The Patching Paradox**
  * Critical security patches fix severe vulnerabilities...
  * Yet production users reflexively hit *"Remind me later"*.
* **Why We Need Volatile Forensics**
  * Systems linger unpatched in enterprise fleets for months.
  * When perimeter defenses fail, RAM preserves the running truth.

::right::

<div class="flex h-full items-center justify-center p-2">
  <div class="bg-white p-3 rounded-xl shadow-2xl border border-slate-700/60 max-w-full">
    <img src="/images/xkcd-update.png" class="max-h-[360px] w-auto object-contain mx-auto" alt="XKCD #1328" />
  </div>
</div>

<!--
XKCD #1328: https://xkcd.com/1328/
What’s the real cause of all the security issues on laptops and desktops? This one :)
-->
`)

// 2. Slide 4: Secrets Trapped in RAM (XKCD #1354)
replacements.set(4, `---
layout: two-cols
title: Secrets Trapped in RAM
kicker: Volatile Vulnerabilities
---

::left::

* **The Scope of Memory Exposure**
  * Asymmetric private keys, TLS session tickets, active sessions.
  * In-memory process caches hold plaintext credentials (\`lsass.exe\`).
* **Hardware & Buffer Leaks**
  * Vulnerabilities like Heartbleed, Spectre, and Meltdown harvest data directly from volatile memory, leaving zero traces in disk logs.

::right::

<div class="flex h-full items-center justify-center p-2">
  <div class="bg-white p-3 rounded-xl shadow-2xl border border-slate-700/60 max-w-full">
    <img src="/images/xkcd-heartbleed.png" class="max-h-[360px] w-auto object-contain mx-auto" alt="XKCD #1354" />
  </div>
</div>

<!--
XKCD #1354: https://xkcd.com/1354/
Or you could consider Spectre/Meltdown, which still have related techniques and speculative execution side-channel attacks that haven’t been fully mitigated in hardware.
-->
`)

// 3. Slide 8: x86/x64 Memory Organization -> Split into 8a (vs) and 8b (default CR3)
replacements.set(8, `---
layout: vs
title: Physical vs. Virtual Memory
kicker: Memory Architecture
left:
  title: Physical RAM (Hardware)
  items:
    - Hardware DRAM DIMMs on motherboard
    - "Scrambled state: OS and all processes interleave"
    - "Capacity strictly bounded by physical chips"
    - Where volatile forensic images are seized
right:
  title: Virtual Memory (Book Index)
  items:
    - "Private space per process (0-4 GB or 128 TB)"
    - Process isolation prevents cross-process writes
    - Uniform paging in fixed 4 KB blocks
    - "Oversubscription: backed by disk swap"
---

<!--
Analogy: Every process gets a book with identical page numbers. But the OS translates those logical page numbers into completely different physical shelves in the warehouse (RAM).
-->

---
layout: default
title: "The Forensic Keystone: Register CR3"
kicker: Memory Architecture
---

Physical RAM is a raw, scrambled dump of billions of bytes with no visible process boundaries. How does an analyst reconstruct running processes from a flat binary dump?

<Callout tone="info" icon="lucide:key" class="my-6">
  <strong>The Directory Table Base (DTB):</strong><br/>
  The CPU register <code>CR3</code> holds the physical base address of each process's top-level page directory. When Volatility runs <code>imageinfo</code>, it hunts for valid kernel <code>CR3</code> structures. <strong>Without CR3, virtual addresses cannot be resolved into executable code or running processes!</strong>
</Callout>

* **Per-Process Page Tables**: Every process has its own CR3 pointer stored in kernel \`_KPROCESS.DirectoryTableBase\`.
* **Hardware Page Walk**: The Memory Management Unit (MMU) walks 4-level page tables (\`PML4\` $\\to$ \`PDPT\` $\\to$ \`PD\` $\\to$ \`PT\`) to translate virtual offsets to physical frames.

<!--
A note about AArch64 / ARM64 is introduced later in the deck to contrast with x86/x64 flat and paged addressing.
-->
`)

// 3b. Slide 10: Logical vs. Physical Address Space
replacements.set(10, `---
layout: default
title: Logical vs. Physical Address Space
kicker: Memory Virtualization
---

<div class="grid grid-cols-2 gap-6 items-center">
  <Figure src="/images/logical-vs-physical-memory.png" caption="Process logical pages mapped to disjointed physical DRAM frames" />
  <Figure src="/images/paging-tables-disk.png" caption="Page tables with valid/invalid bits backed by swap/pagefile on disk" />
</div>

<!--
Reference: https://minnie.tuhs.org/CompArch/Lectures/week06.html
In other words, various isolated processes are multiplexed onto and share the same underlying physical memory frames.
-->
`)

// 4. Slide 12: Memory Addresses & Pointers (XKCD #138)
replacements.set(12, `---
layout: two-cols
title: Memory Addresses & Pointers
kicker: OS Fundamentals
---

::left::

* **Virtual Pointers in Userland**
  * Base addresses (\`0x00400000\`), stack pointers (\`ESP\`/\`RSP\`), PEB (\`0x7FFE0000\`).
* **Why Pointers Rule Memory Forensics**
  * Windows kernel structures (\`_EPROCESS\`, \`_ETHREAD\`) are linked entirely by pointers (\`Flink\`, \`Blink\`).
  * Rootkits unlink list pointers to evade detection APIs, but raw physical pointers remain discoverable.

::right::

<div class="flex h-full items-center justify-center p-2">
  <div class="bg-white p-3 rounded-xl shadow-2xl border border-slate-700/60 max-w-full">
    <img src="/images/xkcd-pointers.png" class="max-h-[360px] w-auto object-contain mx-auto" alt="XKCD #138" />
  </div>
</div>

<!--
XKCD #138: https://xkcd.com/138/
-->
`)

// 5. Slide 14: ARM64 Memory Organization
replacements.set(14, `---
layout: panels
title: ARM64 Memory Architecture
kicker: Modern Hardware Internals
panels:
  - { icon: "lucide:layers", title: Zero Segmentation, items: ["Completely abandons legacy x86 segmentation", "Enforces a clean, flat 64-bit virtual address space", "Compiler-aligned without segment registers"] }
  - { icon: "lucide:sliders", title: Flexible Granules, items: ["Configurable page sizes: 4 KB, 16 KB, or 64 KB", "Huge memory blocks: 2 MB and 1 GB", "OS-tailored: macOS on Apple Silicon defaults to 16 KB"] }
  - { icon: "lucide:split", title: Dual Base Registers, items: ["TTBR0_EL0: Dedicated to User-space translation", "TTBR1_EL1: Dedicated to Kernel-space translation", "Eliminates TLB flushes on user-to-kernel context switches"] }
---

<!--
A note about AArch64: In general, it looks somewhat similar to x86_64 — there is a TLB, translation tables, configurable granule page sizes (4 KB, 16 KB, or 64 KB; 2 MB and 1 GB blocks), and multiple levels (up to 4-level page tables indexed by TTBR0_EL0 for user space and TTBR1_EL1 for kernel space).
-->
`)

// 6. Slide 19: DKOM: Direct Kernel Object Manipulation -> Split into 19a and 19b
replacements.set(19, `---
layout: default
title: "DKOM: Direct Kernel Object Manipulation"
kicker: Rootkit Evasion
---

* **The Attack**: Kernel rootkits rewrite \`ActiveProcessLinks.Flink\` and \`Blink\` pointers to unlink an \`_EPROCESS\` block.
* **The Evasion**: The process vanishes from Task Manager, \`EnumProcesses\`, and standard security APIs.
* **The Rootkit Paradox**:
  * *To inflict damage, malware must execute code on CPU cores.*
  * *To execute on CPU cores, thread objects must stay scheduled in the dispatcher database.*
  * $\\to$ **Even if unlinked from process lists, all process pages and threads persist in physical RAM!**

<!--
Historical milestone paper: Jamie Butler (Black Hat USA 2004) - 'FU Rootkit / Direct Kernel Object Manipulation':
http://www.blackhat.com/presentations/bh-usa-04/bh-us-04-butler/bh-us-04-butler.pdf
-->

---
layout: vs
title: List Traversal vs. Pool Carving
kicker: Forensic Detection Strategy
left:
  title: vol pslist (API Traversal)
  items:
    - Traverses the kernel ActiveProcessLinks list
    - Fast and follows official OS data structures
    - "Vulnerability: blind to unlinked DKOM rootkits!"
    - If a rootkit unlinks its node, pslist reports nothing
right:
  title: vol psscan (Pool Carving)
  items:
    - Scans raw physical RAM byte-by-byte
    - Carves _EPROCESS structures by pool tag (Proc)
    - "The Catch: finds hidden rootkits & terminated PIDs"
    - "Classroom Analogy: checks physical chairs in aisles"
---

<!--
The Classroom Attendance Roster Analogy:
Imagine a student erases their name from the attendance sheet. When the teacher reads the list (pslist), the student is reported absent! But if the teacher walks down the aisles inspecting physical chairs (psscan), the student is caught red-handed.
-->
`)

// 6b. Slide 22: Process & DLL Injection Mechanics
replacements.set(22, `---
layout: panels
title: Process & DLL Injection Mechanics
kicker: In-Memory Code Execution
panels:
  - { icon: "lucide:syringe", title: Remote Thread Injection, items: ["Open target process with PROCESS_ALL_ACCESS", "VirtualAllocEx allocates RWX memory in target", "WriteProcessMemory copies malicious shellcode", "CreateRemoteThread invokes shellcode entry point"] }
  - { icon: "lucide:ghost", title: Process Hollowing, items: ["Spawn legitimate binary suspended (CREATE_SUSPENDED)", "NtUnmapViewOfSection hollows original code", "Allocate RWX memory and write malicious PE image", "SetThreadContext redirects EIP/RIP to entry & resume"] }
---

<!--
Reference: Endgame Technical Survey - 'Ten Process Injection Techniques: A Technical Survey of Common and Trending Process Injection Techniques':
https://www.endgame.com/blog/technical-blog/ten-process-injection-techniques-technical-survey-common-and-trending-process
-->
`)

// 7. Slide 24: Endless Updates & Breaches (XKCD #1197)
replacements.set(24, `---
layout: two-cols
title: Endless Updates & Breaches
kicker: Practical Forensics
---

::left::

* **The Update Fatigue Paradox**
  * Infinite update chains, popups, and user numbness.
  * Attackers exploit the delay between patch release and enterprise rollout.
* **Transition to Volatile Acquisition**
  * Live triage begins where perimeter defenses failed.
  * Next up: How to seize RAM without corrupting evidence.

::right::

<div class="flex h-full items-center justify-center p-2">
  <div class="bg-white p-3 rounded-xl shadow-2xl border border-slate-700/60 max-w-full">
    <img src="/images/xkcd-adobe-update.png" class="max-h-[380px] w-auto object-contain mx-auto" alt="XKCD #1197" />
  </div>
</div>

<!--
XKCD #1197: https://xkcd.com/1197/
The joke is from 2013, but it’s still pretty good and accurate. There’s no extra hidden meaning of this joke right here; it’s just to give students a short break and relax a bit before diving into acquisition.
-->
`)

// 8. Slide 30: Common Acquisition Challenges
replacements.set(30, `---
layout: panels
title: Common Acquisition Challenges
kicker: Forensic Integrity Roadblocks
panels:
  - { icon: "lucide:activity", title: Heisenberg Footprint, items: ["Running tools on live systems perturbs RAM", "Overwrites unallocated pages & creates processes", "Rule: Minimize footprint; stream output away"] }
  - { icon: "lucide:disc", title: Paging & Disk Swap, items: ["Malware pages may be flushed to pagefile.sys", "Crash dumps miss unmapped process memory", "Both RAM and swap must be preserved"] }
  - { icon: "lucide:key", title: Full-Disk Encryption, items: ["BitLocker/FileVault keys live in volatile memory", "Powering down renders the hard drive inaccessible", "Live capture recovers decrypted volume keys"] }
  - { icon: "lucide:shield-alert", title: Rootkit Anti-Forensics, items: ["Rootkits hook \\\\Device\\\\PhysicalMemory", "Anti-VM routines detect forensic drivers", "Hypervisor snapshots bypass OS tampering"] }
---
`)

// 9. Slide 31: Local Memory Acquisition Best Practices
replacements.set(31, `---
layout: steps
title: Local Acquisition Best Practices
kicker: Golden Rules of Live Capture
steps:
  - { icon: "lucide:shield-check", title: Elevated Drivers, desc: "Direct physical RAM access strictly requires root/admin to load signed kernel drivers (WinPmem, LiME)." }
  - { icon: "lucide:hard-drive-download", title: External Output, desc: "Never write dump files to the system drive! Overwrites deleted files and MFT. Stream to USB or netcat." }
  - { icon: "lucide:cpu", title: Analysis VM Sizing, desc: "Allocate small RAM (2–4 GB) in malware labs for exponentially faster dumps, and disable guest swap." }
---
`)

// 10. Slide 32: Remote Memory Acquisition -> Split into 32a and 32b
replacements.set(32, `---
layout: panels
title: Remote Enterprise Triage
kicker: Acquisition at Scale
panels:
  - { icon: "lucide:globe", title: Global Reach, items: ["Triage endpoints globally without travel", "Minutes from alert to forensic memory image", "Essential for distributed enterprise fleets"] }
  - { icon: "lucide:cpu", title: Pre-allocated Footprint, items: ["Pre-deployed agents avoid new process allocation", "Buffers stay locked to avoid memory corruption", "Runs seamlessly alongside OS scheduling"] }
  - { icon: "lucide:lock", title: Encrypted TLS Stream, items: ["Evidence encrypted in-flight straight to server", "No intermediate evidence footprint on local disk", "Integrity verified via remote cryptographic hashes"] }
---

<!--
Very useful for fast Incident Response across large enterprise fleets without physical travel. Requires enterprise EDR/XDR agents or query frameworks like Velociraptor.
-->

---
layout: default
title: Enterprise Forensics Tooling
kicker: Remote Frameworks
---

Modern enterprise DFIR relies on automated query engines rather than manual live memory dumps:

* **Velociraptor (Rapid7)**
  * Powerful endpoint visibility tool using VQL (Velociraptor Query Language).
  * Direct memory hunting, YARA scanning, and process extraction across 10,000+ hosts simultaneously.
* **Commercial Incident Response Platforms**
  * **Binalyze AIR**: Automated compromise assessments and automated evidence acquisition.
  * **Cloud EDR/XDR**: Live response interactive shells (CrowdStrike, SentinelOne, Defender for Endpoint).
* **Hardware Acquisition Implants**
  * PCIe DMA devices (PCILeech) for physical hardware seizure bypassing OS locks completely.
`)

// 11. Slide 34: Memory Analysis Tool Ecosystem
replacements.set(34, `---
layout: panels
title: Memory Analysis Ecosystem
kicker: Evolution of Forensics Tooling
panels:
  - { icon: "lucide:monitor", title: FireEye Redline, items: ["Free Windows GUI incident response & triage", "Pioneered visual MRI & Time Wrinkles", "Historical benchmark for rapid triage"] }
  - { icon: "lucide:dna", title: HBGary Responder Pro, items: ["Commercial forensic suite by Greg Hoglund", "Invented Digital DNA (DDNA) gene scoring", "Visionary behavioral heuristics pioneer"] }
  - { icon: "lucide:terminal", title: The Volatility Framework, items: ["The global open-source industry standard", "CLI-driven, Python modular architecture", "De facto baseline for all memory research"] }
---
`)

// 12. Slide 35: FireEye Redline & Time Wrinkles
replacements.set(35, `---
layout: two-cols
title: FireEye Redline & "Time Wrinkles"
kicker: Forensic Triage Tools
---

::left::

<div class="flex h-full items-center justify-center p-2">
  <div class="bg-slate-900/90 p-2 rounded-xl border border-white/10 shadow-2xl max-w-full">
    <img src="/images/redline-time-wrinkles.png" class="max-h-[360px] w-auto object-contain mx-auto rounded" alt="Redline Time Wrinkles" />
  </div>
</div>

::right::

* **The "Time Wrinkles" Innovation**
  * Solved timeline analysis by graphing density spikes around incident windows.
  * Clustered forensic events across time to highlight anomalous bursts.
* **Malware Risk Index (MRI)**
  * Automated heuristic risk rating for processes.
* **Why DFIR Moved On**
  * Sluggish on modern multi-GB dumps; Windows-only.
  * Replaced today by **Velociraptor**, **Volatility 3**, and **MemProcFS**.

<!--
Support for macOS and Linux memory artifacts was added in Redline in 2020, but it remains predominantly a Windows-centric triage tool.
-->
`)

// 13. Slide 36: HBGary Responder Pro & Digital DNA
replacements.set(36, `---
layout: two-cols
title: HBGary Responder Pro & Digital DNA
kicker: Forensic Triage Tools
---

::left::

<div class="flex h-full items-center justify-center p-2">
  <div class="bg-slate-900/90 p-2 rounded-xl border border-white/10 shadow-2xl max-w-full">
    <img src="/images/responder-ddna.png" class="max-h-[360px] w-auto object-contain mx-auto rounded" alt="Responder Pro DDNA" />
  </div>
</div>

::right::

* **Behavioral Genotyping in RAM**
  * Pioneered by rootkit researcher **Greg Hoglund** (HBGary).
  * First engine to treat memory forensics as **gene sequencing**.
* **Why DDNA Was Ahead of Its Time**
  * Disassembled unbacked code blocks across all processes.
  * Mapped byte patterns into traits (e.g. *API hashing + raw sockets*).
* **The Modern Void**
  * Today's tools still output raw tables (\`malfind\`, \`netscan\`).
  * Automated composite "gene scoring" remains an industry ideal.

<!--
Obsolete and unavailable for a long time, but it pioneered groundbreaking behavioral heuristics.
Commercial successor / alternative references:
- GoSecure Responder Pro: https://www.gosecure.net/responder-pro
- CounterTack DDNA SC Magazine Overview: https://cdn2.hubspot.net/hubfs/150964/CounterTack_DDNA_SCMagazine_030117-1.pdf
-->
`)

// 14. Slide 40: The Volatility Framework -> Split into 40a and 40b
replacements.set(40, `---
layout: default
title: The Volatility Framework
kicker: Open Source Forensics Standard
---

The de facto open-source standard for volatile memory extraction and analysis:

* **Open Architecture**: 100% Python-based, cross-platform, modular plugin pipeline.
* **Symbol-Driven Reconstruction**: Resolves OS structures directly from symbol tables (PDB / DWARF / JSON ISF).
* **Comprehensive Footprint**: Decodes processes, threads, network sockets, drivers, security tokens, clipboard, registry hives, and mutexes.

<Callout tone="info" icon="lucide:terminal" class="mt-6">
  <strong>Dual Toolchain Available in Lab:</strong><br/>
  Use <code>vol</code> (Volatility 2) for legacy Windows XP artifacts (e.g. raw UDP scans, <code>dnscache</code>) and <code>vol3</code> (Volatility 3) for modern 64-bit triage with automated symbol downloading.
</Callout>

---
layout: vs
title: Volatility 2 vs. Volatility 3
kicker: Framework Evolution
left:
  title: Volatility 2 (Legacy)
  items:
    - Python 2.7 runtime (end-of-life)
    - "Rigid OS profile strings: WinXPSP2x86"
    - "Deep legacy socket carving: connscan, sockets"
    - CLI command: vol
right:
  title: Volatility 3 (Modern)
  items:
    - Modern Python 3 modular codebase
    - "Dynamic symbols: automated Microsoft PDB / ISF"
    - Unified single codebase across Win/Linux/Mac
    - CLI command: vol3
---
`)

// 15. Slide 45: What to Search for in Volatile Memory?
replacements.set(45, `---
layout: panels
title: "What to Hunt for in Volatile Memory?"
kicker: Forensic Artifact Checklist
panels:
  - { icon: "lucide:cpu", title: Process Anomalies, items: ["Hidden / unlinked processes (DKOM)", "Non-standard parent-child trees", "Hollowed code & injected DLLs (malfind)"] }
  - { icon: "lucide:wifi", title: Network Connections, items: ["Active C2 beacons & sockets", "Raw listening UDP/TCP ports", "In-memory DNS cache resolution"] }
  - { icon: "lucide:clock", title: Execution & History, items: ["Prefetch records & Shimcache", "Console history buffers (cmdscan)", "In-memory registry hives & run keys"] }
  - { icon: "lucide:key", title: In-Memory Secrets, items: ["Malware infection mutexes", "Decrypted heap configs & webinjects", "Plaintext tokens, LSASS keys & certificates"] }
---
`)

// 16. Slide 48: Spotting Process Masquerading & Anomalies
replacements.set(48, `---
layout: panels
title: "Spotting Process Masquerading"
kicker: Threat Hunting Checklist
panels:
  - { icon: "lucide:git-branch", title: Parentage Violations, items: ["svchost spawned by explorer or cmd (must be services.exe)", "lsass spawned by anything other than wininit", "cmd or powershell spawned by wordpad or spoolsv"] }
  - { icon: "lucide:folder-x", title: Path & Name Squatting, items: ["System binaries outside System32 (e.g. AppData, Temp)", "Typo-squatted names: scvhost.exe, lsas.exe, csrs.exe", "Case anomalies or leading/trailing whitespace"] }
  - { icon: "lucide:hash", title: Instance Counts & CLI, items: ["Singletons: Exactly ONE wininit, services, and lsass", "Two lsass processes = guaranteed active implant!", "svchost without '-k <group>' flag is an impostor"] }
  - { icon: "lucide:shield-alert", title: Memory & VAD Clues, items: ["Process hollowing: legitimate path, malicious VAD", "Unbacked executable memory pages (PAGE_EXECUTE_RW)", "Hunt via Volatility's malfind and ldrmodules"] }
---
`)

// 17. Slide 56: Lab Environment & Requirements
replacements.set(56, `---
layout: panels
title: Lab Environment & Tooling
kicker: Practical Setup
panels:
  - { icon: "lucide:box", title: Virtualization, items: ["VirtualBox or Docker Compose (Linux, Mac, Windows)", "Native multi-arch support (x86_64 & ARM64 Apple Silicon)", "Pre-provisioned forensics environment"] }
  - { icon: "lucide:terminal", title: Core Toolchain, items: ["Volatility 2.7 (vol) & Volatility 3 (vol3)", "Carving & triage: foremost, strings, yara, suricata", "Office/OLE triage: oletools, rtfobj, peepdf"] }
  - { icon: "lucide:file-text", title: Evidence & Reports, items: ["5 real-world malware memory images preloaded", "Complete reference report in report/report.md", "Automated lab launchers: exercise 1 to 5"] }
---
`)

// 18. Exercises 1 to 5 (Slides 58-62)
replacements.set(58, `---
layout: two-cols
title: "Exercise 1: xp-infected.vmem"
kicker: Hands-on Lab 1
---

::left::

<Terminal title="Lab Terminal" class="mb-4">
exercise 1
</Terminal>

* **Sample**: \`xp-infected.vmem\`
* **OS**: Windows XP SP2/SP3 x86
* **Key Tools**:
  * Volatility 2 (\`vol\`)
  * \`strings\`, \`rtfobj\`, \`yara\`

<Callout tone="info" icon="lucide:book-open" class="mt-4 text-xs">
  See <code>report/report.md</code> for the complete reference forensic report!
</Callout>

::right::

### Mission Objectives

<v-clicks>

1. **Profile**: Detect OS profile and acquisition timestamp (\`imageinfo\`).
2. **Lineage**: Spot abnormal parentage (\`cmd\`, \`wordpad\`, \`win32dd\`).
3. **Dropper**: Identify the terminated dropper process (PID \`1204\`).
4. **C2 Beacon**: Find the C2 IP, resolved domain, and UDP socket.
5. **Decoy Carving**: Carve dropped document and reveal true format.
6. **Signatures**: Write functional YARA and Suricata detection rules.

</v-clicks>
`)

replacements.set(59, `---
layout: default
title: "Exercise 2: win7_x64.vmem"
kicker: Hands-on Lab 2 · 64-bit Architecture
---

<Terminal title="Lab Terminal" class="mb-4">
exercise 2
</Terminal>

* **Architecture Transition**: Analyze a 64-bit Windows 7 SP1 memory capture with 8-byte pointers.
* **Modern Network Objects**: Use \`netscan\` instead of legacy \`connscan\` to identify TCP/UDP endpoints.
* **Privilege Inspection**: Audit process tokens with \`privs\` to detect elevated privileges (\`SeDebugPrivilege\`).
* **Code Injection**: Hunt unbacked executable memory regions (\`PAGE_EXECUTE_READWRITE\`) with \`malfind\`.
`)

replacements.set(60, `---
layout: two-cols
title: "Exercise 3: zeus.vmem"
kicker: Hands-on Lab 3
---

::left::

<Terminal title="Lab Terminal" class="mb-4">
exercise 3
</Terminal>

* **Sample**: \`zeus.vmem\`
* **Threat**: Zeus (Zbot) Banking Trojan
* **Key Tools**:
  * Volatility 2 (\`vol\`)

<Callout tone="warn" icon="lucide:shield-alert" class="mt-4 text-xs">
  Zeus hollows legitimate system processes to steal online banking credentials.
</Callout>

::right::

### Mission Objectives

<v-clicks>

1. **Triage**: Profile and identify the active Zeus banking infection.
2. **C2 Telemetry**: Map malicious network connections and remote ports.
3. **Injection Target**: Identify which legitimate process was hollowed.
4. **Mutex Marker**: Extract the hardcoded infection mutex used by Zeus.

</v-clicks>
`)

replacements.set(61, `---
layout: default
title: "Exercise 4: zeus2x4.vmem"
kicker: Hands-on Lab 4 · In-Memory Payload Unpacking
---

<Terminal title="Lab Terminal" class="mb-4">
exercise 4
</Terminal>

* **Advanced Zeus Variant**: Analyze multi-stage banking trojan evasions.
* **Network Correlation**: Identify the hollowed process maintaining active C2 beacon channels.
* **Payload Carving**: Dump injected memory segments and weaponized DLLs using \`dlldump\` / \`memdump\`.
* **Heap Config Decryption**: Carve decrypted C2 configuration strings and banking webinjects from RAM!
`)

replacements.set(62, `---
layout: two-cols
title: "Exercise 5: bob.vmem"
kicker: Hands-on Lab 5
---

::left::

<Terminal title="Lab Terminal" class="mb-4">
exercise 5
</Terminal>

* **Sample**: \`bob.vmem\`
* **Scenario**: Compromised workstation ("Uncle Bob")
* **Key Tools**:
  * Volatility 2, Foremost, Strings, Oletools

<Callout tone="info" icon="lucide:user-x" class="mt-4 text-xs">
  Full attack reconstruction: From phishing document to root exploit.
</Callout>

::right::

### Mission Objectives

<v-clicks>

1. **Activity Reconstruction**: Trace Uncle Bob's actions before infection.
2. **Infection Vector**: Identify which application and file caused compromise.
3. **File Carving**: Extract the weaponized file from cache/memory.
4. **Vulnerability (CVE)**: Identify the exact CVE exploited by the attacker.

</v-clicks>
`)

// Process backwards so earlier indices don't shift
let replacedCount = 0
for (let i = data.slides.length - 1; i >= 0; i--) {
  if (replacements.has(i)) {
    const s = data.slides[i]
    const newText = replacements.get(i).trim()
    const newLines = newText.split('\n')
    // Preserve trailing newline if needed
    lines.splice(s.start, s.end - s.start, ...newLines)
    replacedCount++
    console.log(`Replaced slide [${i}] (lines ${s.start}-${s.end})`)
  }
}

console.log(`Total replaced: ${replacedCount} slides.`)
const result = lines.join('\n')
const outPath = process.argv[2] || 'slides.md'
writeFileSync(outPath, result, 'utf-8')
console.log(`Wrote redesigned presentation to ${outPath}`)
