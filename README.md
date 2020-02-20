# Memory Analysis Toolbox

Well, "toolbox" could be an overstatement, but this Vagrant image builds a set of tools you could use for memory analysis exercises.

## Running the Image

As always, it's very straightforward with Vagrant:

```
vagrant up
```

will do the magic.

When the build of the VM is finished, you can logon to the built VM with

```
vagrant ssh
```

## Available tools

There are three tools pre-installed and configured in the VM at the moment:

* `vol`
* `vol3`
* `rekal`

### `vol`

This command runs the original, stable version of Volatility.

### `vol3`

Volatility tool has a very unstable beta version, Volatility3. However, it processes the memory slightly differently and it could work on some memory images.

### `rekal`

Google Rekall framework doesn't seem to be supported much these days, but it still does its work.
