# Memory Analysis Toolbox

Well, "toolbox" could be an overstatement, but this Vagrant image builds a set
of tools you could use for memory analysis exercises.

> :star: Big thanks to [Adam Ivora](https://github.com/adamivora) for providing
> his files to help with dockerization of this toolset! Please follow [Apple Mx
> instructions](doc/apple-silicon-startup.md) for more detailed instructions.

## Requirements

In order to work with this repository, you need the following software:

* [HashiCorp Vagrant](https://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/)

Both installed on your system. They are available for Windows, Linux and macOS,
so you should be able to get it for the platform of your liking.

Then, you need to either clone this `git` repository (if you know how to work
with `git`, it's a preferred way), or download
[its ZIP archive](https://github.com/valorcz/vagrant-memory-analysis/archive/master.zip).

```bash
git clone https://github.com/valorcz/vagrant-memory-analysis.git
```

## Building the Image

As always, it's very straightforward with Vagrant. Switch to the command-line,
get to the folder where you downloaded (and unpacked, if necessary) the
repository, and on the command-line, run the following command:

```bash
vagrant up
```

It will do the magic. Be patient, the building process may take some time,
depending on your laptop/workstation performance and network bandwidth. Also,
there may be a few warnings around the build process, but they are generally
ok and not affecting the functionality of the resulting VM.

[![asciicast](https://asciinema.org/a/3kndqsOpEIfhlaD3DycIaDuhN.png)](https://asciinema.org/a/3kndqsOpEIfhlaD3DycIaDuhN)

### Manual setup

If you don't like VirtualBox/Vagrant/Docker or cannot use it for any reason, my
recommendation is to get a VM image of AlmaLinux 9 somewhere and when you get
there, you can re-use the `provision/provision.sh` script from my repository.
In theory, it should prepare the working environment too.

## Logging to the VM

When the build of the VM is finished, you can log on to the built VM with

```bash
vagrant ssh
```

and that's it! Now you are working in a well-prepared forensic environment,
with various tools installed to streamline your analysis.

**Note:** If a password is required (this is mostly the case of Windows OS,
where the SSH implementation doesn't play along), use the password `vagrant`.
That'll allow you to log in.

## Available tools

There are three tools pre-installed and configured in the VM at the moment:

* `vol`
* `vol3`

### `vol`

This command runs the original, stable version of Volatility.

### `vol3`

Volatility tool has a stable new version, Volatility3. However, it
processes the memory slightly differently, and it could work on some memory
images. Also, the set of available plugins is still significantly
smaller than for the previous version.

### Additional Tools

Apart from the memory-analysis tools, there are other programs installed to
help you with your tasks:

* `strings`
* `peepdf` 
    * for detailed PDF analysis, with some JavaScript insight too
* `foremost`
    * (!) temporarily unavailable due to the lack of RPM packages
* `radare2` 
    * you don't have to use it, it's just for the curious ones

## Workshop Images & Exercises

In order to make everything a bit more user-friendly, especially for those not
really familiar with command-line interfaces, I prepared a shell function that
will download & unpack each memory image in a specific working directory, and
switch you into that directory.

So, when you log on to the built VM image (via `vagrant ssh`, as mentioned above),
you'll get a prompt.

To start working on the very first exercise image, simply type in the following command:

```bash
exercise 1
```

and you should start seeing something like this:

[![asciicast](https://asciinema.org/a/oxP3X8ZkwSIYyZ1nuevrw9YyS.png)](https://asciinema.org/a/oxP3X8ZkwSIYyZ1nuevrw9YyS)
