
import
  each_for_simple_loop, test_tools

suite "EachForSimpleLoop":
  var cop = EachForSimpleLoop()
  const
    OFFENSEMSG = """Use `Integer#times` for a simple loop which iterates a fixed number of times."""
  test "registers offense for inclusive end range":
    expectOffense("""      (0..10).each {}
      ^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
""".stripIndent)
  test "registers offense for exclusive end range":
    expectOffense("""      (0...10).each {}
      ^^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
""".stripIndent)
  test "registers offense for exclusive end range with do ... end syntax":
    expectOffense("""      (0...10).each do
      ^^^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
      end
""".stripIndent)
  test "registers an offense for range not starting with zero":
    expectOffense("""      (3..7).each do
      ^^^^^^^^^^^ Use `Integer#times` for a simple loop which iterates a fixed number of times.
      end
""".stripIndent)
  test "does not register offense if range startpoint is not constant":
    expectNoOffenses("(a..10).each {}")
  test "does not register offense if range endpoint is not constant":
    expectNoOffenses("(0..b).each {}")
  test "does not register offense for inline block with parameters":
    expectNoOffenses("(0..10).each { |n| puts n }")
  test "does not register offense for multiline block with parameters":
    expectNoOffenses("""      (0..10).each do |n|
      end
""".stripIndent)
  test "does not register offense for character range":
    expectNoOffenses("(\'a\'..\'b\').each {}")
  context("when using an inclusive range", proc (): void =
    test "autocorrects the source with inline block":
      var corrected = autocorrectSource("(0..10).each {}")
      expect(corrected).to(eq("11.times {}"))
    test "autocorrects the source with multiline block":
      var corrected = autocorrectSource("""        (0..10).each do
        end
""".stripIndent)
      expect(corrected).to(eq("""        11.times do
        end
""".stripIndent))
    test "autocorrects the range not starting with zero":
      var corrected = autocorrectSource("""        (3..7).each do
        end
""".stripIndent)
      expect(corrected).to(eq("""        5.times do
        end
""".stripIndent))
    test "does not autocorrect range not starting with zero and using param":
      var
        source = """        (3..7).each do |n|
        end
""".stripIndent
        corrected = autocorrectSource(source)
      expect(corrected).to(eq(source)))
  context("when using an exclusive range", proc (): void =
    test "autocorrects the source with inline block":
      var corrected = autocorrectSource("(0...10).each {}")
      expect(corrected).to(eq("10.times {}"))
    test "autocorrects the source with multiline block":
      var corrected = autocorrectSource("""        (0...10).each do
        end
""".stripIndent)
      expect(corrected).to(eq("""        10.times do
        end
""".stripIndent))
    test "autocorrects the range not starting with zero":
      var corrected = autocorrectSource("""        (3...7).each do
        end
""".stripIndent)
      expect(corrected).to(eq("""        4.times do
        end
""".stripIndent))
    test "does not autocorrect range not starting with zero and using param":
      var
        source = """        (3...7).each do |n|
        end
""".stripIndent
        corrected = autocorrectSource(source)
      expect(corrected).to(eq(source)))
