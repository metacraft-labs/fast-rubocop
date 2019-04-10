
import
  unused_block_argument, test_tools

RSpec.describe(UnusedBlockArgument, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"AllowUnusedKeywordArguments": false}.newTable())
  sharedExamples("auto-correction", proc (name: string; oldSource: string;
                                        newSource: string): void =
    test """auto-corrects (lvar :name)""":
      var correctedSource = autocorrectSource(oldSource)
      expect(correctedSource).to(eq(newSource)))
  context("inspection", proc (): void =
    context("when a block takes multiple arguments", proc (): void =
      context("and an argument is unused", proc (): void =
        test "registers an offense":
          var message = """Unused block argument - `value`. If it's necessary, use `_` or `_value` as an argument name to indicate that it won't be used."""
          expectOffense("""            hash.each do |key, value|
                               ^^^^^ (lvar :message)
              puts key
            end
""".stripIndent))
      context("and arguments are swap-assigned", proc (): void =
        test "accepts":
          expectNoOffenses("""            hash.each do |key, value|
              key, value = value, key
            end
""".stripIndent))
      context("""and one argument is assigned to another, whilst other's value is not used""", proc (): void =
        test "registers an offense":
          var message = """Unused block argument - `key`. If it's necessary, use `_` or `_key` as an argument name to indicate that it won't be used."""
          expectOffense("""            hash.each do |key, value|
                          ^^^ (lvar :message)
              key, value = value, 42
            end
""".stripIndent))
      context("and all the arguments are unused", proc (): void =
        test "registers offenses and suggests omitting them":
          expectOffense("""            hash = { foo: 'FOO', bar: 'BAR' }
            hash.each do |key, value|
                               ^^^^^ (lvar :value_message)
                          ^^^ (lvar :key_message)
              puts :something
            end
""".stripIndent)))
    context("when a block takes single argument", proc (): void =
      context("and the argument is unused", proc (): void =
        test "registers an offense and suggests omitting that":
          var message = """Unused block argument - `index`. You can omit the argument if you don't care about it."""
          expectOffense("""            1.times do |index|
                        ^^^^^ (lvar :message)
              puts :something
            end
""".stripIndent))
      context("and the method call is `define_method`", proc (): void =
        test "registers an offense":
          var message = """Unused block argument - `bar`. If it's necessary, use `_` or `_bar` as an argument name to indicate that it won't be used."""
          expectOffense("""            define_method(:foo) do |bar|
                                    ^^^ (lvar :message)
              puts 'baz'
            end
""".stripIndent)))
    context("when a block have a block local variable", proc (): void =
      context("and the variable is unused", proc (): void =
        test "registers an offense":
          expectOffense("""            1.times do |index; block_local_variable|
                               ^^^^^^^^^^^^^^^^^^^^ Unused block local variable - `block_local_variable`.
              puts index
            end
""".stripIndent)))
    context("when a lambda block takes arguments", proc (): void =
      context("and all the arguments are unused", proc (): void =
        test "registers offenses and suggests using a proc":
          expectOffense("""            -> (foo, bar) { do_something }
                     ^^^ (lvar :bar_message)
                ^^^ (lvar :foo_message)
""".stripIndent))
      context("and an argument is unused", proc (): void =
        test "registers an offense":
          var message = """Unused block argument - `foo`. If it's necessary, use `_` or `_foo` as an argument name to indicate that it won't be used."""
          expectOffense("""            -> (foo, bar) { puts bar }
                ^^^ (lvar :message)
""".stripIndent)))
    context("when an underscore-prefixed block argument is not used", proc (): void =
      test "accepts":
        expectNoOffenses("""          1.times do |_index|
            puts 'foo'
          end
""".stripIndent))
    context("when an optional keyword argument is unused", proc (): void =
      context("when the method call is `define_method`", proc (): void =
        test "registers an offense":
          var message = """Unused block argument - `bar`. If it's necessary, use `_` or `_bar` as an argument name to indicate that it won't be used."""
          expectOffense("""            define_method(:foo) do |bar: 'default'|
                                    ^^^ (lvar :message)
              puts 'bar'
            end
""".stripIndent)
        context("when AllowUnusedKeywordArguments set", proc (): void =
          let("cop_config", proc (): void =
            {"AllowUnusedKeywordArguments": true}.newTable())
          test "does not care":
            expectNoOffenses("""              define_method(:foo) do |bar: 'default'|
                puts 'bar'
              end
""".stripIndent)))
      context("when the method call is not `define_method`", proc (): void =
        test "registers an offense":
          var message = """Unused block argument - `bar`. You can omit the argument if you don't care about it."""
          expectOffense("""            foo(:foo) do |bar: 'default'|
                          ^^^ (lvar :message)
              puts 'bar'
            end
""".stripIndent)
        context("when AllowUnusedKeywordArguments set", proc (): void =
          let("cop_config", proc (): void =
            {"AllowUnusedKeywordArguments": true}.newTable())
          test "does not care":
            expectNoOffenses("""              foo(:foo) do |bar: 'default'|
                puts 'bar'
              end
""".stripIndent))))
    context("when a method argument is not used", proc (): void =
      test "does not care":
        expectNoOffenses("""          def some_method(foo)
          end
""".stripIndent))
    context("when a variable is not used", proc (): void =
      test "does not care":
        expectNoOffenses("""          1.times do
            foo = 1
          end
""".stripIndent))
    context("in a method calling `binding` without arguments", proc (): void =
      test "accepts all arguments":
        expectNoOffenses("""          test do |key, value|
            puts something(binding)
          end
""".stripIndent)
      context("inside a method definition", proc (): void =
        test "registers offenses":
          expectOffense("""            test do |key, value|
                          ^^^^^ (lvar :value_message)
                     ^^^ (lvar :key_message)
              def other(a)
                puts something(binding)
              end
            end
""".stripIndent)))
    context("in a method calling `binding` with arguments", proc (): void =
      context("when a method argument is unused", proc (): void =
        test "registers an offense":
          expectOffense("""            test do |key, value|
                          ^^^^^ (lvar :value_message)
                     ^^^ (lvar :key_message)
              puts something(binding(:other))
            end
""".stripIndent)))
    context("with an empty block", proc (): void =
      context("when not configured to ignore empty blocks", proc (): void =
        let("cop_config", proc (): void =
          {"IgnoreEmptyBlocks": false}.newTable())
        test "registers an offense":
          var message = """Unused block argument - `bar`. You can omit the argument if you don't care about it."""
          expectOffense("""            super { |bar| }
                     ^^^ (lvar :message)
""".stripIndent))
      context("when configured to ignore empty blocks", proc (): void =
        let("cop_config", proc (): void =
          {"IgnoreEmptyBlocks": true}.newTable())
        test "does not register an offense":
          expectNoOffenses("super { |bar| }"))))
  context("auto-correct", proc (): void =
    itBehavesLike("auto-correction", "fixes single", "arr.map { |foo| stuff }",
                  "arr.map { |_foo| stuff }")
    itBehavesLike("auto-correction", "fixes multiple",
                  "hash.map { |key, val| stuff }",
                  "hash.map { |_key, _val| stuff }")
    itBehavesLike("auto-correction", "preserves whitespace", """        hash.map { |key,
                    val| stuff }
""", """        hash.map { |_key,
                    _val| stuff }
""")
    itBehavesLike("auto-correction", "preserves splat",
                  "obj.method { |foo, *bars, baz| stuff(foo, baz) }",
                  "obj.method { |foo, *_bars, baz| stuff(foo, baz) }")
    itBehavesLike("auto-correction", "preserves default",
                  "obj.method { |foo, bar = baz| stuff(foo) }",
                  "obj.method { |foo, _bar = baz| stuff(foo) }")
    test "ignores used arguments":
      var originalSource = "obj.method { |foo, baz| stuff(foo, baz) }"
      expect(autocorrectSource(originalSource)).to(eq(originalSource)))
  context("when IgnoreEmptyBlocks config parameter is set", proc (): void =
    let("cop_config", proc (): void =
      {"IgnoreEmptyBlocks": true}.newTable())
    test "accepts an empty block with a single unused parameter":
      expectNoOffenses("->(arg) { }")
    test "registers an offense for a non-empty block with an unused parameter":
      var message = """Unused block argument - `arg`. If it's necessary, use `_` or `_arg` as an argument name to indicate that it won't be used. Also consider using a proc without arguments instead of a lambda if you want it to accept any arguments but don't care about them."""
      expectOffense("""        ->(arg) { 1 }
           ^^^ (lvar :message)
""".stripIndent)
    test "accepts an empty block with multiple unused parameters":
      expectNoOffenses("->(arg1, arg2, *others) { }")
    test "registers an offense for a non-empty block with multiple unused args":
      expectOffense("""        ->(arg1, arg2, *others) { 1 }
                        ^^^^^^ (lvar :others_message)
                 ^^^^ (lvar :arg2_message)
           ^^^^ (lvar :arg1_message)
""".stripIndent)))
