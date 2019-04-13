
import
  block_length, test_tools

RSpec.describe(BlockLength, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"Max": 2, "CountComments": false}.newTable())
  sharedExamples("ignoring an offense on an excluded method", proc (
      excluded: string): void =
    before(proc (): void =
      copConfig().[]=("ExcludedMethods", @[excluded]))
    test "still rejects other methods with long blocks":
      expectOffense("""        something do
        ^^^^^^^^^^^^ Block has too many lines. [3/2]
          a = 1
          a = 2
          a = 3
        end
""".stripIndent)
    test "accepts the foo method with a long block":
      expectNoOffenses("""        (lvar :excluded) do
          a = 1
          a = 2
          a = 3
        end
""".stripIndent))
  test "rejects a block with more than 5 lines":
    expectOffense("""      something do
      ^^^^^^^^^^^^ Block has too many lines. [3/2]
        a = 1
        a = 2
        a = 3
      end
""".stripIndent)
  test "reports the correct beginning and end lines":
    inspectSource("""      something do
        a = 1
        a = 2
        a = 3
      end
""".stripIndent)
    var offense = cop().offenses[0]
    expect(offense.location.firstLine).to(eq(1))
    expect(offense.location.lastLine).to(eq(5))
  test "accepts a block with less than 3 lines":
    expectNoOffenses("""      something do
        a = 1
        a = 2
      end
""".stripIndent)
  test "does not count blank lines":
    expectNoOffenses("""      something do
        a = 1


        a = 4
      end
""".stripIndent)
  test "accepts a block with multiline receiver and less than 3 lines of body":
    expectNoOffenses("""      [
        :a,
        :b,
        :c,
      ].each do
        a = 1
        a = 2
      end
""".stripIndent)
  test "accepts empty blocks":
    expectNoOffenses("""      something do
      end
""".stripIndent)
  test "rejects brace blocks too":
    expectOffense("""      something {
      ^^^^^^^^^^^ Block has too many lines. [3/2]
        a = 1
        a = 2
        a = 3
      }
""".stripIndent)
  test "properly counts nested blocks":
    expectOffense("""      something do
      ^^^^^^^^^^^^ Block has too many lines. [6/2]
        something do
        ^^^^^^^^^^^^ Block has too many lines. [4/2]
          a = 2
          a = 3
          a = 4
          a = 5
        end
      end
""".stripIndent)
  test "does not count commented lines by default":
    expectNoOffenses("""      something do
        a = 1
        #a = 2
        #a = 3
        a = 4
      end
""".stripIndent)
  context("when defining a class", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        Class.new do
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
""".stripIndent))
  context("when defining a module", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        Module.new do
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
""".stripIndent))
  context("when CountComments is enabled", proc (): void =
    before(proc (): void =
      copConfig().[]=("CountComments", true))
    test "also counts commented lines":
      expectOffense("""        something do
        ^^^^^^^^^^^^ Block has too many lines. [3/2]
          a = 1
          #a = 2
          a = 3
        end
""".stripIndent))
  context("when ExcludedMethods is enabled", proc (): void =
    itBehavesLike("ignoring an offense on an excluded method", "foo")
    itBehavesLike("ignoring an offense on an excluded method",
                  "Gem::Specification.new")
    context("when receiver contains whitespaces", proc (): void =
      before(proc (): void =
        copConfig().[]=("ExcludedMethods", @["Foo::Bar.baz"]))
      test "ignores whitespaces":
        expectNoOffenses("""          Foo::
            Bar.baz do
            a = 1
            a = 2
            a = 3
          end
""".stripIndent))
    context("when a method is ignored, but receiver is a module", proc (): void =
      before(proc (): void =
        copConfig().[]=("ExcludedMethods", @["baz"]))
      test "does not report an offense":
        expectNoOffenses("""          Foo::Bar.baz do
            a = 1
            a = 2
            a = 3
          end
""".stripIndent))))
