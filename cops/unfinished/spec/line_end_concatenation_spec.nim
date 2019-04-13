
import
  line_end_concatenation, test_tools

suite "LineEndConcatenation":
  var cop = LineEndConcatenation()
  test "registers an offense for string concat at line end":
    expectOffense("""      top = "test" +
                   ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top"
""".stripIndent)
  test "registers an offense for string concat with << at line end":
    expectOffense("""      top = "test" <<
                   ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top"
""".stripIndent)
  test "registers an offense for string concat with << and \\ at line ends":
    expectOffense("""      top = "test " \
      "foo" <<
            ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "bar"
""".stripIndent)
  test "registers an offense for dynamic string concat at line end":
    expectOffense("""      top = "test#{x}" +
                       ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top"
""".stripIndent)
  test "registers an offense for dynamic string concat with << at line end":
    expectOffense("""      top = "test#{x}" <<
                       ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top"
""".stripIndent)
  test "registers multiple offenses when there are chained << methods":
    expectOffense("""      top = "test#{x}" <<
                       ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top" <<
            ^^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "ubertop"
""".stripIndent)
  test "registers multiple offenses when there are chained concatenations":
    expectOffense("""      top = "test#{x}" +
                       ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "top" +
            ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "foo"
""".stripIndent)
  test """registers multiple offenses when there are chained concatenationscombined with << calls""":
    inspectSource("""      top = "test#{x}" <<
      "top" +
      "foo" <<
      "bar"
""".stripIndent)
    expect(cop().offenses.size).to(eq(3))
  test "accepts string concat on the same line":
    expectNoOffenses("top = \"test\" + \"top\"")
  test "accepts string concat with a return value of method on a string":
    expectNoOffenses("""      content_and_three_spaces = "content" +
        " " * 3
      a_thing = 'a ' +
        'gniht'.reverse
      output = 'value: ' +
        '%d' % value
      'letter: ' +
        'abcdefghij'[ix]
""".stripIndent)
  test """accepts string concat with a return value of method on an interpolated string""":
    expectNoOffenses("""      x3a = 'x' +
        "#{'a' + "#{3}"}".reverse
""".stripIndent)
  test "accepts string concat at line end when followed by comment":
    expectNoOffenses("""      top = "test" + # something
      "top"
""".stripIndent)
  test "accepts string concat at line end when followed by a comment line":
    expectNoOffenses("""      top = "test" +
      # something
      "top"
""".stripIndent)
  test "accepts string concat at line end when % literals are involved":
    expectNoOffenses("""      top = %(test) +
      "top"
""".stripIndent)
  test "accepts string concat at line end for special strings like __FILE__":
    expectNoOffenses("""      top = __FILE__ +
      "top"
""".stripIndent)
  test "registers offenses only for the appropriate lines in chained concats":
    expectOffense("""      top = "test#{x}" + # comment
      "foo" +
      %(bar) +
      "baz" +
            ^ Use `\` instead of `+` or `<<` to concatenate those strings.
      "qux"
""".stripIndent)
  test "autocorrects in the simple case by replacing + with \\":
    var corrected = autocorrectSource("""      top = "test" + 
      "top"
""".stripIndent)
    expect(corrected).to(eq("""      top = "test" \
      "top"
""".stripIndent))
  test "autocorrects a + with trailing whitespace to \\":
    var corrected = autocorrectSource("""      top = "test" +
      "top"
""".stripIndent)
    expect(corrected).to(eq("""      top = "test" \
      "top"
""".stripIndent))
  test "autocorrects a + with \\ to just \\":
    var corrected = autocorrectSource("""      top = "test" + \
      "top"
""".stripIndent)
    expect(corrected).to(eq("""      top = "test" \
      "top"
""".stripIndent))
  test "autocorrects for chained concatenations and << calls":
    var corrected = autocorrectSource("""      top = "test#{x}" <<
      "top" +
      "ubertop" <<
      "foo"
""".stripIndent)
    expect(corrected).to(eq("""      top = "test#{x}" \
      "top" \
      "ubertop" \
      "foo"
""".stripIndent))
  test "autocorrects only the lines that should be autocorrected":
    var corrected = autocorrectSource("""      top = "test#{x}" <<
      "top" + # comment
      "foo" +
      "bar" +
      %(baz) +
      "qux"
""".stripIndent)
    expect(corrected).to(eq("""      top = "test#{x}" \
      "top" + # comment
      "foo" \
      "bar" +
      %(baz) +
      "qux"
""".stripIndent))
