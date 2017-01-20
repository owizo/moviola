# Moviola

A Dynamic Logic Program (DLP) Interpreter

## Overview

`moviola` is an interactive interpreter for dynamic logic programs.
It implements the following causal rejection-based update semantics on DLPs.
* Update answer set semantics (AS)
* Justified update semantics (JU)
* Dynamic stable model semantics (DS)
* Refined dynamic stable model semantics (RD)

`moviola` implements these semantics by encoding them in online Answer Set Programming (ASP).
It uses [`clingo`](https://github.com/potassco/clingo) from [Potassco](http://potassco.org).

`moviola` utilizes online solving capacity of `clingo` to compute answer sets of DLPs in a multi-shot fashion.
In this way there is no need to start the solving process from scratch whenever a new update program comes.

## Installation

`moviola` needs `clingo` with Python 3 scripting support.
Check [Potassco](https://potassco.org/clingo/) page on getting `clingo`.

Additionally, it needs Python 3 to be installed on your system.
In case the `cmd2` package has not been installed on your system, please check package repositories for your operating system.
In Debian/Ubuntu based systems, you can run `apt-get install python3-cmd2` to install `cmd2` for Python.

`moviola` is in early development stage. There is no official release yet.
You can download the repository as a zip or fetch it using git.

## Usage

The main mode of use for `moviola` is via interactive command-line shell.
It can be run as follows.
The output shows the active update semantics (refined update semantics - RD - in this case) and 
the `>>` prompt denotes `moviola` is waiting your commands.

```bash
$ clingo --acyc-prop=0 moviola-py.lp
clingo version 5.1.0
Reading from moviola-py.lp
Changing semantics: RD
>> 
```

The active update semantics can be inspected and changed.
The options are `as`, `ju`, `ds`, and `rd`, 
update answer set semantics, justified update semantics, dynamic stable model semantics, and refined dynamic stable model semantics, respectively.

```bash
>> semantics
Update semantics: RD
>> semantics ds
Changing semantics: DS
```

Using `update` command you can enter an update logic program.
It opens your default editor (in Linux via `EDITOR` environment variable).

```bash
>> update
```

After you enter and save the propositional normal logic program using your editor, 
`moviola` processes it and updates the current DLP.
Let's enter the logic program with only one fact `p.` as an update.
Here is what `moviola` outputs:

```bash
p.

Reifying u.1.lp ...
Updating ...
```

We can compute the models of the current DLP by `solve` command.
Additionally, the `models` command expects an integer that shows the maximum number of models to compute
(1 is the default value and 0 means all models).
Note that we are using the RD semantics and the only model we get is `{p}`.

```bash
>> models 0
>> solve
Solving...
Answer: 1
p
```

Let's update the DLP with the program `not p :- not p.`.
`{p}` is still the only model we get according to the RD semantics.

```bash
>> update
not p :- not p.

Reifying u.2.lp ...
Updating ...
>> solve
Solving...
Answer: 1
p
```

You can change the underlying semantics anytime and investigate their differences.

```bash
>> semantics ju
Changing semantics: JU
>> solve
Solving...
Answer: 1
p
Answer: 2

>> semantics ds
Changing semantics: DS
>> solve
Solving...
Answer: 1
p
```

Note that according to the JU semantics, our DLP has an extra model `{}`,
which is unintended considering the tautological second update.


## Literature


