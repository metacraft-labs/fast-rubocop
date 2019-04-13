
import
  rescue_standard_error, test_tools

RSpec.describe(RescueStandardError, "config", proc (): void =
  var cop = ()
  context("implicit", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "implicit", "SupportedStyles": @["implicit", "explicit"]}.newTable())
    context("when rescuing in a begin block", proc (): void =
      test "accpets rescuing no error class":
        expectNoOffenses("""          begin
            foo
          rescue
            bar
          end
""".stripIndent)
      test "accepts rescuing no error class, assigned to a variable":
        expectNoOffenses("""          begin
            foo
          rescue => e
            bar
          end
""".stripIndent)
      test "accepts rescuing a single error class other than StandardError":
        expectNoOffenses("""          begin
            foo
          rescue BarError
            bar
          end
""".stripIndent)
      test """accepts rescuing a single error class other than StandardError, assigned to a variable""":
        expectNoOffenses("""          begin
            foo
          rescue BarError => e
            bar
          end
""".stripIndent)
      context("when rescuing StandardError by itself", proc (): void =
        test "registers an offense":
          expectOffense("""            begin
              foo
            rescue StandardError
            ^^^^^^^^^^^^^^^^^^^^ Omit the error class when rescuing `StandardError` by itself.
              bar
            end
""".stripIndent)
          expectCorrection("""            begin
              foo
            rescue
              bar
            end
""".stripIndent)
        context("when the error is assigned to a variable", proc (): void =
          test "registers an offense":
            expectOffense("""              begin
                foo
              rescue StandardError => e
              ^^^^^^^^^^^^^^^^^^^^ Omit the error class when rescuing `StandardError` by itself.
                bar
              end
""".stripIndent)
            expectCorrection("""              begin
                foo
              rescue => e
                bar
              end
""".stripIndent)))
      test "accepts rescuing StandardError with other errors":
        expectNoOffenses("""          begin
            foo
          rescue StandardError, BarError
            bar
          rescue BazError, StandardError
            baz
          end
""".stripIndent)
      test """accepts rescuing StandardError with other errors, assigned to a variable""":
        expectNoOffenses("""          begin
            foo
          rescue StandardError, BarError => e
            bar
          rescue BazError, StandardError => e
            baz
          end
""".stripIndent))
    context("when rescuing in a method definition", proc (): void =
      test "accepts rescuing no error class":
        expectNoOffenses("""          def baz
            foo
          rescue
            bar
          end
""".stripIndent)
      test "accepts rescuing no error class, assigned to a variable":
        expectNoOffenses("""          def baz
            foo
          rescue => e
            bar
          end
""".stripIndent)
      test "accepts rescuing a single error other than StandardError":
        expectNoOffenses("""          def baz
            foo
          rescue BarError
            bar
          end
""".stripIndent)
      test """accepts rescuing a single error other than StandardError, assigned to a variable""":
        expectNoOffenses("""          def baz
            foo
          rescue BarError => e
            bar
          end
""".stripIndent)
      context("when rescuing StandardError by itself", proc (): void =
        test "registers an offense":
          expectOffense("""            def foobar
              foo
            rescue StandardError
            ^^^^^^^^^^^^^^^^^^^^ Omit the error class when rescuing `StandardError` by itself.
              bar
            end
""".stripIndent)
          expectCorrection("""            def foobar
              foo
            rescue
              bar
            end
""".stripIndent)
        context("when the error is assigned to a variable", proc (): void =
          test "registers an offense":
            expectOffense("""              def foobar
                foo
              rescue StandardError => e
              ^^^^^^^^^^^^^^^^^^^^ Omit the error class when rescuing `StandardError` by itself.
                bar
              end
""".stripIndent)
            expectCorrection("""              def foobar
                foo
              rescue => e
                bar
              end
""".stripIndent)))
      test "accepts rescuing StandardError with other errors":
        expectNoOffenses("""          def foobar
            foo
          rescue StandardError, BarError
            bar
          rescue BazError, StandardError
            baz
          end
""".stripIndent)
      test """accepts rescuing StandardError with other errors, assigned to a variable""":
        expectNoOffenses("""          def foobar
            foo
          rescue StandardError, BarError => e
            bar
          rescue BazError, StandardError => e
            baz
          end
""".stripIndent))
    test "accepts rescue modifier":
      expectNoOffenses("        foo rescue 42\n".stripIndent))
  context("explicit", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "explicit", "SupportedStyles": @["implicit", "explicit"]}.newTable())
    context("when rescuing in a begin block", proc (): void =
      context("when calling rescue without an error class", proc (): void =
        test "registers an offense":
          expectOffense("""            begin
              foo
            rescue
            ^^^^^^ Avoid rescuing without specifying an error class.
              bar
            end
""".stripIndent)
          expectCorrection("""            begin
              foo
            rescue StandardError
              bar
            end
""".stripIndent)
        context("when the error is assigned to a variable", proc (): void =
          test "registers an offense":
            expectOffense("""              begin
                foo
              rescue => e
              ^^^^^^ Avoid rescuing without specifying an error class.
                bar
              end
""".stripIndent)
            expectCorrection("""              begin
                foo
              rescue StandardError => e
                bar
              end
""".stripIndent)))
      test "accepts rescuing a single error other than StandardError":
        expectNoOffenses("""          begin
            foo
          rescue BarError
            bar
          end
""".stripIndent)
      test """accepts rescuing a single error other than StandardErrorassigned to a variable""":
        expectNoOffenses("""          begin
            foo
          rescue BarError => e
            bar
          end
""".stripIndent)
      test "accepts rescuing StandardError by itself":
        expectNoOffenses("""          begin
            foo
          rescue StandardError
            bar
          end
""".stripIndent)
      test "accepts rescuing StandardError by itself, assigned to a variable":
        expectNoOffenses("""          begin
            foo
          rescue StandardError => e
            bar
          end
""".stripIndent)
      test "accepts rescuing StandardError with other errors":
        expectNoOffenses("""          begin
            foo
          rescue StandardError, BarError
            bar
          rescue BazError, StandardError
            baz
          end
""".stripIndent)
      test """accepts rescuing StandardError with other errors, assigned to a variable""":
        expectNoOffenses("""          begin
            foo
          rescue StandardError, BarError => e
            bar
          rescue BazError, StandardError => e
            baz
          end
""".stripIndent))
    context("when rescuing in a method definition", proc (): void =
      context("when rescue is called without an error class", proc (): void =
        test "registers an offense":
          expectOffense("""            def baz
              foo
            rescue
            ^^^^^^ Avoid rescuing without specifying an error class.
              bar
            end
""".stripIndent)
          expectCorrection("""            def baz
              foo
            rescue StandardError
              bar
            end
""".stripIndent))
      context("when the error is assigned to a variable", proc (): void =
        test "registers an offense":
          expectOffense("""            def baz
              foo
            rescue => e
            ^^^^^^ Avoid rescuing without specifying an error class.
              bar
            end
""".stripIndent)
          expectCorrection("""            def baz
              foo
            rescue StandardError => e
              bar
            end
""".stripIndent))
      test "accepts rescueing a single error other than StandardError":
        expectNoOffenses("""          def baz
            foo
          rescue BarError
            bar
          end
""".stripIndent)
      test """accepts rescueing a single error other than StandardError, assigned to a variable""":
        expectNoOffenses("""          def baz
            foo
          rescue BarError => e
            bar
          end
""".stripIndent)
      test "accepts rescuing StandardError by itself":
        expectNoOffenses("""          def foobar
            foo
          rescue StandardError
            bar
          end
""".stripIndent)
      test "accepts rescuing StandardError by itself, assigned to a variable":
        expectNoOffenses("""          def foobar
            foo
          rescue StandardError => e
            bar
          end
""".stripIndent)
      test "accepts rescuing StandardError with other errors":
        expectNoOffenses("""          def foobar
            foo
          rescue StandardError, BarError
            bar
          rescue BazError, StandardError
            baz
          end
""".stripIndent)
      test """accepts rescuing StandardError with other errors, assigned to a variable""":
        expectNoOffenses("""          def foobar
            foo
          rescue StandardError, BarError => e
            bar
          rescue BazError, StandardError => e
            baz
          end
""".stripIndent))
    test "accepts rescue modifier":
      expectNoOffenses("        foo rescue 42\n".stripIndent)))
