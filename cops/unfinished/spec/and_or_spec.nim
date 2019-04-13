
import
  tables

import
  and_or, test_tools

RSpec.describe(AndOr, "config", proc (): void =
  context("when style is conditionals", proc (): void =
    var
      copConfig = {"EnforcedStyle": "conditionals"}.newTable()
      cop = ()
    let("cop_config", proc (): void =
      copConfig)
    for operator in @["and", "or"]:
      test """accepts "(lvar :operator)" outside of conditional""":
        expectNoOffenses("""          x = a + b (lvar :operator) return x
""".stripIndent)
      for type, snippetFormat in {"if": "if %<condition>s; %<body>s; end",
                              "while": "while %<condition>s; %<body>s; end",
                              "until": "until %<condition>s; %<body>s; end", "post-conditional while": "begin; %<body>s; end while %<condition>s", "post-conditional until": "begin; %<body>s; end until %<condition>s"}.newTable():
        test """registers an offense for "(lvar :operator)" in (lvar :type) conditional""":
          var
            elements = {"condition": """a (lvar :operator) b""",
                      "body": "do_something"}.newTable()
            source = format(snippetFormat, elements)
          inspectSource(source)
          expect(cop().offenses.size).to(eq(1))
        test """accepts "(lvar :operator)" in (lvar :type) body""":
          var
            elements = {"condition": "some_condition",
                      "body": """do_something (lvar :operator) return"""}.newTable()
            source = format(snippetFormat, elements)
          expectNoOffenses(source)
    for operator in @["&&", "||"]:
      test """accepts (lvar :operator) inside of conditional""":
        expectNoOffenses("""          test if a (lvar :operator) b
""".stripIndent)
      test """accepts (lvar :operator) outside of conditional""":
        expectNoOffenses("""          x = a (lvar :operator) b
""".stripIndent))
  context("when style is always", proc (): void =
    var
      copConfig = {"EnforcedStyle": "always"}.newTable()
      cop = ()
    let("cop_config", proc (): void =
      copConfig)
    test "registers an offense for \"or\"":
      expectOffense("""        test if a or b
                  ^^ Use `||` instead of `or`.
""".stripIndent)
    test "registers an offense for \"and\"":
      expectOffense("""        test if a and b
                  ^^^ Use `&&` instead of `and`.
""".stripIndent)
    test "accepts ||":
      expectNoOffenses("test if a || b")
    test "accepts &&":
      expectNoOffenses("test if a && b")
    test "auto-corrects \"and\" with &&":
      var newSource = autocorrectSource("true and false")
      expect(newSource).to(eq("true && false"))
    test "auto-corrects \"or\" with ||":
      var newSource = autocorrectSource("""        x = 12345
        true or false
""".stripIndent)
      expect(newSource).to(eq("""        x = 12345
        true || false
""".stripIndent))
    test "auto-corrects \"or\" with || inside def":
      var newSource = autocorrectSource("""        def z(a, b)
          return true if a or b
        end
""".stripIndent)
      expect(newSource).to(eq("""        def z(a, b)
          return true if a || b
        end
""".stripIndent))
    test "autocorrects \"or\" with an assignment on the left":
      var
        src = "x = y or teststring.include? \'b\'"
        newSource = autocorrectSource(src)
      expect(newSource).to(eq("(x = y) || teststring.include?(\'b\')"))
    test "autocorrects \"or\" with an assignment on the right":
      var
        src = "teststring.include? \'b\' or x = y"
        newSource = autocorrectSource(src)
      expect(newSource).to(eq("teststring.include?(\'b\') || (x = y)"))
    test "autocorrects \"and\" with an assignment and return on either side":
      var
        src = "x = a + b and return x"
        newSource = autocorrectSource(src)
      expect(newSource).to(eq("(x = a + b) && (return x)"))
    test "autocorrects \"and\" with an Enumerable accessor on either side":
      var
        src = "foo[:bar] and foo[:baz]"
        newSource = autocorrectSource(src)
      expect(newSource).to(eq("foo[:bar] && foo[:baz]"))
    test "warns on short-circuit (and)":
      expectOffense("""        x = a + b and return x
                  ^^^ Use `&&` instead of `and`.
""".stripIndent)
    test "also warns on non short-circuit (and)":
      expectOffense("""        x = a + b if a and b
                       ^^^ Use `&&` instead of `and`.
""".stripIndent)
    test "also warns on non short-circuit (and) (unless)":
      expectOffense("""        x = a + b unless a and b
                           ^^^ Use `&&` instead of `and`.
""".stripIndent)
    test "warns on short-circuit (or)":
      expectOffense("""        x = a + b or return x
                  ^^ Use `||` instead of `or`.
""".stripIndent)
    test "also warns on non short-circuit (or)":
      expectOffense("""        x = a + b if a or b
                       ^^ Use `||` instead of `or`.
""".stripIndent)
    test "also warns on non short-circuit (or) (unless)":
      expectOffense("""        x = a + b unless a or b
                           ^^ Use `||` instead of `or`.
""".stripIndent)
    test "also warns on while (or)":
      expectOffense("""        x = a + b while a or b
                          ^^ Use `||` instead of `or`.
""".stripIndent)
    test "also warns on until (or)":
      expectOffense("""        x = a + b until a or b
                          ^^ Use `||` instead of `or`.
""".stripIndent)
    test "auto-corrects \"or\" with || in method calls":
      var newSource = autocorrectSource("method a or b")
      expect(newSource).to(eq("method(a) || b"))
    test "auto-corrects \"or\" with || in method calls (2)":
      var newSource = autocorrectSource("method a,b or b")
      expect(newSource).to(eq("method(a,b) || b"))
    test "auto-corrects \"or\" with || in method calls (3)":
      var newSource = autocorrectSource("obj.method a or b")
      expect(newSource).to(eq("obj.method(a) || b"))
    test "auto-corrects \"or\" with || in method calls (4)":
      var newSource = autocorrectSource("obj.method a,b or b")
      expect(newSource).to(eq("obj.method(a,b) || b"))
    test "auto-corrects \"or\" with || and doesn\'t add extra parentheses":
      var newSource = autocorrectSource("method(a, b) or b")
      expect(newSource).to(eq("method(a, b) || b"))
    test "auto-corrects \"or\" with || and adds parentheses to expr":
      var newSource = autocorrectSource("b or method a,b")
      expect(newSource).to(eq("b || method(a,b)"))
    test "auto-corrects \"and\" with && in method calls":
      var newSource = autocorrectSource("method a and b")
      expect(newSource).to(eq("method(a) && b"))
    test "auto-corrects \"and\" with && in method calls (2)":
      var newSource = autocorrectSource("method a,b and b")
      expect(newSource).to(eq("method(a,b) && b"))
    test "auto-corrects \"and\" with && in method calls (3)":
      var newSource = autocorrectSource("obj.method a and b")
      expect(newSource).to(eq("obj.method(a) && b"))
    test "auto-corrects \"and\" with && in method calls (4)":
      var newSource = autocorrectSource("obj.method a,b and b")
      expect(newSource).to(eq("obj.method(a,b) && b"))
    test "auto-corrects \"and\" with && and doesn\'t add extra parentheses":
      var newSource = autocorrectSource("method(a, b) and b")
      expect(newSource).to(eq("method(a, b) && b"))
    test "auto-corrects \"and\" with && and adds parentheses to expr":
      var newSource = autocorrectSource("b and method a,b")
      expect(newSource).to(eq("b && method(a,b)"))
    context("with !obj.method arg on right", proc (): void =
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("x and !obj.method arg")
        expect(newSource).to(eq("x && !obj.method(arg)")))
    context("with !obj.method arg on left", proc (): void =
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("!obj.method arg and x")
        expect(newSource).to(eq("!obj.method(arg) && x")))
    context("with obj.method = arg on left", proc (): void =
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("obj.method = arg and x")
        expect(newSource).to(eq("(obj.method = arg) && x")))
    context("with obj.method= arg on left", proc (): void =
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("obj.method= arg and x")
        expect(newSource).to(eq("(obj.method= arg) && x")))
    context("with predicate method with arg without space on right", proc (): void =
      test "autocorrects \"or\" with || and adds parens":
        var newSource = autocorrectSource("false or 3.is_a?Integer")
        expect(newSource).to(eq("false || 3.is_a?(Integer)"))
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("false and 3.is_a?Integer")
        expect(newSource).to(eq("false && 3.is_a?(Integer)")))
    context("with two predicate methods with args without spaces on right", proc (): void =
      test "autocorrects \"or\" with || and adds parens":
        var newSource = autocorrectSource("""'1'.is_a?Integer or 1.is_a?Integer""")
        expect(newSource).to(eq("\'1\'.is_a?(Integer) || 1.is_a?(Integer)"))
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("""'1'.is_a?Integer and 1.is_a?Integer""")
        expect(newSource).to(eq("\'1\'.is_a?(Integer) && 1.is_a?(Integer)")))
    context("""with one predicate method without space on right and another method""", proc (): void =
      test "autocorrects \"or\" with || and adds parens":
        var newSource = autocorrectSource("""'1'.is_a?Integer or 1.is_a? Integer""")
        expect(newSource).to(eq("\'1\'.is_a?(Integer) || 1.is_a?(Integer)"))
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("""'1'.is_a?Integer and 1.is_a? Integer""")
        expect(newSource).to(eq("\'1\'.is_a?(Integer) && 1.is_a?(Integer)")))
    context("with `not` expression on right", proc (): void =
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("x and not arg")
        expect(newSource).to(eq("x && (not arg)")))
    context("with `not` expression on left", proc (): void =
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("not arg and x")
        expect(newSource).to(eq("(not arg) && x")))
    context("with !variable on left", proc (): void =
      test "doesn\'t crash and burn":
        expectOffense("""          !var or var.empty?
               ^^ Use `||` instead of `or`.
""".stripIndent))
    context("within a nested begin node", proc (): void =
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("""          def x
          end

          def y
            a = b and a.c
          end
""".stripIndent)
        expect(newSource).to(eq("""          def x
          end

          def y
            (a = b) && a.c
          end
""".stripIndent)))
    context("when left hand side is a comparison method", proc (): void =
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("          foo == bar and baz\n".stripIndent)
        expect(newSource).to(eq("          (foo == bar) && baz\n".stripIndent)))
    context("within a nested begin node with one child only", proc (): void =
      test "autocorrects \"and\" with && and adds parens":
        var newSource = autocorrectSource("""          (def y
            a = b and a.c
          end)
""".stripIndent)
        expect(newSource).to(eq("""          (def y
            (a = b) && a.c
          end)
""".stripIndent)))
    context("with a file which contains __FILE__", proc (): void =
      let("source", proc (): void =
        """          APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)
          system('bundle check') or system!('bundle install')
""".stripIndent)
      test "autocorrects \"or\" with ||":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq("""            APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)
            system('bundle check') || system!('bundle install')
""".stripIndent)))))
