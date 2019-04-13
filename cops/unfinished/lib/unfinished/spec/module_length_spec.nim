
import
  module_length, test_tools

RSpec.describe(ModuleLength, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"Max": 5, "CountComments": false}.newTable())
  test "rejects a module with more than 5 lines":
    expectOffense("""      module Test
      ^^^^^^^^^^^ Module has too many lines. [6/5]
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
""".stripIndent)
  test "reports the correct beginning and end lines":
    inspectSource("""      module Test
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
  test "accepts a module with 5 lines":
    expectNoOffenses("""      module Test
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
      end
""".stripIndent)
  test "accepts a module with less than 5 lines":
    expectNoOffenses("""      module Test
        a = 1
        a = 2
        a = 3
        a = 4
      end
""".stripIndent)
  test "does not count blank lines":
    expectNoOffenses("""      module Test
        a = 1
        a = 2
        a = 3
        a = 4


        a = 7
      end
""".stripIndent)
  test "accepts empty modules":
    expectNoOffenses("""      module Test
      end
""".stripIndent)
  context("when a module has inner modules", proc (): void =
    test "does not count lines of inner modules":
      expectNoOffenses("""        module NamespaceModule
          module TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          module TestTwo
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
    test "rejects a module with 6 lines that belong to the module directly":
      expectOffense("""        module NamespaceModule
        ^^^^^^^^^^^^^^^^^^^^^^ Module has too many lines. [6/5]
          module TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          module TestTwo
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
  context("when a module has inner classes", proc (): void =
    test "does not count lines of inner classes":
      expectNoOffenses("""        module NamespaceModule
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
    test "rejects a module with 6 lines that belong to the module directly":
      expectOffense("""        module NamespaceModule
        ^^^^^^^^^^^^^^^^^^^^^^ Module has too many lines. [6/5]
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
      expectOffense("""        module Test
        ^^^^^^^^^^^ Module has too many lines. [6/5]
          a = 1
          #a = 2
          a = 3
          #a = 4
          a = 5
          a = 6
        end
""".stripIndent))
  context("when inspecting a class defined with Module.new", proc (): void =
    test "registers an offense":
      expectOffense("""        Foo = Module.new do
        ^^^ Module has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
""".stripIndent)))
