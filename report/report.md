# PV204: Sample Analysis Report

This is a sample report describing analysis of `xp-infected.vmem` memory image
(i.e. `exercise01`). We'll demonstrate both the structure of the report and one
of the possible analysis workflows you could use for your own research/work.

## Sample Preparation

Before we start with the analysis, we need to download the memory image. That
can be done via `exercise 1` command issued on the VM command line (see
[the official course documentation][pv204-workshop] for more details).

```bash
~$ exercise 1
Downloading exercise01 image: xp-infected.vmem...
######################################################################## 100.0%
Extracting the image...
  /home/vagrant/images/exercise01/xp-infected.vmem.bz2: done
```

## Image Identification

Every memory analysis should start with proper identification of the provided
memory image.

Let's do it:

```bash
exercise01$ vol -f xp-infected imageinfo
```

Which results in:
```
          Suggested Profile(s) : WinXPSP2x86, WinXPSP3x86 (Instantiated with WinXPSP2x86)
                     AS Layer1 : IA32PagedMemoryPae (Kernel AS)
                     AS Layer2 : FileAddressSpace (/home/vagrant/images/exercise01/xp-infected.vmem)
                      PAE type : PAE
                           DTB : 0x2b0000L
                          KDBG : 0x80545ae0L
          Number of Processors : 1
     Image Type (Service Pack) : 3
                KPCR for CPU 0 : 0xffdff000L
             KUSER_SHARED_DATA : 0xffdf0000L
           Image date and time : 2011-04-10 21:29:25 UTC+0000
     Image local date and time : 2011-04-10 14:29:25 -0700
```

We'll be dealing with WinXP image, Service Pack 3, running on `x86` platform.

### Image Summary

| Information | Value              | Comment |
| ----------- | ------------------ | ------- |
| Filename    | `xp-infected.vmem` |  n/a    |
| MD5         | `927ce822c7f2c1cf3265c1d5b03281a4` | MD5 sum of the provided image |
| SHA1        | `89998cc2704436a8842cd224e3c34e02907c7cd7` | SHA1 sum of the provided image |
| OS          | Windows XP, Service Pack 3 | Image was created on `2011-04-10 21:29:25 UTC` |
| Image Timezone | `-0700` | This could be a PDT/PST or anything US west-coast. Not that important for Windows OS though, as it uses UTC internally everywhere. Very wise! |

## Processes

```bash
exercise01$ vol -f xp-infected.vmem pslist
```

returns a list of processes, among which some immediately raise questions -- especially
`cmd.exe` and `win32dd.exe`:

```
0x022d3c10 cmd.exe                 972 True   True   True     True   True  True    True
0x0216d228 win32dd.exe            1120 True   True   True     True   True  True    True
```

> **Forensic Note (The "Heisenberg Effect" in Memory Acquisition):**
> Notice `win32dd.exe` running under `cmd.exe`. In digital forensics, the acquisition
> tool inevitably modifies the state of the target system when capturing live memory.
> Here, `win32dd.exe` is MoonSols Win32dd—a popular physical memory acquisition tool
> used by incident responders. Its presence confirms that an investigator acquired
> the memory dump interactively from the command line.

Before we proceed with further steps though, we can review other Volatility
commands outputs to either gain more confidence in our hypothesis, or correct
it if needed.

```bash
exercise01$ vol -f xp-infected.vmem psxview
```

doesn't reveal hidden/unlinked processes (DKOM).

```bash
exercise01$ vol -f xp-infected.vmem pstree
```

however suggests that `WORDPAD.EXE` doesn't have an active parent (the parent process
`1204` has already terminated), leaving it orphaned:

```
 0x82088a78:WORDPAD.EXE                               320   1204      2     98 2011-04-10 21:08:40 UTC+0000
...
. 0x820d3c10:cmd.exe                                  972   1956      1     33 2011-04-10 21:28:24 UTC+0000
.. 0x81f6d228:win32dd.exe                            1120    972      1     22 2011-04-10 21:29:24 UTC+0000
```

`pstree` also confirms that `win32dd.exe` was executed from `cmd.exe` during memory acquisition.

We can also verify whether any process contains injected code or unmapped executable
allocations (`PAGE_EXECUTE_READWRITE`) using `malfind`:

```bash
exercise01$ vol -f xp-infected.vmem malfind
```

### Brief Processes Summary

We have identified the following noteworthy processes so far:

