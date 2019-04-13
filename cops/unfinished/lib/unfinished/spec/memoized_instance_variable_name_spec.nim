
import
  memoized_instance_variable_name, test_tools

RSpec.describe(MemoizedInstanceVariableName, "config", proc (): void =
  var cop = ()
  context("with default EnforcedStyleForLeadingUnderscores => disallowed", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyleForLeadingUnderscores": "disallowed"}.newTable())
    context("memoized variable does not match method name", proc (): void =
      test "registers an offense":
        expectOffense("""        def x
          @my_var ||= :foo
          ^^^^^^^ Memoized variable `@my_var` does not match method name `x`. Use `@x` instead.
        end
""".stripIndent))
    context("memoized variable does not match class method name", proc (): void =
      test "registers an offense":
        expectOffense("""        def self.x
          @my_var ||= :foo
          ^^^^^^^ Memoized variable `@my_var` does not match method name `x`. Use `@x` instead.
        end
""".stripIndent))
    context("memoized variable does not match method name during assignment", proc (): void =
      test "registers an offense":
        expectOffense("""        foo = def x
          @y ||= :foo
          ^^ Memoized variable `@y` does not match method name `x`. Use `@x` instead.
        end
""".stripIndent))
    context("memoized variable does not match method name for block", proc (): void =
      test "registers an offense":
        expectOffense("""        def x
          @y ||= begin
          ^^ Memoized variable `@y` does not match method name `x`. Use `@x` instead.
            :foo
          end
        end
""".stripIndent))
    context("memoized variable after other code does not match method name", proc (): void =
      test "registers an offense":
        expectOffense("""          def foo
            helper_variable = something_we_need_to_calculate_foo
            @bar ||= calculate_expensive_thing(helper_variable)
            ^^^^ Memoized variable `@bar` does not match method name `foo`. Use `@foo` instead.
          end
""".stripIndent)
      test "registers an offense for a predicate method":
        expectOffense("""          def foo?
            helper_variable = something_we_need_to_calculate_foo
            @bar ||= calculate_expensive_thing(helper_variable)
            ^^^^ Memoized variable `@bar` does not match method name `foo?`. Use `@foo` instead.
          end
""".stripIndent)
      test "registers an offense for a bang method":
        expectOffense("""          def foo!
            helper_variable = something_we_need_to_calculate_foo
            @bar ||= calculate_expensive_thing(helper_variable)
            ^^^^ Memoized variable `@bar` does not match method name `foo!`. Use `@foo` instead.
          end
""".stripIndent))
    context("memoized variable matches method name", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          def x
            @x ||= :foo
          end
""".stripIndent)
      test "does not registers an offense when method has leading `_`":
        expectNoOffenses("""          def _foo
            @foo ||= :foo
          end
""".stripIndent)
      test "does not register an offense with a leading `_` for both names":
        expectNoOffenses("""          def _foo
            @_foo ||= :foo
          end
""".stripIndent)
      context("memoized variable matches method name during assignment", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            foo = def y
              @y ||= :foo
            end
""".stripIndent))
      context("memoized variable matches method name for block", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            def z
              @z ||= begin
                :foo
              end
            end
""".stripIndent))
      context("non-memoized variable does not match method name", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            def a
              x ||= :foo
            end
""".stripIndent))
      context("memoized variable matches predicate method name", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            def a?
              @a ||= :foo
            end
""".stripIndent))
      context("memoized variable matches bang method name", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            def a!
              @a ||= :foo
            end
""".stripIndent))
      context("code follows memoized variable assignment", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            def a
              @b ||= :foo
              call_something_else
            end
""".stripIndent)
        context("memoized variable after other code", proc (): void =
          test "does not register an offense":
            expectNoOffenses("""              def foo
                helper_variable = something_we_need_to_calculate_foo
                @foo ||= calculate_expensive_thing(helper_variable)
              end
""".stripIndent))
        context("instance variables in initialize methods", proc (): void =
          test "does not register an offense":
            expectNoOffenses("""              def initialize
                @files_with_offenses ||= {}
              end
""".stripIndent)))))
  context("EnforcedStyleForLeadingUnderscores: required", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyleForLeadingUnderscores": "required"}.newTable())
    test "registers an offense when names match but missing a leading _":
      expectOffense("""      def foo
        @foo ||= :foo
        ^^^^ Memoized variable `@foo` does not start with `_`. Use `@_foo` instead.
      end
""".stripIndent)
    test "registers an offense when it has leading `_` but names do not match":
      expectOffense("""      def foo
        @_my_var ||= :foo
        ^^^^^^^^ Memoized variable `@_my_var` does not match method name `foo`. Use `@_foo` instead.
      end
""".stripIndent)
    test "does not register an offense with a leading `_` for both names":
      expectNoOffenses("""        def _foo
          @_foo ||= :foo
        end
""".stripIndent))
  context("EnforcedStyleForLeadingUnderscores: optional", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyleForLeadingUnderscores": "optional"}.newTable())
    context("memoized variable matches method name", proc (): void =
      test "does not register an offense with a leading underscore":
        expectNoOffenses("""          def x
            @_x ||= :foo
          end
""".stripIndent)
      test "does not register an offense without a leading underscore":
        expectNoOffenses("""          def x
            @x ||= :foo
          end
""".stripIndent)
      test "does not register an offense with a leading `_` for both names":
        expectNoOffenses("""          def _x
            @_x ||= :foo
          end
""".stripIndent)
      test "does not register an offense with a leading `_` for method name":
        expectNoOffenses("""          def _x
            @x ||= :foo
          end
""".stripIndent))))
