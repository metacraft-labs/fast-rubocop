
import
  symbol_proc, test_tools

RSpec.describe(SymbolProc, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"IgnoredMethods": @["respond_to"]}.newTable())
  test """registers an offense for a block with parameterless method call on param""":
    expectOffense("""      coll.map { |e| e.upcase }
               ^^^^^^^^^^^^^^^^ Pass `&:upcase` as an argument to `map` instead of a block.
""".stripIndent)
  test "registers an offense for a block when method in body is unary -/=":
    expectOffense("""      something.map { |x| -x }
                    ^^^^^^^^^^ Pass `&:-@` as an argument to `map` instead of a block.
""".stripIndent)
  test "accepts block with more than 1 arguments":
    expectNoOffenses("something { |x, y| x.method }")
  test "accepts lambda with 1 argument":
    expectNoOffenses("->(x) { x.method }")
  test "accepts proc with 1 argument":
    expectNoOffenses("proc { |x| x.method }")
  test "accepts Proc.new with 1 argument":
    expectNoOffenses("Proc.new { |x| x.method }")
  test "accepts ignored method":
    expectNoOffenses("respond_to { |format| format.xml }")
  test "accepts block with no arguments":
    expectNoOffenses("something { x.method }")
  test "accepts empty block body":
    expectNoOffenses("something { |x| }")
  test "accepts block with more than 1 expression in body":
    expectNoOffenses("something { |x| x.method; something_else }")
  test "accepts block when method in body is not called on block arg":
    expectNoOffenses("something { |x| y.method }")
  test "accepts block with a block argument ":
    expectNoOffenses("something { |&x| x.call }")
  test "accepts block with splat params":
    expectNoOffenses("something { |*x| x.first }")
  test "accepts block with adding a comma after the sole argument":
    expectNoOffenses("something { |x,| x.first }")
  context("when the method has arguments", proc (): void =
    let("source", proc (): void =
      "method(one, 2) { |x| x.test }")
    test "registers an offense":
      expectOffense("""        method(one, 2) { |x| x.test }
                       ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `method` instead of a block.
""".stripIndent)
    test "auto-corrects":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq("method(one, 2, &:test)")))
  test "autocorrects alias with symbols as proc":
    var corrected = autocorrectSource("coll.map { |s| s.upcase }")
    expect(corrected).to(eq("coll.map(&:upcase)"))
  test "autocorrects multiple aliases with symbols as proc":
    var corrected = autocorrectSource("""coll.map { |s| s.upcase }.map { |s| s.downcase }""")
    expect(corrected).to(eq("coll.map(&:upcase).map(&:downcase)"))
  test "auto-corrects correctly when there are no arguments in parentheses":
    var corrected = autocorrectSource("coll.map(   ) { |s| s.upcase }")
    expect(corrected).to(eq("coll.map(&:upcase)"))
  test "does not crash with a bare method call":
    var run = lambda(proc (): void =
      inspectSource("coll.map { |s| bare_method }"))
    expect(proc (it: void): void =
      it.un).notTo(raiseError)
  context("when `super` has arguments", proc (): void =
    let("source", proc (): void =
      "super(one, two) { |x| x.test }")
    test "registers an offense":
      expectOffense("""        super(one, two) { |x| x.test }
                        ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `super` instead of a block.
""".stripIndent)
    test "auto-corrects":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq("super(one, two, &:test)")))
  context("when `super` has no arguments", proc (): void =
    let("source", proc (): void =
      "super { |x| x.test }")
    test "registers an offense":
      expectOffense("""        super { |x| x.test }
              ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `super` instead of a block.
""".stripIndent)
    test "auto-corrects":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq("super(&:test)")))
  test "auto-corrects correctly when args have a trailing comma":
    var corrected = autocorrectSource("""      mail(
        to: 'foo',
        subject: 'bar',
      ) { |format| format.text }
""".stripIndent)
    expect(corrected).to(eq("""      mail(
        to: 'foo',
        subject: 'bar', &:text
      )
""".stripIndent)))
