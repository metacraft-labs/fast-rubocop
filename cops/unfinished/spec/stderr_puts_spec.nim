
import
  stderr_puts, test_tools

suite "StderrPuts":
  var cop = StderrPuts()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when using `$stderr.puts(\'hello\')`":
    expectOffense("""      $stderr.puts('hello')
      ^^^^^^^^^^^^ Use `warn` instead of `$stderr.puts` to allow such output to be disabled.
""".stripIndent)
  test "autocorrects `warn(\'hello\')`":
    var newSource = autocorrectSource("$stderr.puts(\'hello\')")
    expect(newSource).to(eq("warn(\'hello\')"))
