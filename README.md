# Memory Analysis Toolbox

A hands-on, safe forensic environment designed for university students to practice memory analysis and incident response using **Volatility 2** and **Volatility 3**.

---

## Requirements

You can run this environment using **Docker** (recommended) or **Vagrant**:

* **Docker Option (Recommended)**: [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS, Windows, Linux) or Docker Engine. This works cross-platform out-of-the-box on both **x86_64** and **Apple Silicon (M1/M2/M3/M4)**.
* **Vagrant Option**: [HashiCorp Vagrant](https://www.vagrantup.com/) + [VirtualBox](https://www.virtualbox.org/) (for x86_64) or QEMU with the `vagrant-qemu` plugin (for Apple Silicon).

To get started, clone this repository:

```bash
git clone https://github.com/valorcz/vagrant-memory-analysis.git
cd vagrant-memory-analysis
```

---

## Workshop Preparation (Recommended: 1–2 Days Ahead)

Please complete the following setup steps before attending the lab so you are ready to analyze samples immediately without waiting for downloads or builds in class:

### Step 1: Pre-Download Volatility 3 Symbols (Host)

Volatility 3 requires OS symbol tables (ISF) to parse kernel data structures. Run the helper script on your host machine to cache the official symbol pack in `./symbols`:

```bash
./build/download-symbols.sh
```

*(This caches ~840MB of Windows symbols once on your host. Both Docker and Vagrant automatically mount these symbols so your environment operates offline without initial command delays).*

### Step 2: Launch Your Environment

#### Option A: Docker Compose (Universal — macOS, Windows, Linux)

Docker is the simplest, platform-independent option.

* **Fastest (Use Pre-built Image)**:
  ```bash
  docker compose -f docker-compose.prebuilt.yml run --rm memory_analysis /bin/bash
  ```

* **Or Build Locally**:
  ```bash
  docker compose build
  docker compose run --rm memory_analysis /bin/bash
  ```

#### Option B: Vagrant (VirtualBox or QEMU)

If you prefer a full virtual machine via Vagrant:

```bash
vagrant up
vagrant ssh
```

> **Apple Silicon Mac Note:** If using Vagrant on Apple Silicon, ensure you have QEMU installed (`brew install qemu && vagrant plugin install vagrant-qemu`).
>
> **Windows Note:** If prompted for an SSH password, use `vagrant`.

### Step 3: Verify Your Setup

Once inside your container or VM shell, test that both Volatility 2 and Volatility 3 respond:

```bash
vol -h
vol3 -h
```

If both commands print their help screens, your environment is ready for class!

---

## Available Tools

The environment provides both major versions of the Volatility memory forensics framework:

* `vol`: Volatility 2.7 (Python 2.7). Our primary tool for legacy Windows XP images due to its rich community plugins (`connscan`, `sockets`, `dnscache`, `prefetchparser`).
* `vol3`: Volatility 3 (Python 3). The modern framework rewrite for 64-bit Windows 7, 10, 11, and Linux analysis.

> 📖 **Rosetta Stone Guide:** For a side-by-side command comparison and an explanation of when to use each version, see our [Volatility 2 vs. Volatility 3 Rosetta Stone](doc/volatility-rosetta-stone.md).

### Additional Pre-installed Utilities
* `strings`: For targeted ASCII and 16-bit little-endian Unicode extraction.
* `peepdf` & `oletools`: For inspecting dropped PDF, Word, and RTF documents (`rtfobj`, `olevba`).
* `yara`: For signature scanning across memory dumps and carved files.
* `radare2`: For reverse engineering and disassembling carved payloads.

---

## Workshop Images & Exercises

The environment includes a built-in helper function, `exercise`, that automatically downloads, decompresses, and navigates to the working directory for each lab image.

Inside the VM or container, run:

```bash
exercise 1
```

This will download `xp-infected.vmem` into `~/images/exercise01/` and open a shell in that folder.

* See [`report/report.md`](report/report.md) for a comprehensive sample forensic report analyzing `exercise 1`.

---

## Credits

* **Author & Instructor**: [Václav Lorenc](https://github.com/valorcz)
* **Dockerization & Multi-Platform Support**: Special thanks to [Adam Ivora](https://github.com/adamivora) for contributing the initial Docker configurations and containerization setup.
