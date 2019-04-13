
import
  statementModifierHelper

import
  if_unless_modifier, test_tools

suite "IfUnlessModifier":
  var cop = IfUnlessModifier()
  let("config", proc (): void =
    Config.new())
  context("multiline if that fits on one line", proc (): void =
    let("source", proc (): void =
      """        if (send nil :condition)
          (send nil :body)

        end
""".stripIndent)
    let("condition", proc (): void =
      "a" * 38)
    let("body", proc (): void =
      "b" * 38)
    test "registers an offense":
      expect("""(send nil :body) if (send nil :condition)""".length).to(eq(80))
      inspectSource(source())
      expect(cop().messages).to(eq(@["""Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`."""]))
    test "does auto-correction":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq("""(send nil :body) if (send nil :condition)
"""))
    context("and has two statements separated by semicolon", proc (): void =
      test "accepts":
        expectNoOffenses("""          if condition
            do_this; do_that
          end
""".stripIndent)))
  context("multiline if that fits on one line with comment on first line", proc (): void =
    let("source", proc (): void =
      """        if a # comment
          b
        end
""".stripIndent)
    test "registers an offense":
      expectOffense("""        if a # comment
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          b
        end
""".stripIndent)
    test "does auto-correction and preserves comment":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq("b if a # comment\n")))
  context("multiline if that fits on one line with comment near end", proc (): void =
    test "accepts":
      expectNoOffenses("""        if a
          b
        end # comment
        if a
          b
          # comment
        end
""".stripIndent))
  context("short multiline if near an else etc", proc (): void =
    let("source", proc (): void =
      """        if x
          y
        elsif x1
          y1
        else
          z
        end
        n = a ? 0 : 1
        m = 3 if m0

        if a
          b
        end
""".stripIndent)
    test "registers an offense":
      expectOffense("""        if x
          y
        elsif x1
          y1
        else
          z
        end
        n = a ? 0 : 1
        m = 3 if m0

        if a
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          b
        end
""".stripIndent)
    test "does auto-correction":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq("""        if x
          y
        elsif x1
          y1
        else
          z
        end
        n = a ? 0 : 1
        m = 3 if m0

        b if a
""".stripIndent)))
  test "accepts multiline if that doesn\'t fit on one line":
    checkTooLong("if")
  test "accepts multiline if whose body is more than one line":
    checkShortMultiline("if")
  context("multiline unless that fits on one line", proc (): void =
    let("source", proc (): void =
      """        unless a
          b
        end
""".stripIndent)
    test "registers an offense":
      expectOffense("""        unless a
        ^^^^^^ Favor modifier `unless` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          b
        end
""".stripIndent)
    test "does auto-correction":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq("b unless a\n")))
  test "accepts code with EOL comment since user might want to keep it":
    expectNoOffenses("""      unless a
        b # A comment
      end
""".stripIndent)
  test "accepts if-else-end":
    expectNoOffenses("      if args.last.is_a? Hash then args.pop else Hash.new end\n".stripIndent)
  test "accepts an empty condition":
    checkEmpty("if")
    checkEmpty("unless")
  test "accepts if/elsif":
    expectNoOffenses("""      if test
        something
      elsif test2
        something_else
      end
""".stripIndent)
  context("with implicit match conditional", proc (): void =
    let("source", proc (): void =
      """        |  if (send nil :conditional)
        |    (send nil :body)
        |  end
""".stripMargin(
          "|"))
    let("body", proc (): void =
      "b" * 36)
    context("when a multiline if fits on one line", proc (): void =
      let("conditional", proc (): void =
        """/(send
  (str "a") :*
  (int 36))/""")
      test "registers an offense":
        expect("""  (send nil :body) if (send nil :conditional)""".length).to(
            eq(80))
        inspectSource(source())
        expect(cop().offenses.size).to(eq(1))
      test "does auto-correction":
        var corrected = autocorrectSource(source())
        expect(corrected).to(eq("""  (send nil :body) if (send nil :conditional)
""")))
    context("when a multiline if doesn\'t fit on one line", proc (): void =
      let("conditional", proc (): void =
        """/(send
  (str "a") :*
  (int 37))/""")
      test "accepts":
        expect("""  (send nil :body) if (send nil :conditional)""".length).to(
            eq(81))
        expectNoOffenses(source())))
  test "accepts if-end followed by a chained call":
    expectNoOffenses("""      if test
        something
      end.inspect
""".stripIndent)
  test "doesn\'t break if-end when used as RHS of local var assignment":
    var corrected = autocorrectSource("""      a = if b
        1
      end
""".stripIndent)
    expect(corrected).to(eq("a = (1 if b)\n"))
  test "doesn\'t break if-end when used as RHS of instance var assignment":
    var corrected = autocorrectSource("""      @a = if b
        1
      end
""".stripIndent)
    expect(corrected).to(eq("@a = (1 if b)\n"))
  test "doesn\'t break if-end when used as RHS of class var assignment":
    var corrected = autocorrectSource("""      @@a = if b
        1
      end
""".stripIndent)
    expect(corrected).to(eq("@@a = (1 if b)\n"))
  test "doesn\'t break if-end when used as RHS of constant assignment":
    var corrected = autocorrectSource("""      A = if b
        1
      end
""".stripIndent)
    expect(corrected).to(eq("A = (1 if b)\n"))
  test "doesn\'t break if-end when used as RHS of binary arithmetic":
    var corrected = autocorrectSource("""      a + if b
        1
      end
""".stripIndent)
    expect(corrected).to(eq("a + (1 if b)\n"))
  test "accepts if-end when used as LHS of binary arithmetic":
    expectNoOffenses("""      if test
        1
      end + 2
""".stripIndent)
  context("if-end is argument to a parenthesized method call", proc (): void =
    test "doesn\'t add redundant parentheses":
      var corrected = autocorrectSource("""        puts("string", if a
          1
        end)
""".stripIndent)
      expect(corrected).to(eq("puts(\"string\", 1 if a)\n")))
  context("if-end is argument to a non-parenthesized method call", proc (): void =
    test "adds parentheses so as not to change meaning":
      var corrected = autocorrectSource("""        puts "string", if a
          1
        end
""".stripIndent)
      expect(corrected).to(eq("puts \"string\", (1 if a)\n")))
  context("if-end with conditional as body", proc (): void =
    test "accepts":
      expectNoOffenses("""        if condition
          foo ? "bar" : "baz"
        end
""".stripIndent))
  context("unless-end with conditional as body", proc (): void =
    test "accepts":
      expectNoOffenses("""        unless condition
          foo ? "bar" : "baz"
        end
""".stripIndent))
  context("with a named regexp capture on the LHS", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        if /(?<foo>d)/ =~ "bar"
          foo
        end
""".stripIndent))
  context("with disabled Layout/Tab cop", proc (): void =
    sharedExamples("with tabs indentation", proc (): void =
      let("source", proc (): void =
        """						if (send nil :condition)
							(send nil :body)
						end
""")
      let("body", proc (): void =
        "bbb")
      context("it fits on one line", proc (): void =
        let("condition", proc (): void =
          "aaa")
        test "registers an offense":
          expect("""(send nil :body) if (send nil :condition)""".length).to(
              eq(10))
          inspectSource(source())
          expect(cop().messages).to(eq(@["""Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`."""])))
      context("it doesn\'t fit on one line", proc (): void =
        let("condition", proc (): void =
          "aaaa")
        test "doesn\'t register an offense":
          expect("""(send nil :body) if (send nil :condition)""".length).to(
              eq(11))
          expectNoOffenses(source())))
    context("with Layout/Tab: IndentationWidth config", proc (): void =
      let("config", proc (): void =
        Config.new())
      itBehavesLike("with tabs indentation"))
    context("with Layout/IndentationWidth: Width config", proc (): void =
      let("config", proc (): void =
        Config.new())
      itBehavesLike("with tabs indentation"))
    context("without any IndentationWidth config", proc (): void =
      let("config", proc (): void =
        Config.new())
      itBehavesLike("with tabs indentation")))
  context("when Metrics/LineLength is disabled", proc (): void =
    let("config", proc (): void =
      Config.new())
    test "registers an offense even for a long modifier statement":
      expectOffense("""        if foo
        ^^ Favor modifier `if` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`.
          "This string would make the line longer than eighty characters if combined with the statement." 
        end
""".stripIndent))
