
import
  unneeded_interpolation, test_tools

suite "UnneededInterpolation":
  var cop = UnneededInterpolation()
  test "registers an offense for \"#{1 + 1}\"":
    expectOffense("""      "#{1 + 1}"
      ^^^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      (1 + 1).to_s\n".stripIndent)
  test "registers an offense for \"%|#{1 + 1}|\"":
    expectOffense("""      %|#{1 + 1}|
      ^^^^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      (1 + 1).to_s\n".stripIndent)
  test "registers an offense for \"%Q(#{1 + 1})\"":
    expectOffense("""      %Q(#{1 + 1})
      ^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      (1 + 1).to_s\n".stripIndent)
  test "registers an offense for \"#{1 + 1; 2 + 2}\"":
    expectOffense("""      "#{1 + 1; 2 + 2}"
      ^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      (1 + 1; 2 + 2).to_s\n".stripIndent)
  test "registers an offense for \"#{@var}\"":
    expectOffense("""      "#{@var}"
      ^^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      @var.to_s\n".stripIndent)
  test "registers an offense for \"#@var\"":
    expectOffense("""      "#@var"
      ^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      @var.to_s\n".stripIndent)
  test "registers an offense for \"#{@@var}\"":
    expectOffense("""      "#{@@var}"
      ^^^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      @@var.to_s\n".stripIndent)
  test "registers an offense for \"#@@var\"":
    expectOffense("""      "#@@var"
      ^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      @@var.to_s\n".stripIndent)
  test "registers an offense for \"#{$var}\"":
    expectOffense("""      "#{$var}"
      ^^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      $var.to_s\n".stripIndent)
  test "registers an offense for \"#$var\"":
    expectOffense("""      "#$var"
      ^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      $var.to_s\n".stripIndent)
  test "registers an offense for \"#{$1}\"":
    expectOffense("""      "#{$1}"
      ^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      $1.to_s\n".stripIndent)
  test "registers an offense for \"#$1\"":
    expectOffense("""      "#$1"
      ^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      $1.to_s\n".stripIndent)
  test "registers an offense for \"#{$+}\"":
    expectOffense("""      "#{$+}"
      ^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      $+.to_s\n".stripIndent)
  test "registers an offense for \"#$+\"":
    expectOffense("""      "#$+"
      ^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      $+.to_s\n".stripIndent)
  test "registers an offense for \"#{var}\"":
    expectOffense("""      var = 1; "#{var}"
               ^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      var = 1; var.to_s\n".stripIndent)
  test "registers an offense for [\"#{@var}\"]":
    expectOffense("""      ["#{@var}", 'foo']
       ^^^^^^^^^ Prefer `to_s` over string interpolation.
""".stripIndent)
    expectCorrection("      [@var.to_s, \'foo\']\n".stripIndent)
  test "accepts strings with characters before the interpolation":
    expectNoOffenses("\"this is #{@sparta}\"")
  test "accepts strings with characters after the interpolation":
    expectNoOffenses("\"#{@sparta} this is\"")
  test "accepts strings implicitly concatenated with a later string":
    expectNoOffenses("\"#{sparta}\" \' this is\'")
  test "accepts strings implicitly concatenated with an earlier string":
    expectNoOffenses("\'this is \' \"#{sparta}\"")
  test "accepts strings that are part of a %W()":
    expectNoOffenses("%W(#{@var} foo)")
