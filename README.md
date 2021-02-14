Anagram
=======

[![Build](https://github.com/reznikmm/anagram/workflows/Build/badge.svg)](https://github.com/reznikmm/anagram/actions)
[![Copr build status](https://copr.fedorainfracloud.org/coprs/reznik/ada/package/anagram/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/reznik/ada/)
[![reuse compliant](https://img.shields.io/badge/reuse-compliant-green.svg)](https://reuse.software/)

> Grammar handling and parser generation Ada library

Anagram is an Ada library to work with grammars of program languages.
It provides a type to represent classic grammar formalism including
BNF, extended BNF and attributed grammars, subprograms to construct, read
and convert them, some checks, parser generation, etc.

The Anagram makes it easy to create parsers of various kinds.

Main features:
* convert EBNF to BNF with several ways of expanding lists
* generate tables for LALR and simple LR parsers
* provides API to construct grammar or read it from a textual file
* resolve conflicts in LR table using precedence and associativity
* provides generic deterministic parser and Right Nulled GLR Parser
* provides simple templates to represet rules of attributed grammars
* API to construct First/Follow sets
* partition ordered attributed grammar to find attribute evaluation order
* write grammar in a file of yacc format
* provides some checks:
  + Is_Well_Formed
  + Is_L_Attributed
  + is ordered attributed grammar

## Install

Run
```
make all install PREFIX=/path/to/install
```

### Dependencies
It depends on [Matreshka](https://forge.ada-ru.org/matreshka) library.

## Usage
Add `with "anagram";` in your project file.

## Maintainer

[@MaximReznik](https://github.com/reznikmm).

## Contribute

Feel free to dive in!
[Open an issue](https://github.com/reznikmm/anagram/issues/new) or submit PRs.

## License

[MIT](LICENSE) © Maxim Reznik


