
import
  unused_method_argument, test_tools

RSpec.describe(UnusedMethodArgument, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"AllowUnusedKeywordArguments": false, "IgnoreEmptyMethods": false}.newTable())
  describe("inspection", proc (): void =
    context("when a method takes multiple arguments", proc (): void =
      context("and an argument is unused", proc (): void =
        test "registers an offense":
          var message = """Unused method argument - `foo`. If it's necessary, use `_` or `_foo` as an argument name to indicate that it won't be used."""
          expectOffense("""            def some_method(foo, bar)
                            ^^^ (lvar :message)
              puts bar
            end
""".stripIndent)
        context("and arguments are swap-assigned", proc (): void =
          test "accepts":
            expectNoOffenses("""              def foo(a, b)
                a, b = b, a
              end
""".stripIndent))
        context("""and one argument is assigned to another, whilst other's value is not used""", proc (): void =
          test "registers an offense":
            var message = """Unused method argument - `a`. If it's necessary, use `_` or `_a` as an argument name to indicate that it won't be used."""
            expectOffense("""              def foo(a, b)
                      ^ (lvar :message)
                a, b = b, 42
              end
""".stripIndent)))
      context("and all the arguments are unused", proc (): void =
        test "registers offenses and suggests the use of `*`":
          expectOffense("""            def some_method(foo, bar)
                                 ^^^ (lvar :bar_message)
                            ^^^ (lvar :foo_message)
            end
""".stripIndent)))
    context("when a required keyword argument is unused", proc (): void =
      test "registers an offense but does not suggest underscore-prefix":
        expectOffense("""          def self.some_method(foo, bar:)
                                    ^^^ Unused method argument - `bar`.
            puts foo
          end
""".stripIndent))
    context("when an optional keyword argument is unused", proc (): void =
      test "registers an offense but does not suggest underscore-prefix":
        expectOffense("""          def self.some_method(foo, bar: 1)
                                    ^^^ Unused method argument - `bar`.
            puts foo
          end
""".stripIndent)
      context("and AllowUnusedKeywordArguments set", proc (): void =
        let("cop_config", proc (): void =
          {"AllowUnusedKeywordArguments": true}.newTable())
        test "does not care":
          expectNoOffenses("""            def self.some_method(foo, bar: 1)
              puts foo
            end
""".stripIndent)))
    context("when a singleton method argument is unused", proc (): void =
      test "registers an offense":
        var message = """Unused method argument - `foo`. If it's necessary, use `_` or `_foo` as an argument name to indicate that it won't be used. You can also write as `some_method(*)` if you want the method to accept any arguments but don't care about them."""
        expectOffense("""          def self.some_method(foo)
                               ^^^ (lvar :message)
          end
""".stripIndent))
    context("when an underscore-prefixed method argument is unused", proc (): void =
      let("source", proc (): void =
        """        def some_method(_foo)
        end
""".stripIndent)
      test "accepts":
        expectNoOffenses(source()))
    context("when a method argument is used", proc (): void =
      let("source", proc (): void =
        """        def some_method(foo)
          puts foo
        end
""".stripIndent)
      test "accepts":
        expectNoOffenses(source()))
    context("when a variable is unused", proc (): void =
      let("source", proc (): void =
        """        def some_method
          foo = 1
        end
""".stripIndent)
      test "does not care":
        expectNoOffenses(source()))
    context("when a block argument is unused", proc (): void =
      let("source", proc (): void =
        """        1.times do |foo|
        end
""".stripIndent)
      test "does not care":
        expectNoOffenses(source()))
    context("in a method calling `super` without arguments", proc (): void =
      context("when a method argument is not used explicitly", proc (): void =
        test """accepts since the arguments are guaranteed to be the same as superclass' ones and the user has no control on them""":
          expectNoOffenses("""            def some_method(foo)
              super
            end
""".stripIndent)))
    context("in a method calling `super` with arguments", proc (): void =
      context("when a method argument is unused", proc (): void =
        test "registers an offense":
          var message = """Unused method argument - `foo`. If it's necessary, use `_` or `_foo` as an argument name to indicate that it won't be used. You can also write as `some_method(*)` if you want the method to accept any arguments but don't care about them."""
          expectOffense("""            def some_method(foo)
                            ^^^ (lvar :message)
              super(:something)
            end
""".stripIndent)))
    context("in a method calling `binding` without arguments", proc (): void =
      let("source", proc (): void =
        """        def some_method(foo, bar)
          do_something binding
        end
""".stripIndent)
      test "accepts all arguments":
        expectNoOffenses(source())
      context("inside another method definition", proc (): void =
        test "registers offenses":
          expectOffense("""            def some_method(foo, bar)
                                 ^^^ (lvar :bar_message)
                            ^^^ (lvar :foo_message)
              def other(a)
                puts something(binding)
              end
            end
""".stripIndent)))
    context("in a method calling `binding` with arguments", proc (): void =
      context("when a method argument is unused", proc (): void =
        test "registers an offense":
          var message = """Unused method argument - `foo`. If it's necessary, use `_` or `_foo` as an argument name to indicate that it won't be used. You can also write as `some_method(*)` if you want the method to accept any arguments but don't care about them."""
          expectOffense("""            def some_method(foo)
                            ^^^ (lvar :message)
              binding(:something)
            end
""".stripIndent))))
  describe("auto-correction", proc (): void =
    let("corrected_source", proc (): void =
      autocorrectSource(source()))
    context("when multiple arguments are unused", proc (): void =
      let("source", proc (): void =
        """        def some_method(foo, bar)
        end
""")
      let("expected_source", proc (): void =
        """        def some_method(_foo, _bar)
        end
""")
      test "adds underscore-prefix to them":
        expect(correctedSource()).to(eq(expectedSource())))
    context("when only a part of arguments is unused", proc (): void =
      let("source", proc (): void =
        """        def some_method(foo, bar)
          puts foo
        end
""")
      let("expected_source", proc (): void =
        """        def some_method(foo, _bar)
          puts foo
        end
""")
      test "modifies only the unused one":
        expect(correctedSource()).to(eq(expectedSource())))
    context("when there is some whitespace around the argument", proc (): void =
      let("source", proc (): void =
        """        def some_method(foo,
            bar)
          puts foo
        end
""")
      let("expected_source", proc (): void =
        """        def some_method(foo,
            _bar)
          puts foo
        end
""")
      test "preserves the whitespace":
        expect(correctedSource()).to(eq(expectedSource())))
    context("when a splat argument is unused", proc (): void =
      let("source", proc (): void =
        """        def some_method(foo, *bar)
          puts foo
        end
""")
      let("expected_source", proc (): void =
        """        def some_method(foo, *_bar)
          puts foo
        end
""")
      test "preserves the splat":
        expect(correctedSource()).to(eq(expectedSource())))
    context("when an unused argument has default value", proc (): void =
      let("source", proc (): void =
        """        def some_method(foo, bar = 1)
          puts foo
        end
""")
      let("expected_source", proc (): void =
        """        def some_method(foo, _bar = 1)
          puts foo
        end
""")
      test "preserves the default value":
        expect(correctedSource()).to(eq(expectedSource())))
    context("when a keyword argument is unused", proc (): void =
      let("source", proc (): void =
        """        def some_method(foo, bar: 1)
          puts foo
        end
""")
      test "ignores that since modifying the name changes the method interface":
        expect(correctedSource()).to(eq(source())))
    context("when a trailing block argument is unused", proc (): void =
      let("source", proc (): void =
        """        def some_method(foo, bar, &block)
          foo + bar
        end
""")
      let("expected_source", proc (): void =
        """        def some_method(foo, bar)
          foo + bar
        end
""")
      test "removes the unused block arg":
        expect(correctedSource()).to(eq(expectedSource()))))
  context("when IgnoreEmptyMethods config parameter is set", proc (): void =
    let("cop_config", proc (): void =
      {"IgnoreEmptyMethods": true}.newTable())
    test "accepts an empty method with a single unused parameter":
      expectNoOffenses("""        def method(arg)
        end
""".stripIndent)
    test "accepts an empty singleton method with a single unused parameter":
      expectNoOffenses("""        def self.method(unused)
        end
""".stripIndent)
    test """registers an offense for a non-empty method with a single unused parameter""":
      var message = """Unused method argument - `arg`. If it's necessary, use `_` or `_arg` as an argument name to indicate that it won't be used. You can also write as `method(*)` if you want the method to accept any arguments but don't care about them."""
      expectOffense("""        def method(arg)
                   ^^^ (lvar :message)
          1
        end
""".stripIndent)
    test "accepts an empty method with multiple unused parameters":
      expectNoOffenses("""        def method(a, b, *others)
        end
""".stripIndent)
    test """registers an offense for a non-empty method with multiple unused parameters""":
      expectOffense("""        def method(a, b, *others)
                          ^^^^^^ (lvar :others_message)
                      ^ (lvar :b_message)
                   ^ (lvar :a_message)
          1
        end
""".stripIndent)))
