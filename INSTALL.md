# Prerequisites 

Pear is written in the [Raku](https://raku.org/) programming language and thus
a compiler implementing the language is needed. The compiler for Raku is known
as [Rakudo](https://rakudo.org/) and [zef](https://github.com/ugexe/zef)
is the standard distribution manager for Raku.

## Installing the Rakudo compiler

First, you must get the source code for the compiler at
https://rakudo.org/. Alternatively, you can find all the compiler
releases at https://github.com/rakudo/rakudo/releases. There you will
find the latest release, Rakudo version 2020.01. I recommended you install
Rakudo version 2019.11.

Now, you should untar/unzip the archive file with the source. Read the 
`README.md` file to learn about the installation process. Then, follow
the instructions in the `INSTALL.txt` file to install the compiler.

If everything went fine and you added the executable to the PATH, as suggested
by the end of the installation, then you should be able to start the REPL
by typing `raku` in the command line:

```
$ raku
To exit type 'exit' or '^D'
> 
```

Now you can type in your Raku code and have it be evaluated by the REPL.

To run a Raku program in a file, just do:

```
$ raku my-program.raku
```

## Installing zef

You can find all the relevant information for zef, including its installation,
at https://github.com/ugexe/zef. The installation commands will be copied
here for reference:

**Manual installation**:

```
$ git clone https://github.com/ugexe/zef.git
$ cd zef
$ raku -I. bin/zef install .
```

**Rakudobrew**:

To install via [rakudobrew](https://github.com/tadzik/rakudobrew), please use
the following command:

```
$ rakudobrew build zef
```

# Installing Pear

At this stage, you should've the Rakudo compiler and zef installed on your
machine. In order to install Pear, you only need to do the following:

```
$ git clone git@github.com:hunter-classes/winter-2020-codefest-submissions-phoebe.git
$ cd winter-2020-codefest-submissions-phoebe
$ zef install .
```

`zef install .` means install the module in the current directory.

**NOTE**: If you wish to install any module from the
[ecosystem](https://modules.raku.org/) you can use the same command with the
module's name. For instance, to install the
[JSON::Tiny](https://modules.raku.org/dist/JSON::Tiny:cpan:MORITZ) module, 
you run `zef install JSON::Tiny` and zef will take to install the module and
all the module's dependencies if it has any. Run `zef` to learn more zef
commands.

Pear has several dependencies but, as mentioned above, `zef` takes care of them.

# Using Pear

Now that Pear is installed, you can run `pear` and it should print out Pear's
usage message. You can go to https://github.com/uzluisf/pear-doc/tree/source and 
follow the instructions there to generate a demo site using Pear.

You can find more about Pear at https://uzluisf.github.io/pear-doc/.
