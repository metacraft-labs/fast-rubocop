
import
  nested_percent_literal, test_tools

suite "NestedPercentLiteral":
  var cop = NestedPercentLiteral()
  test "registers no offense for empty array":
    expectNoOffenses("%i[]")
  test "registers no offense for array":
    expectNoOffenses("%i[a b c d xyz]")
  test "registers no offense for percent modifier character in isolation":
    expectNoOffenses("%i[% %i %I %q %Q %r %s %w %W %x]")
  test "registers no offense for nestings under percent":
    expectNoOffenses("%[a b %[c d] xyz]")
    expectNoOffenses("%[a b %i[c d] xyz]")
  test "registers no offense for percents in the middle of literals":
    expectNoOffenses("%w[1%+ 2]")
  test "registers offense for nested percent literals":
    expectOffense("""      %i[a b %i[c d] xyz]
      ^^^^^^^^^^^^^^^^^^^ Within percent literals, nested percent literals do not function and may be unwanted in the result.
""".stripIndent)
  test "registers offense for repeated nested percent literals":
    expectOffense("""      %i[a b %i[c d] %i[xyz]]
      ^^^^^^^^^^^^^^^^^^^^^^^ Within percent literals, nested percent literals do not function and may be unwanted in the result.
""".stripIndent)
  test "registers offense for multiply nested percent literals":
    expectOffense("""      %i[a %i[b %i[c d]] xyz]
      ^^^^^^^^^^^^^^^^^^^^^^^ Within percent literals, nested percent literals do not function and may be unwanted in the result.
""".stripIndent)
  context("when handling invalid UTF8 byte sequence", proc (): void =
    test "registers no offense for array":
      expectNoOffenses("%W[\\xff]")
    test "registers offense for nested percent literal":
      expectOffense("""        %W[\xff %W[]]
        ^^^^^^^^^^^^^ Within percent literals, nested percent literals do not function and may be unwanted in the result.
""".stripIndent))
