
import
  unneeded_cop_enable_directive, test_tools

suite "UnneededCopEnableDirective":
  var cop = UnneededCopEnableDirective()
  test "registers offense for unnecessary enable":
    expectOffense("""      foo
      # rubocop:enable Metrics/LineLength
                       ^^^^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/LineLength.
""".stripIndent)
  test "registers multiple offenses for same comment":
    expectOffense("""      foo
      # rubocop:enable Metrics/ModuleLength, Metrics/AbcSize
                                             ^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/AbcSize.
                       ^^^^^^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/ModuleLength.
      bar
""".stripIndent)
  test "registers correct offense when combined with necessary enable":
    expectOffense("""      # rubocop:disable Metrics/LineLength
      fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo = barrrrrrrrrrrrrrrrrrrrrrrrrr
      # rubocop:enable Metrics/AbcSize, Metrics/LineLength
                       ^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/AbcSize.
      bar
""".stripIndent)
  test "registers offense for redundant enabling of same cop":
    expectOffense("""      # rubocop:disable Metrics/LineLength
      fooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo = barrrrrrrrrrrrrrrrrrrrrrrrrr
      # rubocop:enable Metrics/LineLength

      bar

      # rubocop:enable Metrics/LineLength
                       ^^^^^^^^^^^^^^^^^^ Unnecessary enabling of Metrics/LineLength.
      bar
""".stripIndent)
  context("all switch", proc (): void =
    test "registers offense for unnecessary enable all":
      expectOffense("""      foo
      # rubocop:enable all
                       ^^^ Unnecessary enabling of all cops.
""".stripIndent)
    context("when at least one cop was disabled", proc (): void =
      test "does not register offense":
        expectNoOffenses("""        # rubocop:disable Metrics/LineLength
        foooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        # rubocop:enable all
""".stripIndent)))
  context("autocorrection", proc (): void =
    context("when entire comment unnecessarily enables", proc (): void =
      let("source", proc (): void =
        """          foo
          # rubocop:enable Metrics/LineLength
""".stripIndent)
      test "removes unnecessary enables":
        var corrected = autocorrectSource(source())
        expect(corrected).to(eq("""          foo

""".stripIndent)))
    context("when first cop unnecessarily enables", proc (): void =
      let("source", proc (): void =
        """          # rubocop:disable Metrics/LineLength
          foo
          # rubocop:enable Metrics/AbcSize, Metrics/LineLength
""".stripIndent)
      test "removes unnecessary enables":
        var corrected = autocorrectSource(source())
        expect(corrected).to(eq("""          # rubocop:disable Metrics/LineLength
          foo
          # rubocop:enable Metrics/LineLength
""".stripIndent)))
    context("when last cop unnecessarily enables", proc (): void =
      let("source", proc (): void =
        """          # rubocop:disable Metrics/LineLength
          foo
          # rubocop:enable Metrics/LineLength, Metrics/AbcSize
""".stripIndent)
      test "removes unnecessary enables":
        var corrected = autocorrectSource(source())
        expect(corrected).to(eq("""          # rubocop:disable Metrics/LineLength
          foo
          # rubocop:enable Metrics/LineLength
""".stripIndent))
      context("with no space between cops & comma", proc (): void =
        let("source", proc (): void =
          """            # rubocop:disable Metrics/LineLength
            foo
            # rubocop:enable Metrics/LineLength,Metrics/AbcSize
""".stripIndent)
        test "removes unnecessary enables":
          var corrected = autocorrectSource(source())
          expect(corrected).to(eq("""            # rubocop:disable Metrics/LineLength
            foo
            # rubocop:enable Metrics/LineLength
""".stripIndent))))
    context("when middle cop unnecessarily enables", proc (): void =
      let("source", proc (): void =
        """          # rubocop:disable Metrics/LineLength, Lint/Debugger
          foo
          # rubocop:enable Metrics/LineLength, Metrics/AbcSize, Lint/Debugger
""".stripIndent)
      test "removes unnecessary enables":
        var corrected = autocorrectSource(source())
        expect(corrected).to(eq("""          # rubocop:disable Metrics/LineLength, Lint/Debugger
          foo
          # rubocop:enable Metrics/LineLength, Lint/Debugger
""".stripIndent))
      context("with extra space after commas", proc (): void =
        let("source", proc (): void =
          """            # rubocop:disable Metrics/LineLength,  Lint/Debugger
            foo
            # rubocop:enable Metrics/LineLength,  Metrics/AbcSize,  Lint/Debugger
""".stripIndent)
        test "removes unnecessary enables":
          var corrected = autocorrectSource(source())
          expect(corrected).to(eq("""            # rubocop:disable Metrics/LineLength,  Lint/Debugger
            foo
            # rubocop:enable Metrics/LineLength,  Lint/Debugger
""".stripIndent)))))
