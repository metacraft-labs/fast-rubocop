
import
  number_conversion, test_tools

suite "NumberConversion":
  var cop = NumberConversion()
  let("config", proc (): void =
    Config.new)
  context("registers an offense", proc (): void =
    test "when using `#to_i`":
      expectOffense("""        "10".to_i
        ^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using "10".to_i, use stricter Integer("10", 10).
""".stripIndent)
    test "when using `#to_i` for integer":
      expectOffense("""        10.to_i
        ^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using 10.to_i, use stricter Integer(10, 10).
""".stripIndent)
    test "when using `#to_f`":
      expectOffense("""        "10.2".to_f
        ^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using "10.2".to_f, use stricter Float("10.2").
""".stripIndent)
    test "when using `#to_c`":
      expectOffense("""        "10".to_c
        ^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using "10".to_c, use stricter Complex("10").
""".stripIndent)
    test "when `#to_i` called on a variable":
      expectOffense("""        string_value = '10'
        string_value.to_i
        ^^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using string_value.to_i, use stricter Integer(string_value, 10).
""".stripIndent)
    test "when `#to_i` called on a hash value":
      expectOffense("""        params = { id: 10 }
        params[:id].to_i
        ^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using params[:id].to_i, use stricter Integer(params[:id], 10).
""".stripIndent)
    test "when `#to_i` called on a variable on a array":
      expectOffense("""        args = [1,2,3]
        args[0].to_i
        ^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using args[0].to_i, use stricter Integer(args[0], 10).
""".stripIndent))
  context("does not register an offense", proc (): void =
    test "when using Integer() with integer":
      expectNoOffenses("        Integer(10)\n".stripIndent)
    test "when using Float()":
      expectNoOffenses("        Float(\'10\')\n".stripIndent)
    test "when using Complex()":
      expectNoOffenses("        Complex(\'10\')\n".stripIndent))
