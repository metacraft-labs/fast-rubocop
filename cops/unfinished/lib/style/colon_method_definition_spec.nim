
import
  types

import
  colon_method_definition, test_tools

suite "ColonMethodDefinition":
  var cop = ColonMethodDefinition()
  test "accepts a class method defined using .":
    expectNoOffenses("""      class Foo
        def self.bar
          something
        end
      end
""".stripIndent)
  context("using self", proc () =
    test "registers an offense for a class method defined using ::":
      expectOffense("""        class Foo
          def self::bar
                  ^^ Do not use `::` for defining class methods.
            something
          end
        end
""".stripIndent)
      expectCorrection("""        class Foo
          def self.bar
            something
          end
        end
""".stripIndent))
  context("using the class name", proc () =
    test "registers an offense for a class method defined using ::":
      expectOffense("""        class Foo
          def Foo::bar
                 ^^ Do not use `::` for defining class methods.
            something
          end
        end
""".stripIndent)
      expectCorrection("""        class Foo
          def Foo.bar
            something
          end
        end
""".stripIndent))
