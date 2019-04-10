
import
  rescue_exception, test_tools

suite "RescueException":
  var cop = RescueException()
  test "registers an offense for rescue from Exception":
    expectOffense("""      begin
        something
      rescue Exception
      ^^^^^^^^^^^^^^^^ Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?
        #do nothing
      end
""".stripIndent)
  test "registers an offense for rescue with ::Exception":
    expectOffense("""      begin
        something
      rescue ::Exception
      ^^^^^^^^^^^^^^^^^^ Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?
        #do nothing
      end
""".stripIndent)
  test "registers an offense for rescue with StandardError, Exception":
    expectOffense("""      begin
        something
      rescue StandardError, Exception
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?
        #do nothing
      end
""".stripIndent)
  test "registers an offense for rescue with Exception => e":
    expectOffense("""      begin
        something
      rescue Exception => e
      ^^^^^^^^^^^^^^^^^^^^^ Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?
        #do nothing
      end
""".stripIndent)
  test "does not register an offense for rescue with no class":
    expectNoOffenses("""      begin
        something
        return
      rescue
        file.close
      end
""".stripIndent)
  test "does not register an offense for rescue with no class and => e":
    expectNoOffenses("""      begin
        something
        return
      rescue => e
        file.close
      end
""".stripIndent)
  test "does not register an offense for rescue with other class":
    expectNoOffenses("""      begin
        something
        return
      rescue ArgumentError => e
        file.close
      end
""".stripIndent)
  test "does not register an offense for rescue with other classes":
    expectNoOffenses("""      begin
        something
        return
      rescue EOFError, ArgumentError => e
        file.close
      end
""".stripIndent)
  test "does not register an offense for rescue with a module prefix":
    expectNoOffenses("""      begin
        something
        return
      rescue Test::Exception => e
        file.close
      end
""".stripIndent)
  test "does not crash when the splat operator is used in a rescue":
    expectNoOffenses("""      ERRORS = [Exception]
      begin
        a = 3 / 0
      rescue *ERRORS
        puts e
      end
""".stripIndent)
  test """does not crash when the namespace of a rescued class is in a local variable""":
    expectNoOffenses("""      adapter = current_adapter
      begin
      rescue adapter::ParseError
      end
""".stripIndent)
