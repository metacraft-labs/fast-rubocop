
import
  shadowed_argument, test_tools

RSpec.describe(ShadowedArgument, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"IgnoreImplicitReferences": false}.newTable())
  describe("method argument shadowing", proc (): void =
    context("when a single argument is shadowed", proc (): void =
      test "registers an offense":
        expectOffense("""          def do_something(foo)
            foo = 42
            ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
            puts foo
          end
""".stripIndent)
      context("when zsuper is used", proc (): void =
        test "registers an offense":
          expectOffense("""            def do_something(foo)
              foo = 42
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              super
            end
""".stripIndent)
        context("when argument was shadowed by zsuper", proc (): void =
          test "registers an offense":
            expectOffense("""              def select_fields(query, current_time)
                query = super
                ^^^^^^^^^^^^^ Argument `query` was shadowed by a local variable before it was used.
                query.select('*')
              end
""".stripIndent))
        context("when IgnoreImplicitReferences config option is set to true", proc (): void =
          let("cop_config", proc (): void =
            {"IgnoreImplicitReferences": true}.newTable())
          test "accepts":
            expectNoOffenses("""              def do_something(foo)
                foo = 42
                super
              end
""".stripIndent)
          context("when argument was shadowed by zsuper", proc (): void =
            test "does not register an offense":
              expectNoOffenses("""                def select_fields(query, current_time)
                  query = super
                  query.select('*')
                end
""".stripIndent))))
      context("when argument was used in shorthand assignment", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            def do_something(bar)
              bar = 'baz' if foo
              bar ||= {}
            end
""".stripIndent))
      context("when a splat argument is shadowed", proc (): void =
        test "registers an offense":
          expectOffense("""            def do_something(*items)
              *items, last = [42, 42]
               ^^^^^ Argument `items` was shadowed by a local variable before it was used.
              puts items
            end
""".stripIndent))
      context("when reassigning to splat variable", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            def do_something(*items)
              *items, last = items
              puts items
            end
""".stripIndent))
      context("when binding is used", proc (): void =
        test "registers an offense":
          expectOffense("""            def do_something(foo)
              foo = 42
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              binding
            end
""".stripIndent)
        context("when IgnoreImplicitReferences config option is set to true", proc (): void =
          let("cop_config", proc (): void =
            {"IgnoreImplicitReferences": true}.newTable())
          test "accepts":
            expectNoOffenses("""              def do_something(foo)
                foo = 42
                binding
              end
""".stripIndent)))
      context("and the argument is not used", proc (): void =
        test "accepts":
          expectNoOffenses("""            def do_something(foo)
              puts 'done something'
            end
""".stripIndent))
      context("and shadowed within a conditional", proc (): void =
        test """registers an offense without specifying where the reassignment took place""":
          expectOffense("""            def do_something(foo)
                             ^^^ Argument `foo` was shadowed by a local variable before it was used.
              if bar
                foo = 43
              end
              foo = 42
              puts foo
            end
""".stripIndent)
        context("and was used before shadowing", proc (): void =
          test "accepts":
            expectNoOffenses("""              def do_something(foo)
                if bar
                  puts foo
                  foo = 43
                end
                foo = 42
                puts foo
              end
""".stripIndent))
        context("and the argument was not shadowed outside the conditional", proc (): void =
          test "accepts":
            expectNoOffenses("""              def do_something(foo)
                if bar
                  foo = 42
                end

                puts foo
              end
""".stripIndent))
        context("and the conditional occurs after the reassignment", proc (): void =
          test "registers an offense":
            expectOffense("""              def do_something(foo)
                foo = 43
                ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
                if bar
                  foo = 42
                end
                puts foo
              end
""".stripIndent))
        context("and the conditional is nested within a conditional", proc (): void =
          test """registers an offense without specifying where the reassignment took place""":
            expectOffense("""              def do_something(foo)
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                if bar
                  if baz
                    foo = 43
                  end
                end
                foo = 42
                puts foo
              end
""".stripIndent)
          context("and the argument was used before shadowing", proc (): void =
            test "accepts":
              expectNoOffenses("""                def do_something(foo)
                  if bar
                    puts foo
                    if baz
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
""".stripIndent)))
        context("and the conditional is nested within a lambda", proc (): void =
          test """registers an offense without specifying where the reassignment took place""":
            expectOffense("""              def do_something(foo)
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                lambda do
                  if baz
                    foo = 43
                  end
                end
                foo = 42
                puts foo
              end
""".stripIndent)
          context("and the argument was used before shadowing", proc (): void =
            test "accepts":
              expectNoOffenses("""                def do_something(foo)
                  lambda do
                    puts foo
                    if baz
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
""".stripIndent))))
      context("and shadowed within a block", proc (): void =
        test """registers an offense without specifying where the reassignment took place""":
          expectOffense("""            def do_something(foo)
                             ^^^ Argument `foo` was shadowed by a local variable before it was used.
              something { foo = 43 }

              foo = 42
              puts foo
            end
""".stripIndent)
        context("and was used before shadowing", proc (): void =
          test "accepts":
            expectNoOffenses("""              def do_something(foo)
                lambda do
                  puts foo
                  foo = 43
                end

                foo = 42
                puts foo
              end
""".stripIndent))
        context("and the argument was not shadowed outside the block", proc (): void =
          test "accepts":
            expectNoOffenses("""              def do_something(foo)
                something { foo = 43 }

                puts foo
              end
""".stripIndent))
        context("and the block occurs after the reassignment", proc (): void =
          test "registers an offense":
            expectOffense("""              def do_something(foo)
                foo = 43
                ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
                something { foo = 42 }
                puts foo
              end
""".stripIndent))
        context("and the block is nested within a block", proc (): void =
          test """registers an offense without specifying where the reassignment took place""":
            expectOffense("""              def do_something(foo)
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                something do
                  lambda do
                    foo = 43
                  end
                end

                foo = 42
                puts foo
              end
""".stripIndent)
          context("and the argument was used before shadowing", proc (): void =
            test "accepts":
              expectNoOffenses("""                def do_something(foo)
                  lambda do
                    puts foo

                    something do
                      foo = 43
                    end
                  end

                  foo = 42
                  puts foo
                end
""".stripIndent)))
        context("and the block is nested within a conditional", proc (): void =
          test """registers an offense without specifying where the reassignment took place""":
            expectOffense("""              def do_something(foo)
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                if baz
                  lambda do
                    foo = 43
                  end
                end

                foo = 42
                puts foo
              end
""".stripIndent)
          context("and the argument was used before shadowing", proc (): void =
            test "accepts":
              expectNoOffenses("""                def do_something(foo)
                  if baz
                    puts foo
                    lambda do
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
""".stripIndent)))))
    context("when multiple arguments are shadowed", proc (): void =
      context("""and one of them shadowed within a lambda while another is shadowed outside""", proc (): void =
        test "registers an offense":
          expectOffense("""            def do_something(foo, bar)
              lambda do
                bar = 42
              end

              foo = 43
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              puts(foo, bar)
            end
""".stripIndent))))
  describe("block argument shadowing", proc (): void =
    context("""when a block local variable is assigned but no argument is shadowed""", proc (): void =
      test "accepts":
        expectNoOffenses("""          numbers = [1, 2, 3]
          numbers.each do |i; j|
            j = i * 2
            puts j
          end
""".stripIndent))
    context("when a single argument is shadowed", proc (): void =
      test "registers an offense":
        expectOffense("""          do_something do |foo|
            foo = 42
            ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
            puts foo
          end
""".stripIndent)
      context("when zsuper is used", proc (): void =
        test "accepts":
          expectNoOffenses("""            do_something do |foo|
              foo = 42
              super
            end
""".stripIndent))
      context("when binding is used", proc (): void =
        test "registers an offense":
          expectOffense("""            do_something do |foo|
              foo = 42
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              binding
            end
""".stripIndent)
        context("when IgnoreImplicitReferences config option is set to true", proc (): void =
          let("cop_config", proc (): void =
            {"IgnoreImplicitReferences": true}.newTable())
          test "accepts":
            expectNoOffenses("""              do_something do |foo|
                foo = 42
                binding
              end
""".stripIndent)))
      context("and the argument is not used", proc (): void =
        test "accepts":
          expectNoOffenses("""            do_something do |foo|
              puts 'done something'
            end
""".stripIndent))
      context("and shadowed within a conditional", proc (): void =
        test """registers an offense without specifying where the reassignment took place""":
          expectOffense("""            do_something do |foo|
                             ^^^ Argument `foo` was shadowed by a local variable before it was used.
              if bar
                foo = 43
              end
              foo = 42
              puts foo
            end
""".stripIndent)
        context("and was used before shadowing", proc (): void =
          test "accepts":
            expectNoOffenses("""              do_something do |foo|
                if bar
                  puts foo
                  foo = 43
                end
                foo = 42
                puts foo
              end
""".stripIndent))
        context("and the argument was not shadowed outside the conditional", proc (): void =
          test "accepts":
            expectNoOffenses("""              do_something do |foo|
                if bar
                  foo = 42
                end

                puts foo
              end
""".stripIndent))
        context("and the conditional occurs after the reassignment", proc (): void =
          test "registers an offense":
            expectOffense("""              do_something do |foo|
                foo = 43
                ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
                if bar
                  foo = 42
                end
                puts foo
              end
""".stripIndent))
        context("and the conditional is nested within a conditional", proc (): void =
          test """registers an offense without specifying where the reassignment took place""":
            expectOffense("""              do_something do |foo|
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                if bar
                  if baz
                    foo = 43
                  end
                end
                foo = 42
                puts foo
              end
""".stripIndent)
          context("and the argument was used before shadowing", proc (): void =
            test "accepts":
              expectNoOffenses("""                do_something do |foo|
                  if bar
                    puts foo
                    if baz
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
""".stripIndent)))
        context("and the conditional is nested within a lambda", proc (): void =
          test """registers an offense without specifying where the reassignment took place""":
            expectOffense("""              do_something do |foo|
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                lambda do
                  if baz
                    foo = 43
                  end
                end
                foo = 42
                puts foo
              end
""".stripIndent)
          context("and the argument was used before shadowing", proc (): void =
            test "accepts":
              expectNoOffenses("""                do_something do |foo|
                  lambda do
                    puts foo
                    if baz
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
""".stripIndent))))
      context("and shadowed within a block", proc (): void =
        test """registers an offense without specifying where the reassignment took place""":
          expectOffense("""            do_something do |foo|
                             ^^^ Argument `foo` was shadowed by a local variable before it was used.
              something { foo = 43 }

              foo = 42
              puts foo
            end
""".stripIndent)
        context("and was used before shadowing", proc (): void =
          test "accepts":
            expectNoOffenses("""              do_something do |foo|
                lambda do
                  puts foo
                  foo = 43
                end

                foo = 42
                puts foo
              end
""".stripIndent))
        context("and the argument was not shadowed outside the block", proc (): void =
          test "accepts":
            expectNoOffenses("""              do_something do |foo|
                something { foo = 43 }

                puts foo
              end
""".stripIndent))
        context("and the block occurs after the reassignment", proc (): void =
          test "registers an offense":
            expectOffense("""              do_something do |foo|
                foo = 43
                ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
                something { foo = 42 }
                puts foo
              end
""".stripIndent))
        context("and the block is nested within a block", proc (): void =
          test """registers an offense without specifying where the reassignment took place""":
            expectOffense("""              do_something do |foo|
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                something do
                  lambda do
                    foo = 43
                  end
                end

                foo = 42
                puts foo
              end
""".stripIndent)
          context("and the argument was used before shadowing", proc (): void =
            test "accepts":
              expectNoOffenses("""                do_something do |foo|
                  lambda do
                    puts foo

                    something do
                      foo = 43
                    end
                  end

                  foo = 42
                  puts foo
                end
""".stripIndent)))
        context("and the block is nested within a conditional", proc (): void =
          test """registers an offense without specifying where the reassignment took place""":
            expectOffense("""              do_something do |foo|
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                if baz
                  lambda do
                    foo = 43
                  end
                end

                foo = 42
                puts foo
              end
""".stripIndent)
          context("and the argument was used before shadowing", proc (): void =
            test "accepts":
              expectNoOffenses("""                do_something do |foo|
                  if baz
                    puts foo
                    lambda do
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
""".stripIndent)))))
    context("when multiple arguments are shadowed", proc (): void =
      context("""and one of them shadowed within a lambda while another is shadowed outside""", proc (): void =
        test "registers an offense":
          expectOffense("""            do_something do |foo, bar|
              lambda do
                bar = 42
              end

              foo = 43
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              puts(foo, bar)
            end
""".stripIndent)))))
