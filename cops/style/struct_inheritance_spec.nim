
import
  types

import
  struct_inheritance, test_tools

suite "StructInheritance":
  var cop = StructInheritance()
  test "registers an offense when extending instance of Struct":
    expectOffense("""      class Person < Struct.new(:first_name, :last_name)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`.
      end
""".stripIndent)
  test "registers an offense when extending instance of Struct with do ... end":
    expectOffense("""      class Person < Struct.new(:first_name, :last_name) do end
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`.
      end
""".stripIndent)
  test "accepts plain class":
    expectNoOffenses("""      class Person
      end
""".stripIndent)
  test "accepts extending DelegateClass":
    expectNoOffenses("""      class Person < DelegateClass(Animal)
      end
""".stripIndent)
  test "accepts assignment to Struct.new":
    expectNoOffenses("Person = Struct.new(:first_name, :last_name)")
