
import
  perl_backrefs, test_tools

suite "PerlBackrefs":
  var cop = PerlBackrefs()
  test "registers an offense for $1":
    expectOffense("""      puts $1
           ^^ Avoid the use of Perl-style backrefs.
""".stripIndent)
  test "auto-corrects $1 to Regexp.last_match(1)":
    var newSource = autocorrectSource("$1")
    expect(newSource).to(eq("Regexp.last_match(1)"))
  test "auto-corrects #$1 to #{Regexp.last_match(1)}":
    var newSource = autocorrectSource("\"#$1\"")
    expect(newSource).to(eq("\"#{Regexp.last_match(1)}\""))
