
import
  documentation_method, test_tools

RSpec.describe(DocumentationMethod, "config", proc (): void =
  var cop = ()
  let("require_for_non_public_methods", proc (): void =
    false)
  let("config", proc (): void =
    Config.new())
  context("when declaring methods outside a class", proc (): void =
    context("without documentation comment", proc (): void =
      context("when method is public", proc (): void =
        test "registers an offense":
          expectOffense("""            def foo
            ^^^^^^^ Missing method documentation comment.
              puts 'bar'
            end
""".stripIndent)
        test "registers an offense with `end` on the same line":
          expectOffense("""            def method; end
            ^^^^^^^^^^^^^^^ Missing method documentation comment.
""".stripIndent))
      context("when method is private", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            private

            def foo
              puts 'bar'
            end
""".stripIndent)
        test "does not register an offense with `end` on the same line":
          expectNoOffenses("""            private

            def foo; end
""".stripIndent)
        test "does not register an offense with inline `private`":
          expectNoOffenses("""            private def foo
              puts 'bar'
            end
""".stripIndent)
        test "does not register an offense with inline `private` and `end`":
          expectNoOffenses("private def method; end")
        context("when required for non-public methods", proc (): void =
          let("require_for_non_public_methods", proc (): void =
            true)
          test "registers an offense":
            expectOffense("""              private

              def foo
              ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
""".stripIndent)
          test "registers an offense with `end` on the same line":
            expectOffense("""              private

              def foo; end
              ^^^^^^^^^^^^ Missing method documentation comment.
""".stripIndent)
          test "registers an offense with inline `private`":
            expectOffense("""              private def foo
                      ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
""".stripIndent)
          test "registers an offense with inline `private` and `end`":
            expectOffense("""              private def method; end
                      ^^^^^^^^^^^^^^^ Missing method documentation comment.
""".stripIndent)))
      context("when method is protected", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            protected

            def foo
              puts 'bar'
            end
""".stripIndent)
        test "does not register an offense with inline `protected`":
          expectNoOffenses("""            protected def foo
              puts 'bar'
            end
""".stripIndent)
        context("when required for non-public methods", proc (): void =
          let("require_for_non_public_methods", proc (): void =
            true)
          test "registers an offense":
            expectOffense("""              protected

              def foo
              ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
""".stripIndent)
          test "registers an offense with inline `protected`":
            expectOffense("""              protected def foo
                        ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
""".stripIndent))))
    context("with documentation comment", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          # Documentation
          def foo
            puts 'bar'
          end
""".stripIndent)
      test "does not register an offense with `end` on the same line":
        expectNoOffenses("""          # Documentation
          def foo; end
""".stripIndent))
    context("with both public and private methods", proc (): void =
      context("when the public method has no documentation", proc (): void =
        test "registers an offense":
          expectOffense("""            def foo
            ^^^^^^^ Missing method documentation comment.
              puts 'bar'
            end

            private

            def baz
              puts 'bar'
            end
""".stripIndent))
      context("when the public method has documentation", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            # Documentation
            def foo
              puts 'bar'
            end

            private

            def baz
              puts 'bar'
            end
""".stripIndent))
      context("when required for non-public methods", proc (): void =
        let("require_for_non_public_methods", proc (): void =
          true)
        test "registers an offense":
          expectOffense("""            # Documentation
            def foo
              puts 'bar'
            end

            private

            def baz
            ^^^^^^^ Missing method documentation comment.
              puts 'bar'
            end
""".stripIndent)))
    context("when declaring methods in a class", proc (): void =
      context("without documentation comment", proc (): void =
        context("wheh method is public", proc (): void =
          test "registers an offense":
            expectOffense("""              class Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
""".stripIndent)
          test "registers an offense with `end` on the same line":
            expectOffense("""              class Foo
                def method; end
                ^^^^^^^^^^^^^^^ Missing method documentation comment.
              end
""".stripIndent))
        context("when method is private", proc (): void =
          test "does not register an offense":
            expectNoOffenses("""              class Foo
                private

                def bar
                  puts 'baz'
                end
              end
""".stripIndent)
          test "does not register an offense with inline `private`":
            expectNoOffenses("""              class Foo
                private def bar
                  puts 'baz'
                end
              end
""".stripIndent)
          test "does not register an offense with `end` on the same line":
            expectNoOffenses("""              class Foo
                private

                def bar; end
              end
""".stripIndent)
          test "does not register an offense with inline `private` and `end`":
            expectNoOffenses("""              class Foo
                private def bar; end
              end
""".stripIndent)
          context("when required for non-public methods", proc (): void =
            let("require_for_non_public_methods", proc (): void =
              true)
            test "registers an offense":
              expectOffense("""                class Foo
                  private

                  def bar
                  ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
""".stripIndent)
            test "registers an offense with inline `private`":
              expectOffense("""                class Foo
                  private def bar
                          ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
""".stripIndent)
            test "registers an offense with `end` on the same line":
              expectOffense("""                class Foo
                  private

                  def bar; end
                  ^^^^^^^^^^^^ Missing method documentation comment.
                end
""".stripIndent)
            test "registers an offense with inline `private` and `end`":
              expectOffense("""                class Foo
                  private def bar; end
                          ^^^^^^^^^^^^ Missing method documentation comment.
                end
""".stripIndent))))
      context("with documentation comment", proc (): void =
        context("when method is public", proc (): void =
          test "does not register an offense":
            expectNoOffenses("""              class Foo
                # Documentation
                def bar
                  puts 'baz'
                end
              end
""")
          test "does not register an offense with `end` on the same line":
            expectNoOffenses("""              class Foo
                # Documentation
                def bar; end
              end
""".stripIndent)))
      context("with annotation comment", proc (): void =
        test "registers an offense":
          expectOffense("""            class Foo
              # FIXME: offense
              def bar
              ^^^^^^^ Missing method documentation comment.
                puts 'baz'
              end
            end
""".stripIndent))
      context("with directive comment", proc (): void =
        test "registers an offense":
          expectOffense("""            class Foo
              # rubocop:disable Style/For
              def bar
              ^^^^^^^ Missing method documentation comment.
                puts 'baz'
              end
            end
""".stripIndent))
      context("with both public and private methods", proc (): void =
        context("when the public method has no documentation", proc (): void =
          test "registers an offense":
            expectOffense("""              class Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end

                private

                def baz
                  puts 'baz'
                end
              end
""".stripIndent))
        context("when the public method has documentation", proc (): void =
          test "does not register an offense":
            expectNoOffenses("""              class Foo
                # Documentation
                def bar
                  puts 'baz'
                end

                private

                def baz
                  puts 'baz'
                end
              end
""".stripIndent))
        context("when required for non-public methods", proc (): void =
          let("require_for_non_public_methods", proc (): void =
            true)
          test "registers an offense":
            expectOffense("""              class Foo
                # Documentation
                def bar
                  puts 'baz'
                end

                private

                def baz
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
""".stripIndent))))
    context("when declaring methods in a module", proc (): void =
      context("without documentation comment", proc (): void =
        context("when method is public", proc (): void =
          test "registers an offense":
            expectOffense("""              module Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
""".stripIndent)
          test "registers an offense with `end` on the same line":
            expectOffense("""              module Foo
                def method; end
                ^^^^^^^^^^^^^^^ Missing method documentation comment.
              end
""".stripIndent))
        context("when method is private", proc (): void =
          test "does not register an offense":
            expectNoOffenses("""              module Foo
                private

                def bar
                  puts 'baz'
                end
              end
""".stripIndent)
          test "does not register an offense with inline `private`":
            expectNoOffenses("""              module Foo
                private def bar
                  puts 'baz'
                end
              end
""".stripIndent)
          test "does not register an offense with `end` on the same line":
            expectNoOffenses("""              module Foo
                private

                def bar; end
              end
""".stripIndent)
          test "does not register an offense with inline `private` and `end`":
            expectNoOffenses("""              module Foo
                private def bar; end
              end
""".stripIndent)
          context("when required for non-public methods", proc (): void =
            let("require_for_non_public_methods", proc (): void =
              true)
            test "registers an offense":
              expectOffense("""                module Foo
                  private

                  def bar
                  ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
""".stripIndent)
            test "registers an offense with inline `private`":
              expectOffense("""                module Foo
                  private def bar
                          ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
""".stripIndent)
            test "registers an offense with `end` on the same line":
              expectOffense("""                module Foo
                  private

                  def bar; end
                  ^^^^^^^^^^^^ Missing method documentation comment.
                end
""".stripIndent)
            test "registers an offense with inline `private` and `end`":
              expectOffense("""                module Foo
                  private def bar; end
                          ^^^^^^^^^^^^ Missing method documentation comment.
                end
""".stripIndent)))
        context("when method is module_function", proc (): void =
          test "registers an offense for inline def":
            expectOffense("""              module Foo
                module_function def bar
                ^^^^^^^^^^^^^^^^^^^^^^^ Missing method documentation comment.
                end
              end
""".stripIndent)
          test "registers an offense for separate def":
            expectOffense("""              module Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                end

                module_function :bar
              end
""".stripIndent)))
      context("with documentation comment", proc (): void =
        context("when method is public", proc (): void =
          test "does not register an offense":
            expectNoOffenses("""              module Foo
                # Documentation
                def bar
                  puts 'baz'
                end
              end
""".stripIndent)
          test "does not register an offense with `end` on the same line":
            expectNoOffenses("""              module Foo
                # Documentation
                def bar; end
              end
""".stripIndent))
        context("when method is module_function", proc (): void =
          test "does not register an offense for inline def":
            expectNoOffenses("""              module Foo
                # Documentation
                module_function def bar; end
              end
""".stripIndent)
          test "does not register an offense for separate def":
            expectNoOffenses("""              module Foo
                # Documentation
                def bar; end

                module_function :bar
              end
""".stripIndent)))
      context("with both public and private methods", proc (): void =
        context("when the public method has no documentation", proc (): void =
          test "registers an offense":
            expectOffense("""              module Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end

                private

                def baz
                  puts 'baz'
                end
              end
""".stripIndent))
        context("when the public method has documentation", proc (): void =
          test "does not register an offense":
            expectNoOffenses("""              module Foo
                # Documentation
                def bar
                  puts 'baz'
                end

                private

                def baz
                  puts 'baz'
                end
              end
""".stripIndent))
        context("when required for non-public methods", proc (): void =
          let("require_for_non_public_methods", proc (): void =
            true)
          test "registers an offense":
            expectOffense("""              module Foo
                # Documentation
                def bar
                  puts 'baz'
                end

                private

                def baz
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
""".stripIndent))))
    context("when declaring methods for class instance", proc (): void =
      context("without documentation comment", proc (): void =
        test "registers an offense":
          expectOffense("""            class Foo; end

            foo = Foo.new

            def foo.bar
            ^^^^^^^^^^^ Missing method documentation comment.
              puts 'baz'
            end
""".stripIndent)
        test "registers an offense with `end` on the same line":
          expectOffense("""            class Foo; end

            foo = Foo.new

            def foo.bar; end
            ^^^^^^^^^^^^^^^^ Missing method documentation comment.
""".stripIndent))
      context("with documentation comment", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            class Foo; end

            foo = Foo.new

            # Documentation
            def foo.bar
              puts 'baz'
            end
""".stripIndent)
        test "does not register an offense with `end` on the same line":
          expectNoOffenses("""            class Foo; end

            foo = Foo.new

            # Documentation
            def foo.bar; end
""".stripIndent)
        context("when method is private", proc (): void =
          test "does not register an offense with `end` on the same line":
            expectNoOffenses("""              class Foo; end

              foo = Foo.bar

              private

              def foo.bar; end
""".stripIndent)
          test "does not register an offense":
            expectNoOffenses("""              class Foo; end

              foo = Foo.new

              private

              def foo.bar
                puts 'baz'
              end
""".stripIndent)
          test "does not register an offense with inline `private` and `end`":
            expectNoOffenses("""              class Foo; end

              foo = Foo.new

              private def foo.bar; end
""".stripIndent)
          test "does not register an offense with inline `private`":
            expectNoOffenses("""              class Foo; end

              foo = Foo.new

              private def foo.bar
                puts 'baz'
              end
""".stripIndent)
          context("when required for non-public methods", proc (): void =
            let("require_for_non_public_methods", proc (): void =
              true)
            test "registers an offense with `end` on the same line":
              expectOffense("""                class Foo; end

                foo = Foo.bar

                private

                def foo.bar; end
                ^^^^^^^^^^^^^^^^ Missing method documentation comment.
""".stripIndent)
            test "registers an offense":
              expectOffense("""                class Foo; end

                foo = Foo.new

                private

                def foo.bar
                ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
""".stripIndent)
            test "registers an offense with inline `private` and `end`":
              expectOffense("""                class Foo; end

                foo = Foo.new

                private def foo.bar; end
                        ^^^^^^^^^^^^^^^^ Missing method documentation comment.
""".stripIndent)
            test "registers an offense with inline `private`":
              expectOffense("""                class Foo; end

                foo = Foo.new

                private def foo.bar
                        ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
""".stripIndent)))
        context("with both public and private methods", proc (): void =
          context("when the public method has no documentation", proc (): void =
            test "registers an offense":
              expectOffense("""                class Foo; end

                foo = Foo.new

                def foo.bar
                ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end

                private

                def foo.baz
                  puts 'baz'
                end
""".stripIndent))
          context("when the public method has documentation", proc (): void =
            test "does not register an offense":
              expectNoOffenses("""                class Foo; end

                foo = Foo.new

                # Documentation
                def foo.bar
                  puts 'baz'
                end

                private

                def foo.baz
                  puts 'baz'
                end
""".stripIndent))
          context("when required for non-public methods", proc (): void =
            let("require_for_non_public_methods", proc (): void =
              true)
            test "registers an offense":
              expectOffense("""                class Foo; end

                foo = Foo.new

                # Documentation
                def foo.bar
                  puts 'baz'
                end

                private

                def foo.baz
                ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
""".stripIndent)))))))
