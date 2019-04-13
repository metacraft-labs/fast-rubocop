
import
  string_hash_keys, test_tools

suite "StringHashKeys":
  var cop = StringHashKeys()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when using strings as keys":
    expectOffense("""      { 'one' => 1 }
        ^^^^^ Prefer symbols instead of strings as hash keys.
""".stripIndent)
  test "registers an offense when using strings as keys mixed with other keys":
    expectOffense("""      { 'one' => 1, two: 2, 3 => 3 }
        ^^^^^ Prefer symbols instead of strings as hash keys.
""".stripIndent)
  test "autocorrects strings as keys into symbols":
    var newSource = autocorrectSource("{ \'one\' => 1 }")
    expect(newSource).to(eq("{ :one => 1 }"))
  test "autocorrects strings as keys mixed with other keys into symbols":
    var newSource = autocorrectSource("{ \'one\' => 1, two: 2, 3 => 3 }")
    expect(newSource).to(eq("{ :one => 1, two: 2, 3 => 3 }"))
  test "autocorrects strings as keys into symbols with the correct syntax":
    var newSource = autocorrectSource("{ \'one two :\' => 1 }")
    expect(newSource).to(eq("{ :\"one two :\" => 1 }"))
  test "does not register an offense when not using strings as keys":
    expectNoOffenses("      { one: 1 }\n".stripIndent)
  test "does not register an offense when string key is used in IO.popen":
    expectNoOffenses("      IO.popen({\"RUBYOPT\" => \'-w\'}, \'ruby\', \'foo.rb\')\n".stripIndent)
  test "does not register an offense when string key is used in Open3.capture3":
    expectNoOffenses("      Open3.capture3({\"RUBYOPT\" => \'-w\'}, \'ruby\', \'foo.rb\')\n".stripIndent)
  test "does not register an offense when string key is used in Open3.pipeline":
    expectNoOffenses("      Open3.pipeline([{\"RUBYOPT\" => \'-w\'}, \'ruby\', \'foo.rb\'], [\'wc\', \'-l\'])\n".stripIndent)