| Process Name   | ProcessID   | ParentProcessID | Description            |
| -------------- | ----------: | --------------: | ---------------------- |
| `WORDPAD.EXE`  | `320`       |          `1204` | Word editor displaying decoy document |
| `cmd.exe`      | `972`       |          `1956` | Command-line used by incident responder |
| `win32dd.exe`  | `1120`      |           `972` | MoonSols memory acquisition tool (responder artifact) |
| \<unknown\>    | `1204`      |             n/a | Terminated dropper process that spawned `WORDPAD.EXE` |

## Network Communication

Before we proceed further with the process analysis, we could collect some
additional evidence from the system. One very common source of information
about malware, botnets, etc., could be acquired from network communication.

> **INFO:** Network plugin names differ, based on the original
> operating system. For Windows XP images, you can use `connections`,
> `connscan`, `sockets` and `sockscan` commands.

```bash
exercise01$ vol -f xp-infected.vmem connections
```

returns an empty set of connections, which means that there were no active
connections registered by kernel when the memory image was acquired.

```bash
exercise01$ vol -f xp-infected.vmem connscan
```

`connscan` command, however, reveals some useful hints as to what was happening
in the system in the (recent) past:

```
Offset(P)  Local Address             Remote Address            Pid
---------- ------------------------- ------------------------- ---
0x02350cd8 192.168.1.32:1044         91.199.75.77:80           1204
0x024b8838 192.168.1.32:1047         192.168.1.150:139         4
```

First, we can see our mysterious unknown process with PID `1204` communicating
with `91.199.75.77` over HTTP port. Second, a system call over Windows SMB port,
which is most likely legit.

We can also investigate ports that were being handled by some of the running
processes. For that reason, `sockets` or `sockscan` commands could be used:

```
vol -f xp-infected.vmem sockets
```

From the whole listing, we can note down the following line:
```
Offset(V)       PID   Port  Proto Protocol        Address         Create Time
---------- -------- ------ ------ --------------- --------------- -----------
0x8214a620     1056   1031     17 UDP             0.0.0.0         2011-04-10 21:08:37 UTC+0000
```
informing us that a process `1056` (`svchost.exe`) has been listening on port
`1031/udp`.

### WHOIS Lookup

Let's check whether the WHOIS lookup reveals anything. However, we need to
take the information with a grain of salt — the image was taken in 2011,
the incident is now 9 years old, the information about network assignments
can change. Last but not least, botnets and malware can re-use networks and
computers that were infected in the past.

```bash
organisation:   ORG-HLGH1-RIPE
org-name:       Hessische Landesbahn GmbH
org-type:       OTHER
address:        DE 60325 Frankfurt am Main Am Erlenstrasse 2
abuse-c:        AR26935-RIPE
mnt-ref:        ARCOR-MNT
mnt-by:         ARCOR-MNT
mnt-by:         HLB-00
created:        2011-02-17T09:36:45Z
last-modified:  2020-03-05T07:50:41Z
source:         RIPE # Filtered
```

### DNS Cache

If we are lucky enough, the IP used by the malware was a result of a DNS
resolution process; that'd allow us to search for the actual domain used
in the network communication and prepare better signatures (or network
protections).

The DNS cache is just another structure in OS memory, thus we could search for
it. `volatility` doesn't provide the DNS cache search functionality by default,
but the setup we have in VM now does (I used the
[dnscache plugin][dnscache-plugin], fixed some of the issues I found, and made
it available as a part of the VM now).

So, let's give it a try!

> **INFO:** The plugin requires a folder for some temporary
> downloads, so we need to create it first, and pass the path to the plugin.

```
exercise01$ mkdir dnsdump
exercise01$ vol -f xp-infected.vmem dnscache --dump_dir dnsdump/
```

It'll take a moment and we'll learn some extra piece of info about the image!

```
Offset             Name                                                                  TTL Type   Value
------------------ ---------------------------------------------------------------- -------- ------ -----

0x0000000000742278 mialepromo.ru                                                             HASH   0xb2158
0x00000000000b2158 mialepromo.ru                                                       14538 A      91.199.75.77
0x00000000000b27c0                                                                     14538 A      91.199.75.14
-------------------------
PID: 1056, DLL: c:\windows\system32\dnsrslvr.dll
```

What's the new info? We found a domain the malware was trying to communicate
with --- `mialepromo.ru`. Also, we identified another IP that could potentially
be used for the network traffic --- `91.199.75.14`. Cool stuff!

### Brief Network Summary

