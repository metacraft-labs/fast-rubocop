
import
  trailing_body_on_method_definition, test_tools

suite "TrailingBodyOnMethodDefinition":
  var cop = TrailingBodyOnMethodDefinition()
  let("config", proc (): void =
    Config.new())
  test "registers an offense when body trails after method definition":
    expectOffense("""      def some_method; body
                       ^^^^ Place the first line of a multi-line method definition's body on its own line.
      end
      def extra_large; { size: 15 };
                       ^^^^^^^^^^^^ Place the first line of a multi-line method definition's body on its own line.
      end
      def seven_times(stuff) 7.times { do_this(stuff) }
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Place the first line of a multi-line method definition's body on its own line.
      end
""".stripIndent)
  test "registers when body starts on def line & continues one more line":
    expectOffense("""      def some_method; foo = {}
                       ^^^^^^^^ Place the first line of a multi-line method definition's body on its own line.
        more_body(foo)
      end
""".stripIndent)
  test "registers when body starts on def line & continues many more lines":
    expectOffense("""      def do_stuff(thing) process(thing)
                          ^^^^^^^^^^^^^^ Place the first line of a multi-line method definition's body on its own line.
        8.times { thing + 9 }
        even_more(thing)
      end
""".stripIndent)
  test "accepts a method with one line of body":
    expectNoOffenses("""      def some_method
        body
      end
""".stripIndent)
  test "accepts a method with multiple lines of body":
    expectNoOffenses("""      def stuff_method
        stuff
        9.times { process(stuff) }
        more_stuff
      end
""".stripIndent)
  test "does not register offense with trailing body on method end":
    expectNoOffenses("""      def some_method
        body
      foo; end
""".stripIndent)
  test "auto-corrects body after method definition":
    var corrected = autocorrectSource(@["  def some_method; body", "  end"].join(
        "\n"))
    expect(corrected).to(eq(@["  def some_method ", "    body", "  end"].join("\n")))
  test "auto-corrects with comment after body":
    var corrected = autocorrectSource(@["  def some_method; body # stuff", "  end"].join(
        "\n"))
    expect(corrected).to(eq(@["  # stuff", "  def some_method ", "    body ",
                              "  end"].join("\n")))
  test "auto-corrects body with method definition with args in parens":
    var corrected = autocorrectSource(@["  def some_method(arg1, arg2) body",
                                     "  end"].join("\n"))
    expect(corrected).to(eq(@["  def some_method(arg1, arg2) ", "    body",
                              "  end"].join("\n")))
  test "auto-corrects body with method definition with args not in parens":
    var corrected = autocorrectSource(@["  def some_method arg1, arg2; body",
                                     "  end"].join("\n"))
    expect(corrected).to(eq(@["  def some_method arg1, arg2 ", "    body", "  end"].join(
        "\n")))
  test "auto-correction removes semicolon from method definition but not body":
    var corrected = autocorrectSource(@["  def some_method; body; more_body;",
                                     "  end"].join("\n"))
    expect(corrected).to(eq(@["  def some_method ", "    body; more_body;",
                              "  end"].join("\n")))
  test "auto-corrects when body continues on one more line":
    var corrected = autocorrectSource(@["  def some_method; body", "    more_body",
                                     "  end"].join("\n"))
    expect(corrected).to(eq(@["  def some_method ", "    body", "    more_body",
                              "  end"].join("\n")))
  test "auto-corrects when body continues on multiple more line":
    var corrected = autocorrectSource(@["  def some_method; []", "    more_body",
                                     "    even_more", "  end"].join("\n"))
    expect(corrected).to(eq(@["  def some_method ", "    []", "    more_body",
                              "    even_more", "  end"].join("\n")))
  context("when method is not on first line of processed_source", proc (): void =
    test "auto-corrects offense":
      var corrected = autocorrectSource(@["", "  def some_method; body", "  end"].join(
          "\n"))
      expect(corrected).to(eq(@["", "  def some_method ", "    body", "  end"].join(
          "\n"))))
