
import
  caller, test_tools

suite "Caller":
  var cop = Caller()
  test "accepts `caller` without argument and method chain":
    expectNoOffenses("caller")
  test "accepts `caller` with arguments":
    expectNoOffenses("caller(1, 1).first")
  test "accepts `caller_locations` without argument and method chain":
    expectNoOffenses("caller_locations")
  test "registers an offense when :first is called on caller":
    expect(caller()[0]).to(eq(caller()[0]))
    expectOffense("""      caller.first
      ^^^^^^^^^^^^ Use `caller(1..1).first` instead of `caller.first`.
""".stripIndent)
  test "registers an offense when :first is called on caller with 1":
    expect(caller(1)[0]).to(eq(caller()[0]))
    expectOffense("""      caller(1).first
      ^^^^^^^^^^^^^^^ Use `caller(1..1).first` instead of `caller.first`.
""".stripIndent)
  test "registers an offense when :first is called on caller with 2":
    expect(caller(2)[0]).to(eq(caller()[0]))
    expectOffense("""      caller(2).first
      ^^^^^^^^^^^^^^^ Use `caller(2..2).first` instead of `caller.first`.
""".stripIndent)
  test "registers an offense when :[] is called on caller":
    expect(caller()[1]).to(eq(caller()[0]))
    expectOffense("""      caller[1]
      ^^^^^^^^^ Use `caller(2..2).first` instead of `caller[1]`.
""".stripIndent)
  test "registers an offense when :[] is called on caller with 1":
    expect(caller(1)[1]).to(eq(caller()[0]))
    expectOffense("""      caller(1)[1]
      ^^^^^^^^^^^^ Use `caller(2..2).first` instead of `caller[1]`.
""".stripIndent)
  test "registers an offense when :[] is called on caller with 2":
    expect(caller(2)[1]).to(eq(caller()[0]))
    expectOffense("""      caller(2)[1]
      ^^^^^^^^^^^^ Use `caller(3..3).first` instead of `caller[1]`.
""".stripIndent)
  test "registers an offense when :first is called on caller_locations also":
    expect(`$`()).to(eq(`$`()))
    expectOffense("""      caller_locations.first
      ^^^^^^^^^^^^^^^^^^^^^^ Use `caller_locations(1..1).first` instead of `caller_locations.first`.
""".stripIndent)
  test "registers an offense when :[] is called on caller_locations also":
    expect(`$`()).to(eq(`$`()))
    expectOffense("""      caller_locations[1]
      ^^^^^^^^^^^^^^^^^^^ Use `caller_locations(2..2).first` instead of `caller_locations[1]`.
""".stripIndent)
