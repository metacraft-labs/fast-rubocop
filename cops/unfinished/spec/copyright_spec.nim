
import
  copyright, test_tools

RSpec.describe(Copyright, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"Notice": "Copyright (\\(c\\) )?2015 Acme Inc"}.newTable())
  test "does not register an offense when the notice is present":
    expectNoOffenses("""      # Copyright 2015 Acme Inc.
      # test2
      names = Array.new
      names << 'James'
""".stripIndent)
  test "does not register an offense when the notice is not the first comment":
    expectNoOffenses("""      # test2
      # Copyright 2015 Acme Inc.
      names = Array.new
      names << 'James'
""".stripIndent)
  test "does not register an offense when the notice is in a block comment":
    expectNoOffenses("""      =begin
      blah, blah, blah
      Copyright 2015 Acme Inc.
      =end
      names = Array.new
      names << 'James'
""".stripIndent)
  context("when the copyright notice is missing", proc (): void =
    let("source", proc (): void =
      """      # test
      # test2
      names = Array.new
      names << 'James'
""".stripIndent)
    test "adds an offense":
      expectCopyrightOffense(cop(), source())
    test "correctly autocorrects the source code":
      copConfig().[]=("AutocorrectNotice", "# Copyright (c) 2015 Acme Inc.")
      expect(autocorrectSource(source())).to(eq("""        # Copyright (c) 2015 Acme Inc.
        # test
        # test2
        names = Array.new
        names << 'James'
""".stripIndent))
    test """fails to autocorrect when the AutocorrectNotice does not match the Notice pattern""":
      copConfig().[]=("AutocorrectNotice", "# Copyleft (c) 2015 Acme Inc.")
      expect(proc (): void =
        autocorrectSource(source())).to(raiseError(Warning))
    test "fails to autocorrect if no AutocorrectNotice is given":
      expect(proc (): void =
        autocorrectSource(source())).to(raiseError(Warning)))
  context("when the copyright notice comes after any code", proc (): void =
    let("source", proc (): void =
      """      # test2
      names = Array.new
      # Copyright (c) 2015 Acme Inc.
      names << 'James'
""".stripIndent)
    test "adds an offense":
      expectCopyrightOffense(cop(), source())
    test "correctly autocorrects the source code":
      copConfig().[]=("AutocorrectNotice", "# Copyright (c) 2015 Acme Inc.")
      expect(autocorrectSource(source())).to(eq("""        # Copyright (c) 2015 Acme Inc.
        # test2
        names = Array.new
        # Copyright (c) 2015 Acme Inc.
        names << 'James'
""".stripIndent)))
  context("when the source code file is empty", proc (): void =
    let("source", proc (): void =
      "")
    test "adds an offense":
      expectCopyrightOffense(cop(), source())
    test "correctly autocorrects the source code":
      copConfig().[]=("AutocorrectNotice", "# Copyright (c) 2015 Acme Inc.")
      expect(autocorrectSource(source())).to(
          eq("# Copyright (c) 2015 Acme Inc.\n")))
  context("""when the copyright notice is missing and the source code file starts with a shebang""", proc (): void =
    let("source", proc (): void =
      """      #!/usr/bin/env ruby
      names = Array.new
      names << 'James'
""".stripIndent)
    test "adds an offense":
      expectCopyrightOffense(cop(), source())
    test "correctly autocorrects the source code":
      copConfig().[]=("AutocorrectNotice", "# Copyright (c) 2015 Acme Inc.")
      expect(autocorrectSource(source())).to(eq("""        #!/usr/bin/env ruby
        # Copyright (c) 2015 Acme Inc.
        names = Array.new
        names << 'James'
""".stripIndent)))
  context("""when the copyright notice is missing and the source code file starts with an encoding comment""", proc (): void =
    let("source", proc (): void =
      """      # encoding: utf-8
      names = Array.new
      names << 'James'
""".stripIndent)
    test "adds an offense":
      expectCopyrightOffense(cop(), source())
    test "correctly autocorrects the source code":
      copConfig().[]=("AutocorrectNotice", "# Copyright (c) 2015 Acme Inc.")
      expect(autocorrectSource(source())).to(eq("""        # encoding: utf-8
        # Copyright (c) 2015 Acme Inc.
        names = Array.new
        names << 'James'
""".stripIndent)))
  context("""when the copyright notice is missing and the source code file starts with shebang and an encoding comment""", proc (): void =
    let("source", proc (): void =
      """      #!/usr/bin/env ruby
      # encoding: utf-8
      names = Array.new
      names << 'James'
""".stripIndent)
    test "adds an offense":
      expectCopyrightOffense(cop(), source())
    test "correctly autocorrects the source code":
      copConfig().[]=("AutocorrectNotice", "# Copyright (c) 2015 Acme Inc.")
      expect(autocorrectSource(source())).to(eq("""        #!/usr/bin/env ruby
        # encoding: utf-8
        # Copyright (c) 2015 Acme Inc.
        names = Array.new
        names << 'James'
""".stripIndent))))
