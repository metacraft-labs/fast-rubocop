
import
  module_function, test_tools

RSpec.describe(ModuleFunction, "config", proc (): void =
  var cop = ()
  context("when enforced style is `module_function`", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "module_function"}.newTable())
    test "registers an offense for `extend self` in a module":
      expectOffense("""        module Test
          extend self
          ^^^^^^^^^^^ Use `module_function` instead of `extend self`.
          def test; end
        end
""".stripIndent)
      expectCorrection("""        module Test
          module_function
          def test; end
        end
""".stripIndent)
    test "accepts for `extend self` in a module with private methods":
      expectNoOffenses("""        module Test
          extend self
          def test; end
          private
          def test_private;end
        end
""".stripIndent)
    test "accepts for `extend self` in a module with declarative private":
      expectNoOffenses("""        module Test
          extend self
          def test; end
          private :test
        end
""".stripIndent)
    test "accepts `extend self` in a class":
      expectNoOffenses("""        class Test
          extend self
        end
""".stripIndent))
  context("when enforced style is `extend_self`", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "extend_self"}.newTable())
    test "registers an offense for `module_function` without an argument":
      expectOffense("""        module Test
          module_function
          ^^^^^^^^^^^^^^^ Use `extend self` instead of `module_function`.
          def test; end
        end
""".stripIndent)
      expectCorrection("""        module Test
          extend self
          def test; end
        end
""".stripIndent)
    test "accepts module_function with an argument":
      expectNoOffenses("""        module Test
          def test; end
          module_function :test
        end
""".stripIndent)))
