
import
  unneeded_require_statement, test_tools

RSpec.describe(UnneededRequireStatement, "config", proc (): void =
  var cop = ()
  test "registers an offense when using `require \'enumerator\'`":
    expectOffense("""      require 'enumerator'
      ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
""".stripIndent)
  test "autocorrects remove unnecessary require statement":
    var newSource = autocorrectSource("""      require 'enumerator'
      require 'uri'
""".stripIndent)
    expect(newSource).to(eq("      require \'uri\'\n".stripIndent)))
