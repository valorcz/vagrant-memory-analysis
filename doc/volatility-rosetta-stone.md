# Volatility 2 vs. Volatility 3: The Forensic Rosetta Stone

This reference guide provides a side-by-side mapping between **Volatility 2** (`vol`) and **Volatility 3** (`vol3`), detailing syntax differences, plugin availability, and why both versions are included in this lab environment.

---

## 1. Architectural Differences: Profiles vs. Symbol Tables

| Feature | Volatility 2 (`vol`) | Volatility 3 (`vol3`) |
| :--- | :--- | :--- |
| **Runtime Environment** | Python 2.7 | Python 3.10+ |
| **Kernel Structure Knowledge** | Static OS profiles (`--profile=WinXPSP3x86`, `Win7SP1x64`, etc.) | Dynamic Intermediate Symbol Format (ISF) JSON tables downloaded via PDB GUIDs |
| **Speed & Concurrency** | Single-threaded linear scanning | Multi-threaded memory layer translation |
| **Command Syntax** | `vol -f <image> --profile=<prof> <plugin>` | `vol3 -f <image> <os>.<plugin>` |
| **Legacy OS Support (Win XP / 2003)** | **Native & Comprehensive** | Partial (core processes only; legacy network stack unsupported) |
| **Modern OS Support (Win 10 / 11)** | Deprecated / manual profile generation | **First-class & actively maintained** |

---

## 2. Command Reference: Side-by-Side Mapping

### A. Image Identification & Architecture
| Forensics Task | Volatility 2 | Volatility 3 | Notes |
| :--- | :--- | :--- | :--- |
| **Identify OS & Suggested Profile** | `vol -f <img.vmem> imageinfo` | `vol3 -f <img.vmem> windows.info` | Vol3 automatically resolves symbols without guessing profiles. |
| **Scan for Kernel Debugger Block (KDBG)** | `vol -f <img.vmem> kdbgscan` | *(Built into layer scanning)* | In Vol2, useful when `imageinfo` gives ambiguous profiles. |

---

### B. Process & Thread Triage
| Forensics Task | Volatility 2 | Volatility 3 | Notes |
| :--- | :--- | :--- | :--- |
| **Active Process List** | `vol -f <img.vmem> pslist` | `vol3 -f <img.vmem> windows.pslist` | Walks the active process list (`ActiveProcessLinks`). |
| **Process Tree Hierarchy** | `vol -f <img.vmem> pstree` | `vol3 -f <img.vmem> windows.pstree` | Visualizes parent/child PID relationships. |
| **Scan for Unlinked Processes** | `vol -f <img.vmem> psscan` | `vol3 -f <img.vmem> windows.psscan` | Scans physical memory for `EPROCESS` pool tags (detects DKOM). |
| **Cross-View Process Verification** | `vol -f <img.vmem> psxview` | *(No direct equivalent; run `psscan`)* | Vol2 cross-references 8 sources (CSRSS, PspCidTable, threads). |
| **Command Line Arguments** | `vol -f <img.vmem> cmdline` | `vol3 -f <img.vmem> windows.cmdline` | Parses the Process Environment Block (`PEB->ProcessParameters`). |
| **Console / Command History** | `vol -f <img.vmem> consoles` | *(No core Vol3 plugin; requires 3rd-party)* | Extracts executed commands from `conhost.exe` / `csrss.exe` buffers. |
| **Process Environment Variables** | `vol -f <img.vmem> envars` | `vol3 -f <img.vmem> windows.envars` | Inspects environment variables (paths, temp dirs, usernames). |

---

### C. In-Memory Code Injection & Binary Analysis
| Forensics Task | Volatility 2 | Volatility 3 | Notes |
| :--- | :--- | :--- | :--- |
| **Detect Code Injection / Hollowed Memory** | `vol -f <img.vmem> malfind` | `vol3 -f <img.vmem> windows.malfind` | Scans for memory pages with `PAGE_EXECUTE_READWRITE` not backed by disk. |
| **Dump Injected VAD Segments** | `vol -f <img.vmem> malfind -D dump/` | `vol3 -f <img.vmem> windows.malfind --dump` | Dumps suspected shellcode or injected PEs to disk. |
| **Detect Unlinked DLLs** | `vol -f <img.vmem> ldrmodules` | `vol3 -f <img.vmem> windows.ldrmodules` | Checks PEB loaded module lists (`InLoadOrder`, `InMemoryOrder`, `InInitOrder`). |
| **Loaded Modules / DLLs** | `vol -f <img.vmem> dlllist` | `vol3 -f <img.vmem> windows.dlllist` | Lists all mapped DLLs for active processes. |
| **Scan Loaded Kernel Drivers** | `vol -f <img.vmem> modules` | `vol3 -f <img.vmem> windows.modules` | Identifies third-party or malicious kernel drivers. |

---

