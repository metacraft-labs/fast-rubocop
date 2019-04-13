
import
  types

import
  class_and_module_camel_case, test_tools

suite "ClassAndModuleCamelCase":
  var cop = ClassAndModuleCamelCase()
  test "registers an offense for underscore in class and module name":
    expectOffense("""      class My_Class
            ^^^^^^^^ Use CamelCase for classes and modules.
      end

      module My_Module
             ^^^^^^^^^ Use CamelCase for classes and modules.
      end
""".stripIndent)
  test "is not fooled by qualified names":
    expectOffense("""      class Top::My_Class
            ^^^^^^^^^^^^^ Use CamelCase for classes and modules.
      end

      module My_Module::Ala
             ^^^^^^^^^^^^^^ Use CamelCase for classes and modules.
      end
""".stripIndent)
  test "accepts CamelCase names":
    expectNoOffenses("""      class MyClass
      end

      module Mine
      end
""".stripIndent)
