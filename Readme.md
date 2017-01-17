# Moviola

A Dynamic Logic Programming (DLP) Interpreter

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


