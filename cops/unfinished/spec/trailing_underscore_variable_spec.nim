
import
  trailing_underscore_variable, test_tools

suite "TrailingUnderscoreVariable":
  var cop = TrailingUnderscoreVariable()
  sharedExamples("common functionality", proc (): void =
    test """registers an offense when the last variable of parallel assignment is an underscore""":
      expectOffense("""        a, b, _ = foo()
              ^^ Do not use trailing `_`s in parallel assignment. Prefer `a, b, = foo()`.
""".stripIndent)
      expectCorrection("        a, b, = foo()\n".stripIndent)
    test """registers an offense when multiple underscores are used as the last variables of parallel assignment """:
      expectOffense("""        a, _, _ = foo()
           ^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
""".stripIndent)
      expectCorrection("        a, = foo()\n".stripIndent)
    test "registers an offense for splat underscore as the last variable":
      expectOffense("""        a, *_ = foo()
           ^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
""".stripIndent)
      expectCorrection("        a, = foo()\n".stripIndent)
    test """registers an offense when underscore is the second to last variable and blank is the last variable""":
      expectOffense("""        a, _, = foo()
           ^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
""".stripIndent)
      expectCorrection("        a, = foo()\n".stripIndent)
    test """registers an offense when underscore is the only variable in parallel assignment""":
      expectOffense("""        _, = foo()
        ^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `foo()`.
""".stripIndent)
      expectCorrection("        foo()\n".stripIndent)
    test """registers an offense for an underscore as the last param when there is also an underscore as the first param""":
      expectOffense("""        _, b, _ = foo()
              ^^ Do not use trailing `_`s in parallel assignment. Prefer `_, b, = foo()`.
""".stripIndent)
      expectCorrection("        _, b, = foo()\n".stripIndent)
    test "does not register an offense when there are no underscores":
      expectNoOffenses("a, b, c = foo()")
    test "does not register an offense for underscores at the beginning":
      expectNoOffenses("_, a, b = foo()")
    test """does not register an offense for an underscore preceded by a splat variable anywhere in the argument chain""":
      expectNoOffenses("*a, b, _ = foo()")
    test """does not register an offense for an underscore preceded by a splat variable""":
      expectNoOffenses("a, *b, _ = foo()")
    test """does not register an offense for an underscore preceded by a splat variable and another underscore""":
      expectNoOffenses("_, *b, _ = *foo")
    test """does not register an offense for multiple underscores preceded by a splat variable""":
      expectNoOffenses("a, *b, _, _ = foo()")
    test """does not register an offense for multiple named underscores preceded by a splat variable""":
      expectNoOffenses("a, *b, _c, _d = foo()")
    test """registers an offense for multiple underscore variables preceded by a splat underscore variable""":
      expectOffense("""        a, *_, _, _ = foo()
           ^^^^^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
""".stripIndent)
      expectCorrection("        a, = foo()\n".stripIndent)
    test """registers an offense for nested assignments with trailing underscores""":
      expectOffense("""        a, (b, _) = foo()
              ^^ Do not use trailing `_`s in parallel assignment. Prefer `a, (b,) = foo()`.
""".stripIndent)
      expectCorrection("        a, (b,) = foo()\n".stripIndent)
    test """registers an offense for complex nested assignments with trailing underscores""":
      expectOffense("""        a, (_, (b, _), *_) = foo()
                  ^^ Do not use trailing `_`s in parallel assignment. Prefer `a, (_, (b,), *_) = foo()`.
                      ^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, (_, (b, _),) = foo()`.
""".stripIndent)
      expectCorrection("        a, (_, (b,),) = foo()\n".stripIndent)
    test """does not register an offense for a named underscore variable preceded by a splat variable""":
      expectNoOffenses("a, *b, _c = foo()")
    test """does not register an offense for a named variable preceded by a names splat underscore variable""":
      expectNoOffenses("a, *b, _c = foo()")
    test """does not register an offense for nested assignments without trailing underscores""":
      expectNoOffenses("a, (_, b) = foo()")
    test """does not register an offense for complex nested assignments without trailing underscores""":
      expectNoOffenses("a, (_, (b,), c, (d, e),) = foo()")
    describe("autocorrect", proc (): void =
      context("with parentheses", proc (): void =
        test "leaves parentheses but removes trailing underscores":
          var newSource = autocorrectSource("(a, b, _) = foo()")
          expect(newSource).to(eq("(a, b,) = foo()"))
        test "removes assignment part when every assignment is to `_`":
          var newSource = autocorrectSource("(_, _, _,) = foo()")
          expect(newSource).to(eq("foo()"))
        test "removes assignment part when it is the only variable":
          var newSource = autocorrectSource("(_,) = foo()")
          expect(newSource).to(eq("foo()"))
        test "leaves parentheses but removes trailing underscores and commas":
          var newSource = autocorrectSource("(a, _, _,) = foo()")
          expect(newSource).to(eq("(a,) = foo()")))))
  context("configured to allow named underscore variables", proc (): void =
    let("config", proc (): void =
      Config.new())
    includeExamples("common functionality")
    test """does not register an offense for named variables that start with an underscore""":
      expectNoOffenses("a, b, _c = foo()")
    test """does not register an offense for a named splat underscore as the last variable""":
      expectNoOffenses("a, *_b = foo()")
    test """does not register an offense for an underscore variable preceded by a named splat underscore variable""":
      expectNoOffenses("a, *_b, _ = foo()")
    test """does not register an offense for multiple underscore variables preceded by a named splat underscore variable""":
      expectNoOffenses("a, *_b, _, _ = foo()"))
  context("configured to not allow named underscore variables", proc (): void =
    let("config", proc (): void =
      Config.new())
    includeExamples("common functionality")
    test """registers an offense for named variables that start with an underscore""":
      expectOffense("""        a, b, _c = foo()
              ^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, b, = foo()`.
""".stripIndent)
      expectCorrection("        a, b, = foo()\n".stripIndent)
    test """registers an offense for a named splat underscore as the last variable""":
      expectOffense("""        a, *_b = foo()
           ^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
""".stripIndent)
      expectCorrection("        a, = foo()\n".stripIndent)
    test """does not register an offense for a named underscore preceded by a splat variable""":
      expectNoOffenses("a, *b, _c = foo()")
    test """registers an offense for an underscore variable preceded by a named splat underscore variable""":
      expectOffense("""        a, *_b, _ = foo()
           ^^^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
""".stripIndent)
      expectCorrection("        a, = foo()\n".stripIndent)
    test """registers an offense for an underscore preceded by a named splat underscore""":
      expectOffense("""        a, b, *_c, _ = foo()
              ^^^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, b, = foo()`.
""".stripIndent)
      expectCorrection("        a, b, = foo()\n".stripIndent)
    test """registers an offense for multiple underscore variables preceded by a named splat underscore variable""":
      expectOffense("""        a, *_b, _, _ = foo()
           ^^^^^^^^^^ Do not use trailing `_`s in parallel assignment. Prefer `a, = foo()`.
""".stripIndent)
      expectCorrection("        a, = foo()\n".stripIndent))
