
import
  flip_flop, test_tools

suite "FlipFlop":
  var cop = FlipFlop()
  test "registers an offense for inclusive flip-flops":
    expectOffense("""      DATA.each_line do |line|
      print line if (line =~ /begin/)..(line =~ /end/)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid the use of flip-flop operators.
      end
""".stripIndent)
  test "registers an offense for exclusive flip-flops":
    expectOffense("""      DATA.each_line do |line|
      print line if (line =~ /begin/)...(line =~ /end/)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid the use of flip-flop operators.
      end
""".stripIndent)
