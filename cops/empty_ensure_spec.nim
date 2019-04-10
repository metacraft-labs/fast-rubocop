
import
  empty_ensure, test_tools

suite "EmptyEnsure":
  var cop = EmptyEnsure()
  test "registers an offense for empty ensure":
    expectOffense("""      begin
        something
      ensure
      ^^^^^^ Empty `ensure` block detected.
      end
""".stripIndent)
  test "autocorrects for empty ensure":
    var corrected = autocorrectSource("""      begin
        something
      ensure
      end
""".stripIndent)
    expect(corrected).to(eq("""      begin
        something

      end
""".stripIndent))
  test "does not register an offense for non-empty ensure":
    expectNoOffenses("""      begin
        something
        return
      ensure
        file.close
      end
""".stripIndent)
