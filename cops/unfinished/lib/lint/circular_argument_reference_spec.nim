
import
  types

import
  circular_argument_reference, test_tools

suite "CircularArgumentReference":
  var cop = CircularArgumentReference()
  describe("circular argument references in ordinal arguments", proc () =
    context("when the method contains a circular argument reference", proc () =
      test "registers an offense":
        expectOffense("""            def omg_wow(msg = msg)
                              ^^^ Circular argument reference - `msg`.
              puts msg
            end
""".stripIndent))
    context("when the method does not contain a circular argument reference", proc () =
      test "does not register an offense":
        expectNoOffenses("""          def omg_wow(msg)
            puts msg
          end
""".stripIndent))
    context("when the seemingly-circular default value is a method call", proc () =
      test "does not register an offense":
        expectNoOffenses("""          def omg_wow(msg = self.msg)
            puts msg
          end
""".stripIndent)))
  describe("circular argument references in keyword arguments", proc () =
    context("when the keyword argument is not circular", proc () =
      test "does not register an offense":
        expectNoOffenses("""          def some_method(some_arg: nil)
            puts some_arg
          end
""".stripIndent))
    context("when the keyword argument is not circular, and calls a method", proc () =
      test "does not register an offense":
        expectNoOffenses("""          def some_method(some_arg: some_method)
            puts some_arg
          end
""".stripIndent))
    context("when there is one circular argument reference", proc () =
      test "registers an offense":
        expectOffense("""          def some_method(some_arg: some_arg)
                                    ^^^^^^^^ Circular argument reference - `some_arg`.
            puts some_arg
          end
""".stripIndent))
    context("""when the keyword argument is not circular, but calls a method of its own class with a self specification""", proc () =
      test "does not register an offense":
        expectNoOffenses("""          def puts_value(value: self.class.value, smile: self.smile)
            puts value
          end
""".stripIndent))
    context("""when the keyword argument is not circular, but calls a method of some other object with the same name""", proc () =
      test "does not register an offense":
        expectNoOffenses("""          def puts_length(length: mystring.length)
            puts length
          end
""".stripIndent))
    context("when there are multiple offensive keyword arguments", proc () =
      test "registers an offense":
        expectOffense("""          def some_method(some_arg: some_arg, other_arg: other_arg)
                                    ^^^^^^^^ Circular argument reference - `some_arg`.
                                                         ^^^^^^^^^ Circular argument reference - `other_arg`.
            puts [some_arg, other_arg]
          end
""".stripIndent)))