### D. Network Artifacts
| Forensics Task | Volatility 2 | Volatility 3 | Critical Notes |
| :--- | :--- | :--- | :--- |
| **Legacy Windows XP/2003 Connections** | `vol -f <img.vmem> connections` | ❌ *Not supported in Vol3* | Vol3 does not support the legacy Windows XP TCP/IP driver tables. |
| **Legacy Windows XP Connection Scan** | `vol -f <img.vmem> connscan` | ❌ *Not supported in Vol3* | Scans memory for residual closed/terminated XP TCP connections. |
| **Legacy Windows XP Sockets** | `vol -f <img.vmem> sockets` / `sockscan` | ❌ *Not supported in Vol3* | Identifies listening UDP and TCP sockets on Windows XP. |
| **Modern Network Scan (Vista, 7, 10, 11)** | `vol -f <img.vmem> netscan` | `vol3 -f <img.vmem> windows.netscan` | Scans modern Windows network objects (TCP endpoints, listeners). |
| **Network Sockets Status** | `vol -f <img.vmem> netscan` | `vol3 -f <img.vmem> windows.netstat` | Displays network connection state table. |

---

### E. File Extraction & Artifact Carving
| Forensics Task | Volatility 2 | Volatility 3 | Notes |
| :--- | :--- | :--- | :--- |
| **Scan Memory for Cached Files** | `vol -f <img.vmem> filescan` | `vol3 -f <img.vmem> windows.filescan` | Scans for `FILE_OBJECT` structures in memory. |
| **Extract Cached Files by Offset** | `vol -f <img.vmem> dumpfiles -Q <physoffset> -D <dir>` | `vol3 -f <img.vmem> windows.dumpfiles --virtaddr <virtoffset>` | Dumps file cached data from memory to disk. |
| **Dump Process Executable (PE)** | `vol -f <img.vmem> procdump -p <pid> -D <dir>` | `vol3 -f <img.vmem> windows.dumpfiles --pid <pid>` | Reconstructs executable image from memory. |
| **Dump Full Process Address Space** | `vol -f <img.vmem> memdump -p <pid> -D <dir>` | `vol3 -f <img.vmem> windows.memmap --pid <pid> --dump` | Raw memory dump of the entire process space. |

---

### F. Registry, Privileges, and Specialty Artifacts
| Forensics Task | Volatility 2 | Volatility 3 | Notes |
| :--- | :--- | :--- | :--- |
| **List Registry Hives** | `vol -f <img.vmem> hivelist` | `vol3 -f <img.vmem> windows.registry.hivelist` | Finds memory addresses of active registry hives. |
| **Print Registry Key / Values** | `vol -f <img.vmem> printkey -K "<KeyPath>"` | `vol3 -f <img.vmem> windows.registry.printkey --key "<KeyPath>"` | Reads registry keys directly from memory. |
| **UserAssist (Executed Programs)** | `vol -f <img.vmem> userassist` | `vol3 -f <img.vmem> windows.registry.userassist` | Decodes ROT13 execution history from NTUSER.DAT. |
| **Process Token Privileges** | `vol -f <img.vmem> privs` | `vol3 -f <img.vmem> windows.privileges` | Checks privileges (e.g. `SeDebugPrivilege`). |
| **Dump Password Hashes (SAM)** | `vol -f <img.vmem> hashdump` | `vol3 -f <img.vmem> windows.hashdump` | Extracts local user NTLM/LM password hashes. |
| **Dump LSA Secrets** | `vol -f <img.vmem> lsadump` | `vol3 -f <img.vmem> windows.cachedump` / `lsadump` | Extracts cached domain credentials. |

---

## 3. Why Volatility 2 Remains Essential for This Lab

Students often ask: *"Why are we using Volatility 2 when Volatility 3 is newer?"*

1. **Legacy Network Stack in Windows XP**:
   - In Exercise 1 (`xp-infected.vmem`), the infection involves a terminated process (PID `1204`) connecting over port 80, and `svchost.exe` listening on port `1031/udp`.
   - Volatility 3 **cannot parse Windows XP TCP/IP connection structures** (`connscan`, `sockets`). Running `windows.netscan` in Volatility 3 against Windows XP dumps will return an error because the Vista+ network architecture (`netio.sys`) is absent.
2. **Community Plugin Availability**:
   - `dnscache`: The DNS resolution cache plugin (`plugins/dnscache.py`) is written for Volatility 2 and parses `dnsrslvr.dll` memory to reveal resolved C2 domains (`mialepromo.ru`).
   - `prefetchparser`: The prefetch parser (`plugins/prefetch.py`) extracts past execution records (`POST_EXPRESS_LABEL.EXE`) directly from XP memory cache.
3. **When to Switch to Volatility 3**:
   - For **Exercise 2 (`win7_x64.vmem`)** and **Exercise 4 (`emotetvictim.vmem`)**, Volatility 3 is fully equipped. You can use `vol3 windows.pslist`, `windows.pstree`, `windows.netscan`, and `windows.malfind` with high performance and automatic symbol resolution!
