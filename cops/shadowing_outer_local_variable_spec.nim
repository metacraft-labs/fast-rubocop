
import
  shadowing_outer_local_variable, test_tools

suite "ShadowingOuterLocalVariable":
  var cop = ShadowingOuterLocalVariable()
  context("""when a block argument has same name as an outer scope variable""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          foo = 1
          puts foo
          1.times do |foo|
                      ^^^ Shadowing outer local variable - `foo`.
          end
        end
""".stripIndent))
  context("""when a splat block argument has same name as an outer scope variable""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          foo = 1
          puts foo
          1.times do |*foo|
                      ^^^^ Shadowing outer local variable - `foo`.
          end
        end
""".stripIndent))
  context("""when a block block argument has same name as an outer scope variable""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          foo = 1
          puts foo
          proc_taking_block = proc do |&foo|
                                       ^^^^ Shadowing outer local variable - `foo`.
          end
          proc_taking_block.call do
          end
        end
""".stripIndent))
  context("""when a block local variable has same name as an outer scope variable""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          foo = 1
          puts foo
          1.times do |i; foo|
                         ^^^ Shadowing outer local variable - `foo`.
            puts foo
          end
        end
""".stripIndent))
  context("""when a block argument has different name with outer scope variables""", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def some_method
          foo = 1
          puts foo
          1.times do |bar|
          end
        end
""".stripIndent))
  context("when an outer scope variable is reassigned in a block", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def some_method
          foo = 1
          puts foo
          1.times do
            foo = 2
          end
        end
""".stripIndent))
  context("when an outer scope variable is referenced in a block", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def some_method
          foo = 1
          puts foo
          1.times do
            puts foo
          end
        end
""".stripIndent))
  context("when multiple block arguments have same name \"_\"", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def some_method
          1.times do |_, foo, _|
          end
        end
""".stripIndent))
  context("""when multiple block arguments have a same name starts with "_"""", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def some_method
          1.times do |_foo, bar, _foo|
          end
        end
""".stripIndent))
  context("""when a block argument has same name "_" as outer scope variable "_"""", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def some_method
          _ = 1
          puts _
          1.times do |_|
          end
        end
""".stripIndent))
  context("""when a block argument has a same name starts with "_" as an outer scope variable""", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def some_method
          _foo = 1
          puts _foo
          1.times do |_foo|
          end
        end
""".stripIndent))
  context("""when a method argument has same name as an outer scope variable""", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        class SomeClass
          foo = 1
          puts foo
          def some_method(foo)
          end
        end
""".stripIndent))
