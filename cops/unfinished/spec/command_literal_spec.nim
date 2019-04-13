
import
  command_literal, test_tools

RSpec.describe(CommandLiteral, "config", proc (): void =
  var cop = ()
  let("config", proc (): void =
    var supportedStyles = {"SupportedStyles": @["backticks", "percent_x", "mixed"]}.newTable()
    Config.new())
  let("percent_literal_delimiters_config", proc (): void =
    {"PreferredDelimiters": {"%x": "()"}.newTable()}.newTable())
  describe("%x commands with other delimiters than parentheses", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "backticks"}.newTable())
    test "registers an offense":
      expectOffense("""        %x$ls$
        ^^^^^^ Use backticks around command string.
""".stripIndent))
  describe("when PercentLiteralDelimiters is configured with curly braces", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "percent_x"}.newTable())
    let("percent_literal_delimiters_config", proc (): void =
      {"PreferredDelimiters": {"%x": "[]"}.newTable()}.newTable())
    test "respects the configuration when auto-correcting":
      var newSource = autocorrectSource("`ls`")
      expect(newSource).to(eq("%x[ls]")))
  describe("when PercentLiteralDelimiters only has a default", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "percent_x"}.newTable())
    let("percent_literal_delimiters_config", proc (): void =
      {"PreferredDelimiters": {"default": "()"}.newTable()}.newTable())
    test "respects the configuration when auto-correcting":
      var newSource = autocorrectSource("`ls`")
      expect(newSource).to(eq("%x(ls)")))
  describe("when PercentLiteralDelimiters is configured and a default exists", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "percent_x"}.newTable())
    let("percent_literal_delimiters_config", proc (): void =
      {"PreferredDelimiters": {"%x": "[]", "default": "()"}.newTable()}.newTable())
    test "ignores the default when auto-correcting and":
      var newSource = autocorrectSource("`ls`")
      expect(newSource).to(eq("%x[ls]")))
  describe("heredoc commands", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "backticks"}.newTable())
    test "is ignored":
      expectNoOffenses("""        <<`COMMAND`
          ls
        COMMAND
""".stripIndent))
  context("when EnforcedStyle is set to backticks", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "backticks"}.newTable())
    describe("a single-line ` string without backticks", proc (): void =
      test "is accepted":
        expectNoOffenses("foo = `ls`"))
    describe("a single-line ` string with backticks", proc (): void =
      let("source", proc (): void =
        "foo = `echo \\`ls\\``")
      test "registers an offense":
        expectOffense("""          foo = `echo \`ls\``
                ^^^^^^^^^^^^^ Use `%x` around command string.
""".stripIndent)
      test "cannot auto-correct":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq(source()))
      describe("when configured to allow inner backticks", proc (): void =
        before(proc (): void =
          copConfig().[]=("AllowInnerBackticks", true))
        test "is accepted":
          expectNoOffenses("foo = `echo \\`ls\\``")))
    describe("a multi-line ` string without backticks", proc (): void =
      test "is accepted":
        expectNoOffenses("""          foo = `
            ls
            ls -l
          `
""".stripIndent))
    describe("a multi-line ` string with backticks", proc (): void =
      let("source", proc (): void =
        """          foo = `
            echo `ls`
            echo `ls -l`
          `
""".stripIndent)
      test "registers an offense":
        expectOffense("""          foo = `
                ^ Use `%x` around command string.
            echo \`ls\`
            echo \`ls -l\`
          `
""".stripIndent)
      test "cannot auto-correct":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq(source()))
      describe("when configured to allow inner backticks", proc (): void =
        before(proc (): void =
          copConfig().[]=("AllowInnerBackticks", true))
        test "is accepted":
          expectNoOffenses("""            foo = `
              echo \`ls\`
              echo \`ls -l\`
            `
""".stripIndent)))
    describe("a single-line %x string without backticks", proc (): void =
      let("source", proc (): void =
        "foo = %x(ls)")
      test "registers an offense":
        expectOffense("""          foo = %x(ls)
                ^^^^^^ Use backticks around command string.
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq("foo = `ls`")))
    describe("a single-line %x string with backticks", proc (): void =
      let("source", proc (): void =
        "foo = %x(echo `ls`)")
      test "is accepted":
        expectNoOffenses("foo = %x(echo `ls`)")
      describe("when configured to allow inner backticks", proc (): void =
        before(proc (): void =
          copConfig().[]=("AllowInnerBackticks", true))
        test "registers an offense":
          expectOffense("""            foo = %x(echo `ls`)
                  ^^^^^^^^^^^^^ Use backticks around command string.
""".stripIndent)
        test "cannot auto-correct":
          var newSource = autocorrectSource(source())
          expect(newSource).to(eq(source()))))
    describe("a multi-line %x string without backticks", proc (): void =
      let("source", proc (): void =
        """          foo = %x(
            ls
            ls -l
          )
""".stripIndent)
      test "registers an offense":
        expectOffense("""          foo = %x(
                ^^^ Use backticks around command string.
            ls
            ls -l
          )
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq("""          foo = `
            ls
            ls -l
          `
""".stripIndent)))
    describe("a multi-line %x string with backticks", proc (): void =
      let("source", proc (): void =
        """          foo = %x(
            echo `ls`
            echo `ls -l`
          )
""".stripIndent)
      test "is accepted":
        expectNoOffenses("""          foo = %x(
            echo `ls`
            echo `ls -l`
          )
""".stripIndent)
      describe("when configured to allow inner backticks", proc (): void =
        before(proc (): void =
          copConfig().[]=("AllowInnerBackticks", true))
        test "registers an offense":
          expectOffense("""            foo = %x(
                  ^^^ Use backticks around command string.
              echo `ls`
              echo `ls -l`
            )
""".stripIndent)
        test "cannot auto-correct":
          var newSource = autocorrectSource(source())
          expect(newSource).to(eq(source())))))
  context("when EnforcedStyle is set to percent_x", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "percent_x"}.newTable())
    describe("a single-line ` string without backticks", proc (): void =
      let("source", proc (): void =
        "foo = `ls`")
      test "registers an offense":
        expectOffense("""          foo = `ls`
                ^^^^ Use `%x` around command string.
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq("foo = %x(ls)")))
    describe("a single-line ` string with backticks", proc (): void =
      let("source", proc (): void =
        "foo = `echo \\`ls\\``")
      test "registers an offense":
        expectOffense("""          foo = `echo \`ls\``
                ^^^^^^^^^^^^^ Use `%x` around command string.
""".stripIndent)
      test "cannot auto-correct":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq(source())))
    describe("a multi-line ` string without backticks", proc (): void =
      let("source", proc (): void =
        """          foo = `
            ls
            ls -l
          `
""".stripIndent)
      test "registers an offense":
        expectOffense("""          foo = `
                ^ Use `%x` around command string.
            ls
            ls -l
          `
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq("""          foo = %x(
            ls
            ls -l
          )
""".stripIndent)))
    describe("a multi-line ` string with backticks", proc (): void =
      let("source", proc (): void =
        """          foo = `
            echo \`ls\`
            echo \`ls -l\`
          `
""".stripIndent)
      test "registers an offense":
        expectOffense("""          foo = `
                ^ Use `%x` around command string.
            echo \`ls\`
            echo \`ls -l\`
          `
""".stripIndent)
      test "cannot auto-correct":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq(source())))
    describe("a single-line %x string without backticks", proc (): void =
      test "is accepted":
        expectNoOffenses("foo = %x(ls)"))
    describe("a single-line %x string with backticks", proc (): void =
      test "is accepted":
        expectNoOffenses("foo = %x(echo `ls`)"))
    describe("a multi-line %x string without backticks", proc (): void =
      test "is accepted":
        expectNoOffenses("""          foo = %x(
            ls
            ls -l
          )
""".stripIndent))
    describe("a multi-line %x string with backticks", proc (): void =
      test "is accepted":
        expectNoOffenses("""          foo = %x(
            echo `ls`
            echo `ls -l`
          )
""".stripIndent)))
  context("when EnforcedStyle is set to mixed", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "mixed"}.newTable())
    describe("a single-line ` string without backticks", proc (): void =
      test "is accepted":
        expectNoOffenses("foo = `ls`"))
    describe("a single-line ` string with backticks", proc (): void =
      let("source", proc (): void =
        "foo = `echo \\`ls\\``")
      test "registers an offense":
        expectOffense("""          foo = `echo \`ls\``
                ^^^^^^^^^^^^^ Use `%x` around command string.
""".stripIndent)
      test "cannot auto-correct":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq(source()))
      describe("when configured to allow inner backticks", proc (): void =
        before(proc (): void =
          copConfig().[]=("AllowInnerBackticks", true))
        test "is accepted":
          expectNoOffenses("foo = `echo \\`ls\\``")))
    describe("a multi-line ` string without backticks", proc (): void =
      let("source", proc (): void =
        """          foo = `
            ls
            ls -l
          `
""".stripIndent)
      test "registers an offense":
        expectOffense("""          foo = `
                ^ Use `%x` around command string.
            ls
            ls -l
          `
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq("""          foo = %x(
            ls
            ls -l
          )
""".stripIndent)))
    describe("a multi-line ` string with backticks", proc (): void =
      let("source", proc (): void =
        """          foo = `
            echo \`ls\`
            echo \`ls -l\`
          `
""".stripIndent)
      test "registers an offense":
        expectOffense("""          foo = `
                ^ Use `%x` around command string.
            echo \`ls\`
            echo \`ls -l\`
          `
""".stripIndent)
      test "cannot auto-correct":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq(source())))
    describe("a single-line %x string without backticks", proc (): void =
      let("source", proc (): void =
        "foo = %x(ls)")
      test "registers an offense":
        expectOffense("""          foo = %x(ls)
                ^^^^^^ Use backticks around command string.
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource(source())
        expect(newSource).to(eq("foo = `ls`")))
    describe("a single-line %x string with backticks", proc (): void =
      let("source", proc (): void =
        "foo = %x(echo `ls`)")
      test "is accepted":
        expectNoOffenses("foo = %x(echo `ls`)")
      describe("when configured to allow inner backticks", proc (): void =
        before(proc (): void =
          copConfig().[]=("AllowInnerBackticks", true))
        test "registers an offense":
          expectOffense("""            foo = %x(echo `ls`)
                  ^^^^^^^^^^^^^ Use backticks around command string.
""".stripIndent)
        test "cannot auto-correct":
          var newSource = autocorrectSource(source())
          expect(newSource).to(eq(source()))))
    describe("a multi-line %x string without backticks", proc (): void =
      test "is accepted":
        expectNoOffenses("""          foo = %x(
            ls
            ls -l
          )
""".stripIndent))
    describe("a multi-line %x string with backticks", proc (): void =
      test "is accepted":
        expectNoOffenses("""          foo = %x(
            echo `ls`
            echo `ls -l`
          )
""".stripIndent))))
