# Running on Apple M1/M2/M3 hardware

If you happen to be using macOS computers with Apple Silicon processors,
you need to use a slightly (or very, depends) process for provisioning
a VM with the required tools.

> :warn: Currently my setup only works with `x86_64` emulation.

## Vagrant-based setup

### Installing base tools

In order to get all the things running, you need a few extra tools
on your host:

```bash
brew install vagrant qemu
#Due to dependency errors, we must install vbguest first..

vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-qemu
```

### Initial VM provisioning

Then, if everything goes fine, things could be pretty straightforward.

```bash
VAGRANT_VAGRANTFILE=Vagrantfile.m1mac vagrant up
```

## Dockerized version

Thanks to @adamivora and his effort, you can use another (easier) way of provisioning
the necessary toolset on your host.

### With Docker Compose

You need the following software installed:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

#### Option 1 - Build it yourself

```bash
docker compose build # takes ~20 minutes on a M1 Macbook Pro
docker compose run memory-analysis /bin/bash
```

#### Option 2 - Use a pre-built image

This is faster, but it means you trust me with the process of building the
image and not including any malicious code.

```bash
docker compose -f docker-compose.prebuilt.yml run memory-analysis /bin/bash
```

### Resources

- <https://gist.github.com/beauwilliams/69eabc42e540a309f53d55c4b8e6ffe3>

