# fast-rubocop

A linter for Ruby based on semi-automated translation of [rubocop](https://github.com/rubocop-hq/rubocop/).

## Why

It's a prototype used to demonstrate [languist](https://githib.com/metacraft-labs/languist)

* We used treesitter and a custom adapter to replace the usage of the `parser` gem
* We ported manually some basic parts of the infrastructure/testing code/mixins
* We translate automatically the actual cops to Nim

## Credits

* the project is based on the great work on rubocop by the author Bozhidar Batsov and all core developers and contributors: [rubocop](https://github.com/rubocop-hq/rubocop/)

* nim-rubocop is technically a fork of [nimterop](https://github.com/nimterop/nimterop): huge credit is due to [genotrance](https://github.com/genotrance) for nimterop and the tree-sitter nim wrappers, also to the tree-sitter project. Nimterop helped incredibly for getting treesitter/the project working quickly! 
  
  Credit is due to [timotheecour](https://github.com/timotheecour) as well, for his contributions to nimterop included here


## Build

* install [nim](https://github.com/nim-lang/Nim)
* clone this repo
* run `nim c -d:release checker.nim`
* `./checker <path>` now should act similarly to rubocop (you can put it somewhere in path)

## Example cop


```ruby
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      ## Docs
      class CircularArgumentReference < Cop
        MSG = 'Circular argument reference - `%<arg_name>s`.'.freeze

        def on_kwoptarg(node)
          check_for_circular_argument_references(*node)
        end

        def on_optarg(node)
          check_for_circular_argument_references(*node)
        end

        private

        def check_for_circular_argument_references(arg_name, arg_value)
          return unless arg_value.lvar_type?
          return unless arg_value.to_a == [arg_name]

          add_offense(arg_value, message: format(MSG, arg_name: arg_name))
        end
      end
    end
  end
end
```

is converted to

```nim
import
  types

cop CircularArgumentReference:
  ## Docs

  const
    MSG = "Circular argument reference - `%<arg_name>s`."

  method onKwoptarg*(self; node) =
    self.checkForCircularArgumentReferences(node[0], node[1])


  method onOptarg*(self; node) =
    self.checkForCircularArgumentReferences(node[0], node[1])


  method checkForCircularArgumentReferences*(self; argName: Symbol; argValue: Node) =
    if not argValue.isLvarType:
      return
    if not (argValue.toSeq() == @[argName]):
      return
    addOffense(argValue, message = format(MSG, argName = argName))
```

## Performance

We target 5-10x performance increase.
Initial benchmarks running rubocop and fast-rubocop with mostly equivalent configs(with only several cops) on some of the rubocop source
show fast-rubocop being around 2x-10x faster:

Nim program is built with
`nim -d:release c checker.nim`

Rubocop is used with `--cache false` as we want to find raw speeds and with manual benchmarking code inserted to count only from the start of actual linting: the code is in [rubocop](https://github.com/metacraft-labs/rubocop#port)

**Keep in mind**: we are still only running benchmarks with small number of cops and in an uncontrolled environment, so benchmarks results might not be representative enough. Note: even if some cops still behave incorrectly in the Nim translation, their speed should be still similar.

project | rubocop|fast-rubocop
--------|--------|------------
line_length.rb | 49ms | 19ms
metrics (11 files) | 94 ms | 29 ms
rubocop(1187 files) | 16.540 s | 1.396 s

## Caution

This is still a research project: it depends on languist progress and the tools we use might still change
significantly: the interlang api, rewrites and translations are not stable yet.
Fast-rubocop itself is still not stable, but if there is enough interest, and if enough cops are succesfully annotated/translated, it might be maintained as an alternative linter, as we plan to be able to translate new commits.

Currently we have automatically translated correctly enough for our goals 6 cops residing in subfolders of `cops`.
We also translated most of the cops in less correct way which would still require manual fixes: the quality of those translations should hopefully improve.

## Translate with ruby2nim

* install [ruby2nim](https://github.com/metacraft-labs/ruby2nim)
* use langcop to translate parts of rubocop based on args and env vars

## Langcop

it is a script helping to translate portions of rubocop

you can run `./langcop_all` to translate the currently correctly translatable modules


## Tree-sitter

we adapt tree-sitter because rubocop heavily depends on parser's format. We currently compile treesitter's AST to an AST mostly compatible with `parser`'s API, however there are still some edge cases and nodes which are not handled correctly, so this is a work in progress.
Another option is to port `parser` itself to Nim/C++, but this is out of scope.

## LICENSE

fast-rubocop is a derivative work based on [rubocop](https://github.com/rubocop-hq/rubocop/). which seems to use the MIT License as well: credits for the original 
tool to its author Bozhidar Batsov and all core developers and contributors: [rubocop](https://github.com/rubocop-hq/rubocop/)

fast-rubocop is a fork of [nimterop](https://github.com/nimterop/nimterop) which also uses the MIT License.

The MIT License (MIT)

Copyright (c) 2019 Zahary Karadjov, Alexander Ivanov

