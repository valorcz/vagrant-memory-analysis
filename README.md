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
git clone git@github.com:valorcz/vagrant-memory-analysis.git
```

## Running the Image

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

When the build of the VM is finished, you can logon to the built VM with

```
vagrant ssh
```

### Without VirtualBox

If you don't like VirtualBox or cannot use it for any reason, my recommendation is
to get a VM image of CentOS 7 somewhere and when you get there, you can re-use the 
`provision/provision.sh` script from my repository. In theory, it should prepare
the working environment too.

## Available tools

There are three tools pre-installed and configured in the VM at the moment:

* `vol`
* `vol3`
* `rekal`

### `vol`

This command runs the original, stable version of Volatility.

### `vol3`

Volatility tool has a very unstable beta version, Volatility3. However, it
processes the memory slightly differently and it could work on some memory
images.

### `rekal`

Google Rekall framework doesn't seem to be supported much these days, but it
still does its work.

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

```
 ns-memory-analysis  vagrant  ~  exercise 1
Downloading exercise01 image: xp-infected.vmem...
######################################################################## 100.0%
Extracting the image...
  /home/vagrant/images/exercise01/xp-infected.vmem.bz2: done
 ns-memory-analysis  vagrant  ~  images  exercise01  
```

