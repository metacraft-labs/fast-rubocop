
import
  class_length, test_tools

RSpec.describe(ClassLength, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"Max": 5, "CountComments": false}.newTable())
  test "rejects a class with more than 5 lines":
    expectOffense("""      class Test
      ^^^^^^^^^^ Class has too many lines. [6/5]
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
""".stripIndent)
  test "reports the correct beginning and end lines":
    inspectSource("""      class Test
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
""".stripIndent)
    var offense = cop().offenses[0]
    expect(offense.location.firstLine).to(eq(1))
    expect(offense.location.lastLine).to(eq(8))
  test "accepts a class with 5 lines":
    expectNoOffenses("""      class Test
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
      end
""".stripIndent)
  test "accepts a class with less than 5 lines":
    expectNoOffenses("""      class Test
        a = 1
        a = 2
        a = 3
        a = 4
      end
""".stripIndent)
  test "does not count blank lines":
    expectNoOffenses("""      class Test
        a = 1
        a = 2
        a = 3
        a = 4


        a = 7
      end
""".stripIndent)
  test "accepts empty classes":
    expectNoOffenses("""      class Test
      end
""".stripIndent)
  context("when a class has inner classes", proc (): void =
    test "does not count lines of inner classes":
      expectNoOffenses("""        class NamespaceClass
          class TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          class TestTwo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
        end
""".stripIndent)
    test "rejects a class with 6 lines that belong to the class directly":
      expectOffense("""        class NamespaceClass
        ^^^^^^^^^^^^^^^^^^^^ Class has too many lines. [6/5]
          class TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          class TestTwo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
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
      expectOffense("""        class Test
        ^^^^^^^^^^ Class has too many lines. [6/5]
          a = 1
          #a = 2
          a = 3
          #a = 4
          a = 5
          a = 6
        end
""".stripIndent))
  context("when inspecting a class defined with Class.new", proc (): void =
    test "registers an offense":
      expectOffense("""        Foo = Class.new do
        ^^^ Class has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
""".stripIndent)))
