
import
  random_with_offset, test_tools

suite "RandomWithOffset":
  var cop = RandomWithOffset()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when using rand(int) + offset":
    expectOffense("""      rand(6) + 1
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using offset + rand(int)":
    expectOffense("""      1 + rand(6)
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using rand(int).succ":
    expectOffense("""      rand(6).succ
      ^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using rand(int) - offset":
    expectOffense("""      rand(6) - 1
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using offset - rand(int)":
    expectOffense("""      1 - rand(6)
      ^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using rand(int).pred":
    expectOffense("""      rand(6).pred
      ^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using rand(int).next":
    expectOffense("""      rand(6).next
      ^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using Kernel.rand":
    expectOffense("""      Kernel.rand(6) + 1
      ^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using Random.rand":
    expectOffense("""      Random.rand(6) + 1
      ^^^^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using rand(irange) + offset":
    expectOffense("""      rand(0..6) + 1
      ^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "registers an offense when using rand(erange) + offset":
    expectOffense("""      rand(0...6) + 1
      ^^^^^^^^^^^^^^^ Prefer ranges when generating random numbers instead of integers with offsets.
""".stripIndent)
  test "autocorrects rand(int) + offset":
    var newSource = autocorrectSource("rand(6) + 1")
    expect(newSource).to(eq("rand(1..6)"))
  test "autocorrects offset + rand(int)":
    var newSource = autocorrectSource("1 + rand(6)")
    expect(newSource).to(eq("rand(1..6)"))
  test "autocorrects rand(int) - offset":
    var newSource = autocorrectSource("rand(6) - 1")
    expect(newSource).to(eq("rand(-1..4)"))
  test "autocorrects offset - rand(int)":
    var newSource = autocorrectSource("1 - rand(6)")
    expect(newSource).to(eq("rand(-4..1)"))
  test "autocorrects rand(int).succ":
    var newSource = autocorrectSource("rand(6).succ")
    expect(newSource).to(eq("rand(1..6)"))
  test "autocorrects rand(int).pred":
    var newSource = autocorrectSource("rand(6).pred")
    expect(newSource).to(eq("rand(-1..4)"))
  test "autocorrects rand(int).next":
    var newSource = autocorrectSource("rand(6).next")
    expect(newSource).to(eq("rand(1..6)"))
  test "autocorrects the use of Random.rand":
    var newSource = autocorrectSource("Random.rand(6) + 1")
    expect(newSource).to(eq("Random.rand(1..6)"))
  test "autocorrects the use of Kernel.rand":
    var newSource = autocorrectSource("Kernel.rand(6) + 1")
    expect(newSource).to(eq("Kernel.rand(1..6)"))
  test "autocorrects rand(irange) + offset":
    var newSource = autocorrectSource("rand(0..6) + 1")
    expect(newSource).to(eq("rand(1..7)"))
  test "autocorrects rand(3range) + offset":
    var newSource = autocorrectSource("rand(0...6) + 1")
    expect(newSource).to(eq("rand(1..6)"))
  test "autocorrects rand(irange) - offset":
    var newSource = autocorrectSource("rand(0..6) - 1")
    expect(newSource).to(eq("rand(-1..5)"))
  test "autocorrects rand(erange) - offset":
    var newSource = autocorrectSource("rand(0...6) - 1")
    expect(newSource).to(eq("rand(-1..4)"))
  test "autocorrects offset - rand(irange)":
    var newSource = autocorrectSource("1 - rand(0..6)")
    expect(newSource).to(eq("rand(-5..1)"))
  test "autocorrects offset - rand(erange)":
    var newSource = autocorrectSource("1 - rand(0...6)")
    expect(newSource).to(eq("rand(-4..1)"))
  test "autocorrects rand(irange).succ":
    var newSource = autocorrectSource("rand(0..6).succ")
    expect(newSource).to(eq("rand(1..7)"))
  test "autocorrects rand(erange).succ":
    var newSource = autocorrectSource("rand(0...6).succ")
    expect(newSource).to(eq("rand(1..6)"))
  test "does not register an offense when using range with double dots":
    expectNoOffenses("rand(1..6)")
  test "does not register an offense when using range with triple dots":
    expectNoOffenses("rand(1...6)")
