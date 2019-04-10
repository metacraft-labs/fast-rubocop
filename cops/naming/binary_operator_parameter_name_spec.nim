
import
  types

import
  binary_operator_parameter_name, test_tools

suite "BinaryOperatorParameterName":
  var cop = BinaryOperatorParameterName()
  test "registers an offense for `#+` when argument is not named other":
    expectOffense("""        def +(foo); end
              ^^^ When defining the `+` operator, name its argument `other`.
""".stripIndent)
  test "registers an offense for `#eql?` when argument is not named other":
    expectOffense("""        def eql?(foo); end
                 ^^^ When defining the `eql?` operator, name its argument `other`.
""".stripIndent)
  test "registers an offense for `#equal?` when argument is not named other":
    expectOffense("""        def equal?(foo); end
                   ^^^ When defining the `equal?` operator, name its argument `other`.
""".stripIndent)
  test "works properly even if the argument not surrounded with braces":
    expectOffense("""      def + another
            ^^^^^^^ When defining the `+` operator, name its argument `other`.
        another
      end
""".stripIndent)
  test "does not register an offense for arg named other":
    expectNoOffenses("""      def +(other)
        other
      end
""".stripIndent)
  test "does not register an offense for arg named _other":
    expectNoOffenses("""      def <=>(_other)
        0
      end
""".stripIndent)
  test "does not register an offense for []":
    expectNoOffenses("""      def [](index)
        other
      end
""".stripIndent)
  test "does not register an offense for []=":
    expectNoOffenses("""      def []=(index, value)
        other
      end
""".stripIndent)
  test "does not register an offense for <<":
    expectNoOffenses("""      def <<(cop)
        other
      end
""".stripIndent)
  test "does not register an offense for ===":
    expectNoOffenses("""      def ===(string)
        string
      end
""".stripIndent)
  test "does not register an offense for non binary operators":
    expectNoOffenses("""      def -@; end
                    # This + is not a unary operator. It can only be
                    # called with dot notation.
      def +; end
      def *(a, b); end # Quite strange, but legal ruby.
      def `(cmd); end
""".stripIndent)
