
import
  uri_default_parser, test_tools

suite "UriDefaultParser":
  var cop = UriDefaultParser()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when using `URI::Parser.new`":
    expectOffense("""      URI::Parser.new.make_regexp
      ^^^^^^^^^^^^^^^ Use `URI::DEFAULT_PARSER` instead of `URI::Parser.new`.
""".stripIndent)
  test "registers an offense when using `::URI::Parser.new`":
    expectOffense("""      ::URI::Parser.new.make_regexp
      ^^^^^^^^^^^^^^^^^ Use `::URI::DEFAULT_PARSER` instead of `::URI::Parser.new`.
""".stripIndent)
  test "autocorrects `URI::DEFAULT_PARSER`":
    var newSource = autocorrectSource("URI::Parser.new.make_regexp")
    expect(newSource).to(eq("URI::DEFAULT_PARSER.make_regexp"))
  test "autocorrects `::URI::DEFAULT_PARSER`":
    var newSource = autocorrectSource("::URI::Parser.new.make_regexp")
    expect(newSource).to(eq("::URI::DEFAULT_PARSER.make_regexp"))
