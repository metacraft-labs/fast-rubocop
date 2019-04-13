
import
  unneeded_condition, test_tools

suite "UnneededCondition":
  var cop = UnneededCondition()
  context("when regular condition (if)", proc (): void =
    test "registers no offense":
      expectNoOffenses("""        if a
          b
        else
          c
        end
""".stripIndent)
    test "registers no offense for elsif":
      expectNoOffenses("""        if a
          b
        elsif d
          d
        else
          c
        end
""".stripIndent)
    context("when condition and if_branch are same", proc (): void =
      test "registers an offense":
        expectOffense("""          if b
          ^^^^ Use double pipes `||` instead.
            b
          else
            y(x,
              z)
          end
""".stripIndent)
      context("when else_branch is complex", proc (): void =
        test "registers no offense":
          expectNoOffenses("""            if b
              b
            else
              c
              d
            end
""".stripIndent))
      context("when using elsif branch", proc (): void =
        test "registers no offense":
          expectNoOffenses("""            if a
              a
            elsif cond
              d
            end
""".stripIndent))
      context("when using modifier if", proc (): void =
        test "registers an offense":
          expectOffense("""            bar if bar
            ^^^^^^^^^^ This condition is not needed.
""".stripIndent))
      context("""when `if` condition and `then` branch are the same and it has no `else` branch""", proc (): void =
        test "registers an offense":
          expectOffense("""            if do_something
            ^^^^^^^^^^^^^^^ This condition is not needed.
              do_something
            end
""".stripIndent))
      context("when using ternary if in `else` branch", proc (): void =
        test "registers no offense":
          expectNoOffenses("""            if a
              a
            else
              b ? c : d
            end
""".stripIndent)))
    describe("#autocorrection", proc (): void =
      test "auto-corrects offense":
        var newSource = autocorrectSource("""          if b
            b
          else
            c
          end
""".stripIndent)
        expect(newSource).to(eq("          b || c\n".stripIndent))
      test "auto-corrects multiline sendNode offense":
        var newSource = autocorrectSource("""          if b
            b
          else
            y(x,
              z)
          end
""".stripIndent)
        expect(newSource).to(eq("""          b || y(x,
              z)
""".stripIndent))
      test "auto-corrects one-line node offense":
        var newSource = autocorrectSource("""          if b
            b
          else
            (c || d)
          end
""".stripIndent)
        expect(newSource).to(eq("          b || (c || d)\n".stripIndent))
      test "auto-corrects modifier nodes offense":
        var newSource = autocorrectSource("""          if b
            b
          else
            c while d
          end
""".stripIndent)
        expect(newSource).to(eq("          b || (c while d)\n".stripIndent))
      test "auto-corrects modifer if statements":
        var newSource = autocorrectSource("bar if bar")
        expect(newSource).to(eq("bar"))
      test """auto-corrects when using `<<` method higher precedence than `||` operator""":
        var newSource = autocorrectSource("""          ary << if foo
                   foo
                 else
                   bar
                 end
""".stripIndent)
        expect(newSource).to(eq("          ary << (foo || bar)\n".stripIndent))
      test """when `if` condition and `then` branch are the same and it has no `else` branch""":
        var newSource = autocorrectSource("""          if do_something
            do_something
          end
""".stripIndent)
        expect(newSource).to(eq("          do_something\n".stripIndent))))
  context("when ternary expression (?:)", proc (): void =
    test "registers no offense":
      expectNoOffenses("b ? d : c")
    context("when condition and if_branch are same", proc (): void =
      test "registers an offense":
        expectOffense("""          b ? b : c
            ^^^^^ Use double pipes `||` instead.
""".stripIndent))
    describe("#autocorrection", proc (): void =
      test "auto-corrects vars":
        var newSource = autocorrectSource("a = b ? b : c")
        expect(newSource).to(eq("a = b || c"))
      test "auto-corrects nested vars":
        var newSource = autocorrectSource("b.x ? b.x : c")
        expect(newSource).to(eq("b.x || c"))
      test "auto-corrects class vars":
        var newSource = autocorrectSource("@b ? @b : c")
        expect(newSource).to(eq("@b || c"))
      test "auto-corrects functions":
        var newSource = autocorrectSource("a = b(x) ? b(x) : c")
        expect(newSource).to(eq("a = b(x) || c"))))
  context("when inverted condition (unless)", proc (): void =
    test "registers no offense":
      expectNoOffenses("""        unless a
          b
        else
          c
        end
""".stripIndent)
    context("when condition and else branch are same", proc (): void =
      test "registers an offense":
        expectOffense("""          unless b
          ^^^^^^^^ Use double pipes `||` instead.
            y(x, z)
          else
            b
          end
""".stripIndent)
      context("when unless branch is complex", proc (): void =
        test "registers no offense":
          expectNoOffenses("""            unless b
              c
              d
            else
              b
            end
""".stripIndent)))
    describe("#autocorrection", proc (): void =
      test "auto-corrects offense":
        var newSource = autocorrectSource("""          unless b
            c
          else
            b
          end
""".stripIndent)
        expect(newSource).to(eq("          b || c\n".stripIndent))))
