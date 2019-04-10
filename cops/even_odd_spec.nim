
import
  even_odd, test_tools

suite "EvenOdd":
  var cop = EvenOdd()
  test "registers an offense for x % 2 == 0":
    expectOffense("""      x % 2 == 0
      ^^^^^^^^^^ Replace with `Integer#even?`.
""".stripIndent)
  test "registers an offense for x % 2 != 0":
    expectOffense("""      x % 2 != 0
      ^^^^^^^^^^ Replace with `Integer#odd?`.
""".stripIndent)
  test "registers an offense for (x % 2) == 0":
    expectOffense("""      (x % 2) == 0
      ^^^^^^^^^^^^ Replace with `Integer#even?`.
""".stripIndent)
  test "registers an offense for (x % 2) != 0":
    expectOffense("""      (x % 2) != 0
      ^^^^^^^^^^^^ Replace with `Integer#odd?`.
""".stripIndent)
  test "registers an offense for x % 2 == 1":
    expectOffense("""      x % 2 == 1
      ^^^^^^^^^^ Replace with `Integer#odd?`.
""".stripIndent)
  test "registers an offense for x % 2 != 1":
    expectOffense("""      x % 2 != 1
      ^^^^^^^^^^ Replace with `Integer#even?`.
""".stripIndent)
  test "registers an offense for (x % 2) == 1":
    expectOffense("""      (x % 2) == 1
      ^^^^^^^^^^^^ Replace with `Integer#odd?`.
""".stripIndent)
  test "registers an offense for (x % 2) != 1":
    expectOffense("""      (x % 2) != 1
      ^^^^^^^^^^^^ Replace with `Integer#even?`.
""".stripIndent)
  test "registers an offense for (x.y % 2) != 1":
    expectOffense("""      (x.y % 2) != 1
      ^^^^^^^^^^^^^^ Replace with `Integer#even?`.
""".stripIndent)
  test "registers an offense for (x(y) % 2) != 1":
    expectOffense("""      (x(y) % 2) != 1
      ^^^^^^^^^^^^^^^ Replace with `Integer#even?`.
""".stripIndent)
  test "accepts x % 3 == 0":
    expectNoOffenses("x % 3 == 0")
  test "accepts x % 3 != 0":
    expectNoOffenses("x % 3 != 0")
  test "converts x % 2 == 0 to #even?":
    var corrected = autocorrectSource("x % 2 == 0")
    expect(corrected).to(eq("x.even?"))
  test "converts x % 2 != 0 to #odd?":
    var corrected = autocorrectSource("x % 2 != 0")
    expect(corrected).to(eq("x.odd?"))
  test "converts (x % 2) == 0 to #even?":
    var corrected = autocorrectSource("(x % 2) == 0")
    expect(corrected).to(eq("x.even?"))
  test "converts (x % 2) != 0 to #odd?":
    var corrected = autocorrectSource("(x % 2) != 0")
    expect(corrected).to(eq("x.odd?"))
  test "converts x % 2 == 1 to odd?":
    var corrected = autocorrectSource("x % 2 == 1")
    expect(corrected).to(eq("x.odd?"))
  test "converts x % 2 != 1 to even?":
    var corrected = autocorrectSource("x % 2 != 1")
    expect(corrected).to(eq("x.even?"))
  test "converts (x % 2) == 1 to odd?":
    var corrected = autocorrectSource("(x % 2) == 1")
    expect(corrected).to(eq("x.odd?"))
  test "converts (y % 2) != 1 to even?":
    var corrected = autocorrectSource("(y % 2) != 1")
    expect(corrected).to(eq("y.even?"))
  test "converts (x.y % 2) != 1 to even?":
    var corrected = autocorrectSource("(x.y % 2) != 1")
    expect(corrected).to(eq("x.y.even?"))
  test "converts (x(y) % 2) != 1 to even?":
    var corrected = autocorrectSource("(x(y) % 2) != 1")
    expect(corrected).to(eq("x(y).even?"))
  test "converts (x._(y) % 2) != 1 to even?":
    var corrected = autocorrectSource("(x._(y) % 2) != 1")
    expect(corrected).to(eq("x._(y).even?"))
  test "converts (x._(y)) % 2 != 1 to even?":
    var corrected = autocorrectSource("(x._(y)) % 2 != 1")
    expect(corrected).to(eq("(x._(y)).even?"))
  test "converts x._(y) % 2 != 1 to even?":
    var corrected = autocorrectSource("x._(y) % 2 != 1")
    expect(corrected).to(eq("x._(y).even?"))
  test "converts 1 % 2 != 1 to even?":
    var corrected = autocorrectSource("1 % 2 != 1")
    expect(corrected).to(eq("1.even?"))
  test "converts complex examples":
    var corrected = autocorrectSource("""      if (y % 2) != 1
        method == :== ? :even : :odd
      elsif x % 2 == 1
        method == :== ? :odd : :even
      end
""".stripIndent)
    expect(corrected).to(eq("""      if y.even?
        method == :== ? :even : :odd
      elsif x.odd?
        method == :== ? :odd : :even
      end
""".stripIndent))
