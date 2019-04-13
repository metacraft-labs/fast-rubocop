
import
  option_hash, test_tools

RSpec.describe(OptionHash, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"SuspiciousParamNames": suspiciousNames()}.newTable())
  let("suspicious_names", proc (): void =
    @["options"])
  test "registers an offense":
    expectOffense("""      def some_method(options = {})
                      ^^^^^^^^^^^^ Prefer keyword arguments to options hashes.
        puts some_arg
      end
""".stripIndent)
  context("when the last argument is an options hash named something else", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def steep(flavor, duration, config={})
          mug = config.fetch(:mug)
          prep(flavor, duration, mug)
        end
""".stripIndent)
    context("when the argument name is in the list of suspicious names", proc (): void =
      let("suspicious_names", proc (): void =
        @["options", "config"])
      test "registers an offense":
        expectOffense("""          def steep(flavor, duration, config={})
                                      ^^^^^^^^^ Prefer keyword arguments to options hashes.
            mug = config.fetch(:mug)
            prep(flavor, duration, mug)
          end
""".stripIndent)))
  context("when there are no arguments", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def meditate
          puts true
          puts true
        end
""".stripIndent))
  context("when the last argument is a non-options-hash optional hash", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def cook(instructions, ingredients = { hot: [], cold: [] })
          prep(ingredients)
        end
""".stripIndent))
  context("when passing options hash to super", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def allowed(foo, options = {})
          super
        end
""".stripIndent)
    test "does not register an offense when code exists before call to super":
      expectNoOffenses("""        def allowed(foo, options = {})
          bar

          super
        end
""".stripIndent)
    test "does not register an offense when call to super is in a nested block":
      expectNoOffenses("""        def allowed(foo, options = {})
          5.times do
            super
          end
        end
""".stripIndent)))
