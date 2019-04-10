
import
  special_global_vars, test_tools

RSpec.describe(SpecialGlobalVars, "config", proc (): void =
  var cop = ()
  context("when style is use_english_names", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "use_english_names"}.newTable())
    test "registers an offense for $:":
      expectOffense("""        puts $:
             ^^ Prefer `$LOAD_PATH` over `$:`.
""".stripIndent)
    test "registers an offense for $\"":
      expectOffense("""        puts $"
             ^^ Prefer `$LOADED_FEATURES` over `$"`.
""".stripIndent)
    test "registers an offense for $0":
      expectOffense("""        puts $0
             ^^ Prefer `$PROGRAM_NAME` over `$0`.
""".stripIndent)
    test "registers an offense for $$":
      expectOffense("""        puts $$
             ^^ Prefer `$PROCESS_ID` or `$PID` from the stdlib 'English' module (don't forget to require it) over `$$`.
""".stripIndent)
    test "is clear about variables from the English library vs those not":
      expectOffense("""        puts $*
             ^^ Prefer `$ARGV` from the stdlib 'English' module (don't forget to require it) or `ARGV` over `$*`.
""".stripIndent)
    test "does not register an offense for backrefs like $1":
      expectNoOffenses("puts $1")
    test "auto-corrects $: to $LOAD_PATH":
      var newSource = autocorrectSource("$:")
      expect(newSource).to(eq("$LOAD_PATH"))
    test "auto-corrects $/ to $INPUT_RECORD_SEPARATOR":
      var newSource = autocorrectSource("$/")
      expect(newSource).to(eq("$INPUT_RECORD_SEPARATOR"))
    test "auto-corrects #$: to #{$LOAD_PATH}":
      var newSource = autocorrectSource("\"#$:\"")
      expect(newSource).to(eq("\"#{$LOAD_PATH}\""))
    test "auto-corrects #{$!} to #{$ERROR_INFO}":
      var newSource = autocorrectSource("\"#{$!}\"")
      expect(newSource).to(eq("\"#{$ERROR_INFO}\""))
    test "generates correct auto-config when Perl variable names are used":
      inspectSource("$0")
      expect(cop().configToAllowOffenses).to(eq())
    test "generates correct auto-config when mixed styles are used":
      inspectSource("$!; $ERROR_INFO")
      expect(cop().configToAllowOffenses).to(eq()))
  context("when style is use_perl_names", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "use_perl_names"}.newTable())
    test "registers an offense for $LOAD_PATH":
      expectOffense("""        puts $LOAD_PATH
             ^^^^^^^^^^ Prefer `$:` over `$LOAD_PATH`.
""".stripIndent)
    test "registers an offense for $LOADED_FEATURES":
      expectOffense("""        puts $LOADED_FEATURES
             ^^^^^^^^^^^^^^^^ Prefer `$"` over `$LOADED_FEATURES`.
""".stripIndent)
    test "registers an offense for $PROGRAM_NAME":
      expectOffense("""        puts $PROGRAM_NAME
             ^^^^^^^^^^^^^ Prefer `$0` over `$PROGRAM_NAME`.
""".stripIndent)
    test "registers an offense for $PID":
      expectOffense("""        puts $PID
             ^^^^ Prefer `$$` over `$PID`.
""".stripIndent)
    test "registers an offense for $PROCESS_ID":
      expectOffense("""        puts $PROCESS_ID
             ^^^^^^^^^^^ Prefer `$$` over `$PROCESS_ID`.
""".stripIndent)
    test "does not register an offense for backrefs like $1":
      expectNoOffenses("puts $1")
    test "auto-corrects $LOAD_PATH to $:":
      var newSource = autocorrectSource("$LOAD_PATH")
      expect(newSource).to(eq("$:"))
    test "auto-corrects $INPUT_RECORD_SEPARATOR to $/":
      var newSource = autocorrectSource("$INPUT_RECORD_SEPARATOR")
      expect(newSource).to(eq("$/"))
    test "auto-corrects #{$LOAD_PATH} to #$:":
      var newSource = autocorrectSource("\"#{$LOAD_PATH}\"")
      expect(newSource).to(eq("\"#$:\""))))
