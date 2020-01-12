# Installation

In order to run `pear`, you'll first need the following:

* [Rakudo](https://rakudo.org/), a production-ready and stable implementation
of the [Raku](https://raku.org/) language.

* [zef](https://github.com/ugexe/zef), a tool for managing Raku modules.

## Installing Rakudo

To make things easier it's recommended that you install Rakudo Star,
which contains the Rakudo compiler, several modules, and the documentation. 
The instructions for the different platforms can be found at
https://rakudo.org/files.

Alternatively, you can install *only* the Rakudo compiler. However,
you must also install `zef` in order to install `pear` and any other module
from the [ecosystem](https://modules.raku.org/).

## Installing `zef`

If you installed only the Rakudo compiler, then you'll need to install `zef`
manually. The module and its documentation can be found at
https://github.com/ugexe/zef. The installation instructions are as follows:

```
$ git clone https://github.com/ugexe/zef.git
$ cd zef
$ raku -I. bin/zef install .
```

## Installing `pear`

In order to install `pear`, you only need to do the following:

```
$ git clone git@github.com:hunter-classes/winter-2020-codefest-submissions-phoebe.git
$ cd winter-2020-codefest-submissions-phoebe
$ zef install .
```

`zef install .` means install the module in this path (e.g., current directory
here). If you wish to install any module from the ecosystem you use the same
command with the module's name (e.g., `zef install YAMLish` to install the
`YAMLish` module). 

`pear` have several dependencies (i.e., several modules) but you don't need
to install them manually; `zef` will take care of that while it installs
`pear`.

## More info about `pear`

Information about `pear` can be found at [MODDOC.md](./MODDOC.md).
