
import
  implicit_string_concatenation, test_tools

suite "ImplicitStringConcatenation":
  var cop = ImplicitStringConcatenation()
  context("on a single string literal", proc (): void =
    test "does not register an offense":
      expectNoOffenses("abc"))
  context("on adjacent string literals on the same line", proc (): void =
    test "registers an offense":
      expectOffense("""        class A; "abc" "def"; end
                 ^^^^^^^^^^^ Combine "abc" and "def" into a single string literal, rather than using implicit string concatenation.
        class B; 'ghi' 'jkl'; end
                 ^^^^^^^^^^^ Combine 'ghi' and 'jkl' into a single string literal, rather than using implicit string concatenation.
""".stripIndent))
  context("on adjacent string literals on different lines", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        array = [
          'abc'\
          'def'
        ]
""".stripIndent))
  context("when the string literals contain newlines", proc (): void =
    test "registers an offense":
      inspectSource("        def method; \"ab\nc\" \"de\nf\"; end\n".stripIndent)
      expect(cop().offenses.size).to(eq(1)))
  context("on a string with interpolations", proc (): void =
    test "does register an offense":
      expectNoOffenses("array = [\"abc#{something}def#{something_else}\"]"))
  context("when inside an array", proc (): void =
    test "notes that the strings could be separated by a comma instead":
      expectOffense("""        array = ["abc" "def"]
                 ^^^^^^^^^^^ Combine "abc" and "def" into a single string literal, rather than using implicit string concatenation. Or, if they were intended to be separate array elements, separate them with a comma.
""".stripIndent))
  context("when in a method call\'s argument list", proc (): void =
    test "notes that the strings could be separated by a comma instead":
      expectOffense("""        method("abc" "def")
               ^^^^^^^^^^^ Combine "abc" and "def" into a single string literal, rather than using implicit string concatenation. Or, if they were intended to be separate method arguments, separate them with a comma.
""".stripIndent))
