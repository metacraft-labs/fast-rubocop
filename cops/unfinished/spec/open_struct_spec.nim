
import
  open_struct, test_tools

suite "OpenStruct":
  var cop = OpenStruct()
  let("config", proc (): void =
    Config.new)
  test "registers an offense for OpenStruct.new":
    expectOffense("""      OpenStruct.new(key: "value")
                 ^^^ Consider using `Struct` over `OpenStruct` to optimize the performance.
""".stripIndent)
  test "registers an offense for a fully qualified ::OpenStruct.new":
    expectOffense("""      ::OpenStruct.new(key: "value")
                   ^^^ Consider using `Struct` over `OpenStruct` to optimize the performance.
""".stripIndent)
  test "does not register offense for Struct":
    expectNoOffenses("""      MyStruct = Struct.new(:key)
      MyStruct.new('value')
""".stripIndent)