| Process Name   | ProcessID | Details           | Comment                |
| -------------- | --------: | ----------------: | ---------------------- |
| \<unknown\>    |    `1204` | `91.199.75.77:80` | unknown parent process, most likely downloading stuff from Internet |
| `svchost.exe`  |    `1056` |        `1031/udp` | a (system?) service listening on an UDP port |
| `svchost.exe`  |    `1056` |    `mialepromo.ru` + `91.199.75.14` | This process tried to resolve some unexpected, potentially malicious DNS domains, and it resolved an alternate IP for the domain. |

We can probably start constructing a preliminary hypothesis:

> A process `1204` communicated with the Internet, downloaded something (most
> likely a .DOC or .RTF document among other things) and started the
> `wordpad.exe` process. It's possible that it started another service
> listening on `1031/udp` port. Also, the newly started service may have been
> actively participating in the communication with a suspicious domain,
> `mialepromo.ru`.

## Files Analysis

```bash
exercise01$ vol -f xp-infected.vmem dumpfiles -D dump -Q 0x00000000024a5840
```

The command `dumpfiles` extracts the cached memory file object to our output directory:

```
DataSectionObject 0x024a5840   None   \Device\HarddiskVolume1\DOCUME~1\unclebob\Desktop\document.doc
```

Volatility extracts this object as `dump/file.None.0x824a5840.dat`. We can check its integrity and type using standard Linux tools:

```bash
exercise01$ file dump/file.None.0x824a5840.dat
dump/file.None.0x824a5840.dat: Rich Text Format data, version 1, ANSI

exercise01$ md5sum dump/file.None.0x824a5840.dat
dae329b01159385eef29f6d1416f2f27  dump/file.None.0x824a5840.dat
```

Even though named `document.doc` on `unclebob`'s Desktop, the magic bytes reveal it is actually an **RTF** (Rich Text Format) file. We can examine it further with `rtfobj` (part of the pre-installed `oletools` package):

```bash
exercise01$ rtfobj dump/file.None.0x824a5840.dat
```

`rtfobj` reveals embedded exploit objects (consistent with known RTF parser vulnerabilities such as CVE-2010-3333). When opened, the file displays a decoy text in Wordpad while the dropper executes payload code in the background.

## Forensic Analysis

### Prefetch Files

Analysts familiar with Windows XP internals know that there's a mechanism
built in Windows XP to speed up loading of executables. It's called _"prefetch"_
and good thing about it is that it can help with discovery of processes executed
in the past, with some extra details.

The Volatility plugin we are about to use is another "extra" plugin, not available
in the default Volatility distro. It can be found at [github repository][prefetchparser].
Good news is that it doesn't require any fixing or updates :)

```bash
exercise01$ vol -f xp-infected.vmem prefetchparser
```

will provide us with some super-useful extra information -- we've found a new
unexpected executable name!

```
Prefetch File                              Execution Time               Times Size
------------------------------------------ ---------------------------- ----- --------
POST_EXPRESS_LABEL.EXE-1FE60565.pf         2011-04-10 21:08:32 UTC+0000     1    17530
```

### Strings Analysis

Rather than running `strings` indiscriminately over the entire multi-gigabyte dump, we can perform targeted extraction targeting Unicode (16-bit little endian, `-e l`) and ASCII strings associated with our discovered indicators:

```bash
exercise01$ strings -a -e l xp-infected.vmem | grep -i "mialepromo"
http://mialepromo.ru/load.php?id=...
```

Inspecting the surrounding memory reveals HTTP request headers:

```http
GET /load.php?id=... HTTP/1.1
Accept: */*
User-Agent: Our_Agent
Host: mialepromo.ru
Cache-Control: no-cache
```

This confirms that the downloader client used a hardcoded, non-standard HTTP header `User-Agent: Our_Agent`.

## Final Hypothesis

Based on the correlated memory artifacts, the incident unfolded as follows:

