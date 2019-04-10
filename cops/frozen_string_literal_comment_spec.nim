
import
  frozen_string_literal_comment, test_tools

RSpec.describe(FrozenStringLiteralComment, "config", proc (): void =
  var cop = ()
  context("always", proc (): void =
    let("cop_config", proc (): void =
      {"Enabled": true, "EnforcedStyle": "always"}.newTable())
    test "accepts an empty source":
      expectNoOffenses("")
    test "accepts a source with no tokens":
      expectNoOffenses(" ")
    test "accepts a frozen string literal on the top line":
      expectNoOffenses("""        # frozen_string_literal: true
        puts 1
""".stripIndent)
    test "accepts a disabled frozen string literal on the top line":
      expectNoOffenses("""        # frozen_string_literal: false
        puts 1
""".stripIndent)
    test """registers an offense for not having a frozen string literal comment on the top line""":
      expectOffense("""        puts 1
        ^ Missing magic comment `# frozen_string_literal: true`.
""".stripIndent)
    test """registers an offense for not having a frozen string literal comment under a shebang""":
      expectOffense("""        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
        puts 1
""".stripIndent)
    test "accepts a frozen string literal below a shebang comment":
      expectNoOffenses("""        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
""".stripIndent)
    test "accepts a disabled frozen string literal below a shebang comment":
      expectNoOffenses("""        #!/usr/bin/env ruby
        # frozen_string_literal: false
        puts 1
""".stripIndent)
    test """registers an offense for not having a frozen string literal comment under an encoding comment""":
      expectOffense("""        # encoding: utf-8
        ^ Missing magic comment `# frozen_string_literal: true`.
        puts 1
""".stripIndent)
    test "accepts a frozen string literal below an encoding comment":
      expectNoOffenses("""        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
""".stripIndent)
    test "accepts a dsabled frozen string literal below an encoding comment":
      expectNoOffenses("""        # encoding: utf-8
        # frozen_string_literal: false
        puts 1
""".stripIndent)
    test """registers an offense for not having a frozen string literal comment under a shebang and an encoding comment""":
      expectOffense("""        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
        # encoding: utf-8
        puts 1
""".stripIndent)
    test """accepts a frozen string literal comment below shebang and encoding comments""":
      expectNoOffenses("""        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: true
        puts 1
""".stripIndent)
    test """accepts a disabled frozen string literal comment below shebang and encoding comments""":
      expectNoOffenses("""        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: false
        puts 1
""".stripIndent)
    test """accepts a frozen string literal comment below shebang above an encoding comments""":
      expectNoOffenses("""        #!/usr/bin/env ruby
        # frozen_string_literal: true
        # encoding: utf-8
        puts 1
""".stripIndent)
    test """accepts a disabled frozen string literal comment below shebang above an encoding comments""":
      expectNoOffenses("""        #!/usr/bin/env ruby
        # frozen_string_literal: false
        # encoding: utf-8
        puts 1
""".stripIndent)
    test "accepts an emacs style combined magic comment":
      expectNoOffenses("""        #!/usr/bin/env ruby
        # -*- encoding: UTF-8; frozen_string_literal: true -*-
        # encoding: utf-8
        puts 1
""".stripIndent)
    test """registers an offence for not having a frozen string literal comment when there is only a shebang""":
      expectOffense("""        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
""".stripIndent)
    context("auto-correct", proc (): void =
      test """adds a frozen string literal comment to the first line if one is missing""":
        var newSource = autocorrectSource("          puts 1\n".stripIndent)
        expect(newSource).to(eq("""          # frozen_string_literal: true

          puts 1
""".stripIndent))
      test """adds a frozen string literal comment to the first line if one is missing and handles extra spacing""":
        var newSource = autocorrectSource("""
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          # frozen_string_literal: true

          puts 1
""".stripIndent))
      test "adds a frozen string literal comment after a shebang":
        var newSource = autocorrectSource("""          #!/usr/bin/env ruby
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          # frozen_string_literal: true

          puts 1
""".stripIndent))
      test "adds a frozen string literal comment after an encoding comment":
        var newSource = autocorrectSource("""          # encoding: utf-8
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
""".stripIndent))
      test """adds a frozen string literal comment after a shebang and encoding comment""":
        var newSource = autocorrectSource("""          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
""".stripIndent))
      test """adds a frozen string literal comment after a shebang and encoding comment when there is an empty line before the code""":
        var newSource = autocorrectSource("""          #!/usr/bin/env ruby
          # encoding: utf-8

          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
""".stripIndent))
      test """adds a frozen string literal comment after an encoding comment when there is an empty line before the code""":
        var newSource = autocorrectSource("""          # encoding: utf-8

          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          # encoding: utf-8
          # frozen_string_literal: true

          puts 1
""".stripIndent))
      test """adds a frozen string literal comment after a shebang when there is only a shebang""":
        var newSource = autocorrectSource("          #!/usr/bin/env ruby\n".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          # frozen_string_literal: true
""".stripIndent))))
  context("when_needed", proc (): void =
    let("cop_config", proc (): void =
      {"Enabled": true, "EnforcedStyle": "when_needed"}.newTable())
    test "accepts an empty source":
      expectNoOffenses("")
    if RUBYVERSION >= "2.3.0":
      context("ruby >= 2.3", proc (): void =
        context("no frozen string literal comment", proc (): void =
          test "accepts not modifing a string":
            expectNoOffenses("puts \"x\"")
          test "accepts calling + on a string":
            expectNoOffenses("\"x\" + \"y\"")
          test "accepts calling freeze on a variable":
            expectNoOffenses("""              foo = "x"
                foo.freeze
""".stripIndent)
          test "accepts calling shovel on a variable":
            expectNoOffenses("""              foo = "x"
                foo << "y"
""".stripIndent)
          test "accepts freezing a string":
            expectNoOffenses("\"x\".freeze")
          test "accepts when << is called on a string literal":
            expectNoOffenses("\"x\" << \"y\""))
        test """accepts freezing a string when there is a frozen string literal comment""":
          expectNoOffenses("""            # frozen_string_literal: true
            "x".freeze
""".stripIndent)
        test """accepts shoveling into a string when there is a frozen string literal comment""":
          expectNoOffenses("""            # frozen_string_literal: true
            "x" << "y"
""".stripIndent))
    context("target_ruby_version < 2.3", "ruby22", proc (): void =
      test "accepts freezing a string":
        expectNoOffenses("\"x\".freeze")
      test "accepts calling << on a string":
        expectNoOffenses("\"x\" << \"y\"")
      test "accepts freezing a string with interpolation":
        expectNoOffenses("\"#{foo}bar\".freeze")
      test "accepts calling << on a string with interpolation":
        expectNoOffenses("\"#{foo}bar\" << \"baz\""))
    context("target_ruby_version 2.3+", "ruby23", proc (): void =
      test "accepts freezing a string":
        expectOffense("""          "x".freeze
          ^ Missing magic comment `# frozen_string_literal: true`.
""".stripIndent)
      test "accepts calling << on a string":
        expectOffense("""          "x" << "y"
          ^ Missing magic comment `# frozen_string_literal: true`.
""".stripIndent)
      test "accepts freezing a string with interpolation":
        expectOffense("""          "#{foo}bar".freeze
          ^ Missing magic comment `# frozen_string_literal: true`.
""".stripIndent)
      test "accepts calling << on a string with interpolation":
        expectOffense("""          "#{foo}bar" << "baz"
          ^ Missing magic comment `# frozen_string_literal: true`.
""".stripIndent)))
  context("never", proc (): void =
    let("cop_config", proc (): void =
      {"Enabled": true, "EnforcedStyle": "never"}.newTable())
    test "accepts an empty source":
      expectNoOffenses("")
    test "accepts a source with no tokens":
      expectNoOffenses(" ")
    test """registers an offense for a frozen string literal comment on the top line""":
      expectOffense("""        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
""".stripIndent)
    test """registers an offense for a disabled frozen string literal comment on the top line""":
      expectOffense("""        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
""".stripIndent)
    test "accepts not having a frozen string literal comment on the top line":
      expectNoOffenses("puts 1")
    test """accepts not having not having a frozen string literal comment under a shebang""":
      expectNoOffenses("""        #!/usr/bin/env ruby
        puts 1
""".stripIndent)
    test """registers an offense for a frozen string literal comment below a shebang comment""":
      expectOffense("""        #!/usr/bin/env ruby
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
""".stripIndent)
    test """registers an offense for a disabled frozen string literal below a shebang comment""":
      expectOffense("""        #!/usr/bin/env ruby
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
""".stripIndent)
    test """allows not having a frozen string literal comment under an encoding comment""":
      expectNoOffenses("""        # encoding: utf-8
        puts 1
""".stripIndent)
    test """registers an offense for a frozen string literal comment below an encoding comment""":
      expectOffense("""        # encoding: utf-8
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
""".stripIndent)
    test """registers an offense for a dsabled frozen string literal below an encoding comment""":
      expectOffense("""        # encoding: utf-8
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
""".stripIndent)
    test """allows not having a frozen string literal comment under a shebang and an encoding comment""":
      expectNoOffenses("""        #!/usr/bin/env ruby
        # encoding: utf-8
        puts 1
""".stripIndent)
    test """registers an offense for a frozen string literal comment below shebang and encoding comments""":
      expectOffense("""        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
""".stripIndent)
    test """registers an offense for a disabled frozen string literal comment below shebang and encoding comments""":
      expectOffense("""        #!/usr/bin/env ruby
        # encoding: utf-8
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
""".stripIndent)
    test """registers an offense for a frozen string literal comment below shebang above an encoding comments""":
      expectOffense("""        #!/usr/bin/env ruby
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        # encoding: utf-8
        puts 1
""".stripIndent)
    test """registers an offense for a disabled frozen string literal comment below shebang above an encoding comments""":
      expectOffense("""        #!/usr/bin/env ruby
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        # encoding: utf-8
        puts 1
""".stripIndent)
    context("auto-correct", proc (): void =
      test "removes the frozen string literal comment from the top line":
        var newSource = autocorrectSource("""          # frozen_string_literal: true
          puts 1
""".stripIndent)
        expect(newSource).to(eq("          puts 1\n".stripIndent))
      test "removes a disabled frozen string literal comment on the top line":
        var newSource = autocorrectSource("""          # frozen_string_literal: false
          puts 1
""".stripIndent)
        expect(newSource).to(eq("          puts 1\n".stripIndent))
      test "removes a frozen string literal comment below a shebang comment":
        var newSource = autocorrectSource("""          #!/usr/bin/env ruby
          # frozen_string_literal: true
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          puts 1
""".stripIndent))
      test "removes a disabled frozen string literal below a shebang comment":
        var newSource = autocorrectSource("""          #!/usr/bin/env ruby
          # frozen_string_literal: false
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          puts 1
""".stripIndent))
      test "removes a frozen string literal comment below an encoding comment":
        var newSource = autocorrectSource("""          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          # encoding: utf-8
          puts 1
""".stripIndent))
      test "removes a dsabled frozen string literal below an encoding comment":
        var newSource = autocorrectSource("""          # encoding: utf-8
          # frozen_string_literal: false
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          # encoding: utf-8
          puts 1
""".stripIndent))
      test """removes a frozen string literal comment below shebang and encoding comments""":
        var newSource = autocorrectSource("""          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: true
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
""".stripIndent))
      test """removes a disabled frozen string literal comment from below shebang and encoding comments""":
        var newSource = autocorrectSource("""          #!/usr/bin/env ruby
          # encoding: utf-8
          # frozen_string_literal: false
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
""".stripIndent))
      test """removes a frozen string literal comment below shebang above an encoding comments""":
        var newSource = autocorrectSource("""          #!/usr/bin/env ruby
          # frozen_string_literal: true
          # encoding: utf-8
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
""".stripIndent))
      test """removes a disabled frozen string literal comment below shebang above an encoding comments""":
        var newSource = autocorrectSource("""          #!/usr/bin/env ruby
          # frozen_string_literal: false
          # encoding: utf-8
          puts 1
""".stripIndent)
        expect(newSource).to(eq("""          #!/usr/bin/env ruby
          # encoding: utf-8
          puts 1
""".stripIndent)))))
