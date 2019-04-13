
import
  empty_lines_around_module_body, test_tools

RSpec.describe(EmptyLinesAroundModuleBody, "config", proc (): void =
  var cop = ()
  let("extra_begin", proc (): void =
    "Extra empty line detected at module body beginning.")
  let("extra_end", proc (): void =
    "Extra empty line detected at module body end.")
  let("missing_begin", proc (): void =
    "Empty line missing at module body beginning.")
  let("missing_end", proc (): void =
    "Empty line missing at module body end.")
  let("missing_def", proc (): void =
    "Empty line missing before first def definition")
  let("missing_type", proc (): void =
    "Empty line missing before first module definition")
  context("when EnforcedStyle is no_empty_lines", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "no_empty_lines"}.newTable())
    test "registers an offense for module body starting with a blank":
      inspectSource("""        module SomeModule

          do_something
        end
""".stripIndent)
      expect(cop().messages).to(eq(@["Extra empty line detected at module body beginning."]))
    test "registers an offense for module body ending with a blank":
      inspectSource("""        module SomeModule
          do_something

        end
""".stripIndent)
      expect(cop().messages).to(eq(@["Extra empty line detected at module body end."]))
    test "autocorrects beginning and end":
      var newSource = autocorrectSource("""        module SomeModule

          do_something

        end
""".stripIndent)
      expect(newSource).to(eq("""        module SomeModule
          do_something
        end
""".stripIndent)))
  context("when EnforcedStyle is empty_lines", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "empty_lines"}.newTable())
    test """registers an offense for module body not starting or ending with a blank""":
      inspectSource("""        module SomeModule
          do_something
        end
""".stripIndent)
      expect(cop().messages).to(eq(@["Empty line missing at module body beginning.",
                                     "Empty line missing at module body end."]))
    test "registers an offense for module body not ending with a blank":
      expectOffense("""        module SomeModule

          do_something
        end
        ^ Empty line missing at module body end.
""".stripIndent)
    test "autocorrects beginning and end":
      var newSource = autocorrectSource("""        module SomeModule
          do_something
        end
""".stripIndent)
      expect(newSource).to(eq("""        module SomeModule

          do_something

        end
""".stripIndent))
    test "ignores modules with an empty body":
      var
        source = "module A\nend"
        corrected = autocorrectSource(source)
      expect(corrected).to(eq(source)))
  context("when EnforcedStyle is empty_lines_except_namespace", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "empty_lines_except_namespace"}.newTable())
    context("when only child is class", proc (): void =
      test "requires no empty lines for namespace":
        expectNoOffenses("""          module Parent
            module Child

              do_something

            end
          end
""".stripIndent)
      test "registers offense for namespace body starting with a blank":
        inspectSource("""          module Parent

            module Child

              do_something

            end
          end
""".stripIndent)
        expect(cop().messages).to(eq(@[extraBegin()]))
      test "registers offense for namespace body ending with a blank":
        inspectSource("""          module Parent
            module Child

              do_something

            end

          end
""".stripIndent)
        expect(cop().messages).to(eq(@[extraEnd()]))
      test """registers offenses for namespaced module body not starting with a blank""":
        inspectSource("""          module Parent
            module Child
              do_something

            end
          end
""".stripIndent)
        expect(cop().messages).to(eq(@[missingBegin()]))
      test """registers offenses for namespaced module body not ending with a blank""":
        inspectSource("""          module Parent
            module Child

              do_something
            end
          end
""".stripIndent)
        expect(cop().messages).to(eq(@[missingEnd()]))
      test "autocorrects beginning and end":
        var newSource = autocorrectSource("""          module Parent

            module Child
              do_something
            end

          end
""".stripIndent)
        expect(newSource).to(eq("""          module Parent
            module Child

              do_something

            end
          end
""".stripIndent)))
    context("when only child is class", proc (): void =
      test "requires no empty lines for namespace":
        expectNoOffenses("""          module Parent
            class SomeClass
              do_something
            end
          end
""".stripIndent)
      test "registers offense for namespace body starting with a blank":
        inspectSource("""          module Parent

            class SomeClass
              do_something
            end
          end
""".stripIndent)
        expect(cop().messages).to(eq(@[extraBegin()]))
      test "registers offense for namespace body ending with a blank":
        inspectSource("""          module Parent
            class SomeClass
              do_something
            end

          end
""".stripIndent)
        expect(cop().messages).to(eq(@[extraEnd()])))
    context("when has multiple child modules", proc (): void =
      test "requires empty lines for namespace":
        expectNoOffenses("""          module Parent

            module Mom

              do_something

            end
            module Dad

            end

          end
""".stripIndent)
      test """registers offenses for namespace body starting and ending without a blank""":
        inspectSource("""          module Parent
            module Mom

              do_something

            end
            module Dad

            end
          end
""".stripIndent)
        expect(cop().messages).to(eq(@[missingBegin(), missingEnd()]))))
  includeExamples("empty_lines_around_class_or_module_body", "module"))
