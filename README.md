# Memory Analysis Toolbox

Well, "toolbox" could be an overstatement, but this Vagrant image builds a set
of tools you could use for memory analysis exercises.

## Requirements

In order to work with this repository, you need the following software:
  * [VirtualBox](https://www.virtualbox.org/)
  * [HashiCorp Vagrant](https://www.vagrantup.com/)

Both installed on your system. They are available for Windows, Linux and MacOS,
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

```
vagrant up
```

It will do the magic. Be patient, the budilding process may take some time,
depending on your laptop/workstation performance and network bandwith. Also,
there may be a few warnings around the built process, but they are generally
ok and not affecting the functionality of the resulting VM.

[![asciicast](https://asciinema.org/a/3kndqsOpEIfhlaD3DycIaDuhN.png)](https://asciinema.org/a/3kndqsOpEIfhlaD3DycIaDuhN)

### Without VirtualBox

If you don't like VirtualBox or cannot use it for any reason, my recommendation is
to get a VM image of CentOS 7 somewhere and when you get there, you can re-use the 
`provision/provision.sh` script from my repository. In theory, it should prepare
the working environment too.

## Logging to the VM

When the build of the VM is finished, you can logon to the built VM with

```
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
* `rekal` (upstream discontinued in October 2020)

### `vol`

This command runs the original, stable version of Volatility.

### `vol3`

Volatility tool has a very unstable beta version, Volatility3. However, it
processes the memory slightly differently and it could work on some memory
images.

*November 2020 update*: It seems that Volatility3 is undergoing another
major rewrite, combined with changes on Microsoft side too (PDB debugging 
symbols seem to be restructured a bit). That causes problems with Windows
image analysis.

### `rekal`

Google Rekall framework doesn't seem to be supported much these days, but it
still does its work. 

*November 2020 update*: Google team officially discontinued the product
and turned off some of the artifact repositories. Even though `rekal` command
still kind of works, it may break any time.

### Additional Tools

Apart from the memory-analysis tools, there are other programs installed to
help you with your tasks:

  * `strings`
  * `foremost`
  * `radare2` (you don't have to use it, it's just for the curious ones)

## Workshop Images & Exercises 

In order to make everything a bit more user friendly, especially for those not
really familiar with command-line interfaces, I prepared a shell function that
will download & unpack each memory image in a specific working directory, and 
switch you into that directory.

So, when you logon to the built VM image (via `vagrant ssh`, as mentioned above),
you'll get a prompt.

To start working on the very first exercise image, simply type in the following command:

```bash
exercise 1
```

and you should start seeing something like this:

[![asciicast](https://asciinema.org/a/oxP3X8ZkwSIYyZ1nuevrw9YyS.png)](https://asciinema.org/a/oxP3X8ZkwSIYyZ1nuevrw9YyS)

