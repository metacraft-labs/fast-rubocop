
import
  types

import
  accessor_method_name, test_tools

suite "AccessorMethodName":
  var cop = AccessorMethodName()
  test "registers an offense for method get_... with no args":
    expectOffense("""      def get_attr
          ^^^^^^^^ Do not prefix reader method names with `get_`.
        # ...
      end
""".stripIndent)
  test "registers an offense for singleton method get_... with no args":
    expectOffense("""      def self.get_attr
               ^^^^^^^^ Do not prefix reader method names with `get_`.
        # ...
      end
""".stripIndent)
  test "accepts method get_something with args":
    expectNoOffenses("""      def get_something(arg)
        # ...
      end
""".stripIndent)
  test "accepts singleton method get_something with args":
    expectNoOffenses("""      def self.get_something(arg)
        # ...
      end
""".stripIndent)
  test "registers an offense for method set_something with one arg":
    expectOffense("""      def set_attr(arg)
          ^^^^^^^^ Do not prefix writer method names with `set_`.
        # ...
      end
""".stripIndent)
  test "registers an offense for singleton method set_... with one args":
    expectOffense("""      def self.set_attr(arg)
               ^^^^^^^^ Do not prefix writer method names with `set_`.
        # ...
      end
""".stripIndent)
  test "accepts method set_something with no args":
    expectNoOffenses("""      def set_something
        # ...
      end
""".stripIndent)
  test "accepts singleton method set_something with no args":
    expectNoOffenses("""      def self.set_something
        # ...
      end
""".stripIndent)
  test "accepts method set_something with two args":
    expectNoOffenses("""      def set_something(arg1, arg2)
        # ...
      end
""".stripIndent)
  test "accepts singleton method set_something with two args":
    expectNoOffenses("""      def self.get_something(arg1, arg2)
        # ...
      end
""".stripIndent)
