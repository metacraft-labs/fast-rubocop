
import
  variable_interpolation, test_tools

suite "VariableInterpolation":
  var cop = VariableInterpolation()
  test "registers an offense for interpolated global variables in string":
    expectOffense("""      puts "this is a #$test"
                       ^^^^^ Replace interpolated variable `$test` with expression `#{$test}`.
""".stripIndent)
  test "registers an offense for interpolated global variables in regexp":
    expectOffense("""      puts /this is a #$test/
                       ^^^^^ Replace interpolated variable `$test` with expression `#{$test}`.
""".stripIndent)
  test "registers an offense for interpolated global variables in backticks":
    expectOffense("""      puts `this is a #$test`
                       ^^^^^ Replace interpolated variable `$test` with expression `#{$test}`.
""".stripIndent)
  test "registers an offense for interpolated regexp nth back references":
    expectOffense("""      puts "this is a #$1"
                       ^^ Replace interpolated variable `$1` with expression `#{$1}`.
""".stripIndent)
  test "registers an offense for interpolated regexp back references":
    expectOffense("""      puts "this is a #$+"
                       ^^ Replace interpolated variable `$+` with expression `#{$+}`.
""".stripIndent)
  test "registers an offense for interpolated instance variables":
    expectOffense("""      puts "this is a #@test"
                       ^^^^^ Replace interpolated variable `@test` with expression `#{@test}`.
""".stripIndent)
  test "registers an offense for interpolated class variables":
    expectOffense("""      puts "this is a #@@t"
                       ^^^ Replace interpolated variable `@@t` with expression `#{@@t}`.
""".stripIndent)
  test "does not register an offense for variables in expressions":
    expectNoOffenses("puts \"this is a #{@test} #{@@t} #{$t} #{$1} #{$+}\"")
  test "autocorrects by adding the missing {}":
    var corrected = autocorrectSource("\"some #@var\"")
    expect(corrected).to(eq("\"some #{@var}\""))
