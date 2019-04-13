
import
  handle_exceptions, test_tools

suite "HandleExceptions":
  var cop = HandleExceptions()
  test "registers an offense for empty rescue block":
    expectOffense("""      begin
        something
      rescue
      ^^^^^^ Do not suppress exceptions.
        #do nothing
      end
""".stripIndent)
  test "does not register an offense for rescue with body":
    expectNoOffenses("""      begin
        something
        return
      rescue
        file.close
      end
""".stripIndent)
