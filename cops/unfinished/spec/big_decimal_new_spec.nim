
import
  big_decimal_new, test_tools

suite "BigDecimalNew":
  var cop = BigDecimalNew()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when using `BigDecimal.new()`":
    expectOffense("""      BigDecimal.new(123.456, 3)
                 ^^^ `BigDecimal.new()` is deprecated. Use `BigDecimal()` instead.
""".stripIndent)
  test "registers an offense when using `::BigDecimal.new()`":
    expectOffense("""      ::BigDecimal.new(123.456, 3)
                   ^^^ `::BigDecimal.new()` is deprecated. Use `::BigDecimal()` instead.
""".stripIndent)
  test "does not register an offense when using `BigDecimal()`":
    expectNoOffenses("      BigDecimal(123.456, 3)\n".stripIndent)
  test "autocorrects `BigDecimal()`":
    var newSource = autocorrectSource("BigDecimal.new(123.456, 3)")
    expect(newSource).to(eq("BigDecimal(123.456, 3)"))