1. **Initial Vector**: The victim user (`unclebob`) received and executed an executable named `POST_EXPRESS_LABEL.EXE` (likely masquerading as a postal delivery notification).
2. **Decoy & Dropping**: At `21:08:32 UTC`, `POST_EXPRESS_LABEL.EXE` executed. It dropped a decoy file `document.doc` onto the desktop (`C:\Documents and Settings\unclebob\Desktop\document.doc`) and spawned `WORDPAD.EXE` (PID 320) at `21:08:40 UTC` to distract the victim.
3. **C2 Resolution & Download**: The dropper process (PID 1204) queried DNS for `mialepromo.ru` (cached as `91.199.75.77` and `91.199.75.14`) and established an HTTP connection to download secondary malware payloads using `User-Agent: Our_Agent`. Having completed its routine, PID 1204 exited, leaving `WORDPAD.EXE` orphaned without an active parent process.
4. **Backdoor Persistence**: Concurrently, at `21:08:37 UTC`, a service process (`svchost.exe`, PID 1056) opened a listening socket on `1031/udp`, likely serving as a remote backdoor or botnet control channel.
5. **Memory Acquisition**: At `21:28:24 UTC`, an investigator opened `cmd.exe` (PID 972) and ran `win32dd.exe` (PID 1120) at `21:29:24 UTC` to dump volatile memory, completing the capture at `21:29:25 UTC`.

### Timeline

| Timestamp (UTC)      | Information                                            |
| -------------------  | ------------------------------------------------------ |
| `2011-04-10 21:08:32`| Prefetch record for `POST_EXPRESS_LABEL.EXE` created (malware execution). |
| `2011-04-10 21:08:37`| `svchost.exe (1056)` started listening on `1031/udp`.   |
| `2011-04-10 21:08:40`| `WORDPAD.EXE (320)` started to display decoy document.  |
| `2011-04-10 21:28:24`| `cmd.exe (972)` launched by incident responder.        |
| `2011-04-10 21:29:24`| `win32dd.exe (1120)` executed to capture RAM dump.      |
| `2011-04-10 21:29:25`| Memory image acquisition completed.                   |

### Indicators

| IndicatorType  | Value                              | Comment                                    |
| -------------- | ---------------------------------- | -------------------------------------------------- |
| `ip-address`   |                    `91.199.75.77`  | Used for downloading various stages of the malware. |  
| `ip-address`   |                    `91.199.75.14`  | Alternate IP resolved for malicious domain. |
| `domain`       |                    `mialepromo.ru` | C2 domain used for payload staging. |
| `user-agent`   |                        `Our_Agent` | Custom User-Agent header used in HTTP requests. |
| `filename`     |           `POST_EXPRESS_LABEL.EXE` | Original malicious executable name. |
| `md5`          | `dae329b01159385eef29f6d1416f2f27` | Decoy RTF document dropped by malware. |

### Signatures

#### Yara Signatures

For triage across memory dumps and raw disk files, we prepared the following YARA rules:

```yara
rule pv204_suspicious_domain {
  meta:
    description = "Detects mialepromo.ru C2 domain in process memory"
    author = "Vasek Lorenc"
    date = "2020-04-29"
    reference = "PV204 exercise01"
  strings:
    $domain = "mialepromo.ru" ascii wide nocase
  condition:
    $domain
}

rule pv204_suspicious_agent {
  meta:
    description = "Detects Our_Agent malware User-Agent header"
    author = "Vasek Lorenc"
    date = "2020-04-29"
    reference = "PV204 exercise01"
  strings:
    $ua = "Our_Agent" ascii wide nocase
  condition:
    $ua
}
```

#### Suricata Signatures

Signatures for monitoring malicious DNS resolution and HTTP communications:

```suricata
# Detect DNS query for the C2 domain
alert dns $HOME_NET any -> any 53 (msg:"PV204 - Suspicious DNS Query to mialepromo.ru"; dns.query; content:"mialepromo.ru"; nocase; endswith; reference:url,https://github.com/valorcz/vagrant-memory-analysis; classtype:trojan-activity; sid:1000001; rev:1;)

# Detect HTTP traffic with malware-specific User-Agent
alert http $HOME_NET any -> $EXTERNAL_NET any (msg:"PV204 - Suspicious User-Agent (Our_Agent)"; flow:established,to_server; http.user_agent; content:"Our_Agent"; depth:9; reference:url,https://github.com/valorcz/vagrant-memory-analysis; classtype:trojan-activity; sid:1000002; rev:1;)
```

# Further Reading

* [Volatility 2 vs. Volatility 3 Forensic Rosetta Stone](../doc/volatility-rosetta-stone.md)
* [PV204 Workshop Documentation][pv204-workshop]
* [dnscache Plugin Repository][dnscache-plugin]
* [prefetchparser Plugin Repository][prefetchparser]

[pv204-workshop]: https://github.com/valorcz/vagrant-memory-analysis/blob/master/README.md
[dnscache-plugin]: https://github.com/mnemonic-no/dnscache
[prefetchparser]: https://github.com/superponible/volatility-plugins
