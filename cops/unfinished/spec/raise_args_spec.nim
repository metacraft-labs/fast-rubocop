
import
  raise_args, test_tools

RSpec.describe(RaiseArgs, "config", proc (): void =
  var cop = ()
  context("when enforced style is compact", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "compact"}.newTable())
    context("with a raise with 2 args", proc (): void =
      test "reports an offense":
        expectOffense("""          raise RuntimeError, msg
          ^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
""".stripIndent)
      test "auto-corrects to compact style":
        var newSource = autocorrectSource("raise RuntimeError, msg")
        expect(newSource).to(eq("raise RuntimeError.new(msg)")))
    context("when used in a ternary expression", proc (): void =
      test "registers an offense and auto-corrects":
        expectOffense("""          foo ? raise(Ex, 'error') : bar
                ^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
""".stripIndent)
        expectCorrection("          foo ? raise(Ex.new(\'error\')) : bar\n".stripIndent))
    context("when used in a logical and expression", proc (): void =
      test "registers an offense and auto-corrects":
        expectOffense("""          bar && raise(Ex, 'error')
                 ^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
""".stripIndent)
        expectCorrection("          bar && raise(Ex.new(\'error\'))\n".stripIndent))
    context("when used in a logical or expression", proc (): void =
      test "registers an offense and auto-corrects":
        expectOffense("""          bar || raise(Ex, 'error')
                 ^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
""".stripIndent)
        expectCorrection("          bar || raise(Ex.new(\'error\'))\n".stripIndent))
    context("with correct + opposite", proc (): void =
      test "reports an offense":
        expectOffense("""          if a
            raise RuntimeError, msg
            ^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
          else
            raise Ex.new(msg)
          end
""".stripIndent)
      test "auto-corrects to compact style":
        var newSource = autocorrectSource("""          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
          end
""".stripIndent)
        expect(newSource).to(eq("""          if a
            raise RuntimeError.new(msg)
          else
            raise Ex.new(msg)
          end
""".stripIndent)))
    context("with a raise with 3 args", proc (): void =
      test "reports an offense":
        expectOffense("""          raise RuntimeError, msg, caller
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
""".stripIndent)
      test "does not auto-correct to compact style":
        var
          initialSource = "raise RuntimeError, msg, caller"
          newSource = autocorrectSource(initialSource)
        expect(newSource).to(eq(initialSource)))
    test "accepts a raise with msg argument":
      expectNoOffenses("raise msg")
    test "accepts a raise with an exception argument":
      expectNoOffenses("raise Ex.new(msg)"))
  context("when enforced style is exploded", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "exploded"}.newTable())
    context("with a raise with exception object", proc (): void =
      context("with one argument", proc (): void =
        test "reports an offense":
          expectOffense("""            raise Ex.new(msg)
            ^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
""".stripIndent)
          expect(cop().configToAllowOffenses).to(eq())
        test "auto-corrects to exploded style":
          var newSource = autocorrectSource("raise Ex.new(msg)")
          expect(newSource).to(eq("raise Ex, msg")))
      context("with no arguments", proc (): void =
        test "reports an offense":
          expectOffense("""            raise Ex.new
            ^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
""".stripIndent)
          expect(cop().configToAllowOffenses).to(eq())
        test "auto-corrects to exploded style":
          var newSource = autocorrectSource("raise Ex.new")
          expect(newSource).to(eq("raise Ex")))
      context("when used in a ternary expression", proc (): void =
        test "registers an offense and auto-corrects":
          expectOffense("""            foo ? raise(Ex.new('error')) : bar
                  ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
""".stripIndent)
          expectCorrection("            foo ? raise(Ex, \'error\') : bar\n".stripIndent))
      context("when used in a logical and expression", proc (): void =
        test "registers an offense and auto-corrects":
          expectOffense("""            bar && raise(Ex.new('error'))
                   ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
""".stripIndent)
          expectCorrection("            bar && raise(Ex, \'error\')\n".stripIndent))
      context("when used in a logical or expression", proc (): void =
        test "registers an offense and auto-corrects":
          expectOffense("""            bar || raise(Ex.new('error'))
                   ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
""".stripIndent)
          expectCorrection("            bar || raise(Ex, \'error\')\n".stripIndent)))
    context("with opposite + correct", proc (): void =
      test "reports an offense for opposite + correct":
        expectOffense("""          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
            ^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          end
""".stripIndent)
        expect(cop().configToAllowOffenses).to(eq())
      test "auto-corrects to exploded style":
        var newSource = autocorrectSource("""          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
          end
""".stripIndent)
        expect(newSource).to(eq("""          if a
            raise RuntimeError, msg
          else
            raise Ex, msg
          end
""".stripIndent)))
    context("when an exception object is assigned to a local variable", proc (): void =
      test "auto-corrects to exploded style":
        var newSource = autocorrectSource("""          def do_something
            klass = RuntimeError
            raise klass.new('hi')
          end
""".stripIndent)
        expect(newSource).to(eq("""          def do_something
            klass = RuntimeError
            raise klass, 'hi'
          end
""".stripIndent)))
    test "accepts exception constructor with more than 1 argument":
      expectNoOffenses("raise MyCustomError.new(a1, a2, a3)")
    test "accepts exception constructor with keyword arguments":
      expectNoOffenses("raise MyKwArgError.new(a: 1, b: 2)")
    test "accepts a raise with splatted arguments":
      expectNoOffenses("raise MyCustomError.new(*args)")
    test "accepts a raise with 3 args":
      expectNoOffenses("raise RuntimeError, msg, caller")
    test "accepts a raise with 2 args":
      expectNoOffenses("raise RuntimeError, msg")
    test "accepts a raise with msg argument":
      expectNoOffenses("raise msg")))
