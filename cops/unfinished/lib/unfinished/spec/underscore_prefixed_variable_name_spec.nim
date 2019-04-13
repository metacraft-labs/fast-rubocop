
import
  tables

import
  underscore_prefixed_variable_name, test_tools

suite "UnderscorePrefixedVariableName":
  var cop = UnderscorePrefixedVariableName()
  context("when an underscore-prefixed variable is used", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          _foo = 1
          ^^^^ Do not use prefix `_` for a variable that is used.
          puts _foo
        end
""".stripIndent))
  context("when non-underscore-prefixed variable is used", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def some_method
          foo = 1
          puts foo
        end
""".stripIndent))
  context("when an underscore-prefixed variable is reassigned", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def some_method
          _foo = 1
          _foo = 2
        end
""".stripIndent))
  context("when an underscore-prefixed method argument is used", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method(_foo)
                        ^^^^ Do not use prefix `_` for a variable that is used.
          puts _foo
        end
""".stripIndent))
  context("when an underscore-prefixed block argument is used", proc (): void =
    test "registers an offense":
      expectOffense("""        1.times do |_foo|
                    ^^^^ Do not use prefix `_` for a variable that is used.
          puts _foo
        end
""".stripIndent))
  context("when an underscore-prefixed variable in top-level scope is used", proc (): void =
    test "registers an offense":
      expectOffense("""        _foo = 1
        ^^^^ Do not use prefix `_` for a variable that is used.
        puts _foo
""".stripIndent))
  context("when an underscore-prefixed variable is captured by a block", proc (): void =
    test "accepts":
      expectNoOffenses("""        _foo = 1
        1.times do
          _foo = 2
        end
""".stripIndent))
  context("when an underscore-prefixed named capture variable is used", proc (): void =
    test "registers an offense":
      expectOffense("""        /(?<_foo>\w+)/ =~ 'FOO'
        ^^^^^^^^^^^^^^ Do not use prefix `_` for a variable that is used.
        puts _foo
""".stripIndent))
  for keyword in @["super", "binding"]:
    context("""in a method calling `(lvar :keyword)` without arguments""", proc (): void =
      context("when an underscore-prefixed argument is not used explicitly", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            def some_method(*_)
              (lvar :keyword)
            end
""".stripIndent))
      context("when an underscore-prefixed argument is used explicitly", proc (): void =
        test "registers an offense":
          expectOffense("""            def some_method(*_)
                             ^ Do not use prefix `_` for a variable that is used.
              (lvar :keyword)
              puts _
            end
""".stripIndent)))
    context("""in a method calling `(lvar :keyword)` with arguments""", proc (): void =
      context("when an underscore-prefixed argument is not used", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            def some_method(*_)
              (lvar :keyword)(:something)
            end
""".stripIndent))
      context("when an underscore-prefixed argument is used explicitly", proc (): void =
        test "registers an offense":
          expectOffense("""            def some_method(*_)
                             ^ Do not use prefix `_` for a variable that is used.
              (lvar :keyword)(*_)
            end
""".stripIndent)))
