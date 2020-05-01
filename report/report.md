# PV204: Sample Analysis Report

This is a sample report describing analysis of `xp-infected.vmem` memory image
(i.e. `exercise01`). We'll demonstrate both the structure of the report and one
of the possible analysis workflows you could use for your own research/work.

## Sample Preparation

Before we start with the analysis, we need to download the memory image. That
can be done via `exercise 1` command issued on the VM command line (see [the
official course documentation][pv204-workshop] for more details).

## Image Identification

Every memory analysis should start with proper identification of the provided
memory image. Let's do it:

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

## Processes

```bash
exercise01$ vol -f xp-infected.vmem pslist
```

returns a list of processes, which some could be raising concerns -- especially
`cmd.exe` and `wind32dd.exe`.

```
0x022d3c10 cmd.exe                 972 True   True   True     True   True  True    True
0x0216d228 win32dd.exe            1120 True   True   True     True   True  True    True
```

Before we proceed with further steps though, we can review other Volatility
commands outputs to either gain more confidence in our hypothesis, or correct
it if needed.

```bash
exercise01$ vol -f xp-infected.vmem psxview
```

doesn't reveal anything new or suspicious.

```bash
exercise01$ vol -f xp-infected.vmem pstree
```

however suggests that `WORDPAD.EXE` doesn't have any parent (the parent process
has either terminated or something else has happened), so we have no idea
how it was started.

```
 0x82088a78:WORDPAD.EXE                               320   1204      2     98 2011-04-10 21:08:40 UTC+0000
...
. 0x820d3c10:cmd.exe                                  972   1956      1     33 2011-04-10 21:28:24 UTC+0000
.. 0x81f6d228:win32dd.exe                            1120    972      1     22 2011-04-10 21:29:24 UTC+0000
```

Also, `pstree` command visualized that `win32dd.exe` was executed from `cmd.exe`,
which could be important.

### Brief Processes Summary

We have identified a few possibly suspicious processes so far:

| Process Name   | ProcessID   | ParentProcessID | Description            |
| -------------- | ----------: | --------------: | ---------------------- |
| `WORDPAD.EXE`  | `320`       |          `1204` | Word-like editor       |
| `cmd.exe`      | `972`       |          `1956` | command-line           |
| `win32.dd`     | `1120`      |           `972` | to-be-analyzed         |
| \<unknown\>    | `1204`      |             n/a | unknown parent process |

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
take the information with a grain of salt -- the image was taken in 2011,
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

### Brief Network Summary

| Process Name   | ProcessID | IPs/Ports         | Comment                |
| -------------- | --------: | ----------------: | ---------------------- |
| \<unknown\>    |    `1204` | `91.199.75.77:80` | unknown parent process, most likely downloading stuff from Internet |
| `svchost.exe`  |    `1056` |        `1031/udp` | a (system?) service listening on an UDP port |

We can probably start constructing our preliminary hypothesis:

> A process `1204` communicated with the Internet, downloaded something (most
> likely a .DOC or .RTF document among other things) and started the
> `wordpad.exe` process. It's possible that it started another (system) service
> listening on `1031/udp` port.

### Files Analysis

TBD

### Strings Analysis

TBD

### Forensic (`foremost`) Analysis

TBD

## Final Hypothesis

TBD.

### Indicators

| IndicatorType | Value           | Comment                                    |
| -------------- | -------------- | -------------------------------------------------- |
| `ip-address`   | `91.199.75.77`  | Used for downloading of various stages of the malware. |  
| `domain`       | `mialepromo.ru` | DNS name most likely bound to the address above, used for downloading of various stages of the malware. |
| `user-agent`   | `Our_Agent`     | user-agent identification used for the malware downloads. |
| `filename`     | `Post_Express_Label.exe` | Filename of the original malware file. |

### Signatures

For any kind of future incidents, we prepared the following Yara signatures:

```yaml
rule pv204_suspicious_domain {
  meta:
    description =  "Detects our very suspicious domain"
    author = "Vasek Lorenc"
    date = "2020-04-29"
  strings:
    $env1 = /mialepromo.ru/
  condition:
    any of them
}

rule pv204_suspicious_agent {
  meta:
    description =  "Detects our very suspicious agent"
    author = "Vasek Lorenc"
    date = "2020-04-29"
  strings:
    $env1 = /Our_Agent/
  condition:
    any of them
}
```


[pv204-workshop]: https://github.com/valorcz/vagrant-memory-analysis/blob/master/README.md