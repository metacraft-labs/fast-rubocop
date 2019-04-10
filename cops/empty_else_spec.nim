
import
  tables, sequtils

import
  empty_else, test_tools

suite "EmptyElse":
  var cop = EmptyElse()
  let("missing_else_config", proc (): void =
    {:}.newTable())
  sharedExamples("auto-correct", proc (keyword: string): void =
    context("MissingElse is disabled", proc (): void =
      test "does auto-correction":
        expect(autocorrectSource(source())).to(eq(correctedSource())))
    for missingElseStyle in @["both", "if", "case"]:
      context("""MissingElse is (lvar :missing_else_style)""", proc (): void =
        let("missing_else_config", proc (): void =
          {"Enabled": true, "EnforcedStyle": missingElseStyle}.newTable())
        if ("both", keyword).isInclude(missingElseStyle):
          test "does not auto-correct":
            expect(autocorrectSource(source())).to(eq(source()))
            expect(cop().offenses.mapIt:
              it.isOrrected).to(eq(@[false]))
        else:
          test "does auto-correction":
            expect(autocorrectSource(source())).to(eq(correctedSource()))
      ))
  sharedExamplesFor("offense registration", proc (): void =
    test "registers an offense with correct message":
      inspectSource(source())
      expect(cop().messages).to(eq(@["Redundant `else`-clause."]))
    test "registers an offense with correct location":
      inspectSource(source())
      expect(cop().highlights).to(eq(@["else"])))
  context("configured to warn on empty else", proc (): void =
    let("config", proc (): void =
      Config.new())
    context("given an if-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        context("using semicolons", proc (): void =
          let("source", proc (): void =
            "if a; foo else end")
          let("corrected_source", proc (): void =
            "if a; foo end")
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "if"))
        context("not using semicolons", proc (): void =
          let("source", proc (): void =
            """              if a
                foo
              else
              end
""".stripIndent)
          let("corrected_source", proc (): void =
            """              if a
                foo
              end
""".stripIndent)
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "if")))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo elsif b; bar else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo end"))
      context("in an if-statement", proc (): void =
        let("source", proc (): void =
          """          if cond
            if cond2
              something
            else
            end
          end
""".stripIndent)
        let("corrected_source", proc (): void =
          """          if cond
            if cond2
              something
            end
          end
""".stripIndent)
        itBehavesLike("auto-correct", "if")
        itBehavesLike("offense registration"))
      context("with an empty comment", proc (): void =
        let("source", proc (): void =
          """          if cond
            something
          else
            # TODO
          end
""".stripIndent)
        let("corrected_source", proc (): void =
          """          if cond
            something
          else
            # TODO
          end
""".stripIndent)
        itBehavesLike("auto-correct", "if")
        itBehavesLike("offense registration")))
    context("given an unless-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        let("source", proc (): void =
          "unless cond; foo else end")
        let("corrected_source", proc (): void =
          "unless cond; foo end")
        itBehavesLike("offense registration")
        itBehavesLike("auto-correct", "if"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo end")))
    context("given a case statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        let("source", proc (): void =
          "case v; when a; foo else end")
        let("corrected_source", proc (): void =
          "case v; when a; foo end")
        itBehavesLike("offense registration")
        itBehavesLike("auto-correct", "case"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; else b; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; end"))))
  context("configured to warn on nil in else", proc (): void =
    let("config", proc (): void =
      Config.new())
    context("given an if-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        context("when standalone", proc (): void =
          let("source", proc (): void =
            """              if a
                foo
              elsif b
                bar
              else
                nil
              end
""".stripIndent)
          let("corrected_source", proc (): void =
            """              if a
                foo
              elsif b
                bar
              end
""".stripIndent)
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "if"))
        context("when the result is assigned to a variable", proc (): void =
          let("source", proc (): void =
            @["foobar = if a", "           foo", "         elsif b",
              "           bar", "         else", "           nil", "         end"].join(
                "\n"))
          let("corrected_source", proc (): void =
            @["foobar = if a", "           foo", "         elsif b",
              "           bar", "         end"].join("\n"))
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "if")))
      context("""with an else-clause containing only the literal nil using semicolons""", proc (): void =
        context("with one elsif", proc (): void =
          let("source", proc (): void =
            "if a; foo elsif b; bar else nil end")
          let("corrected_source", proc (): void =
            "if a; foo elsif b; bar end")
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "if"))
        context("with multiple elsifs", proc (): void =
          let("source", proc (): void =
            "if a; foo elsif b; bar; elsif c; bar else nil end")
          let("corrected_source", proc (): void =
            "if a; foo elsif b; bar; elsif c; bar end")
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "if")))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo end")))
    context("given an unless-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        let("source", proc (): void =
          "unless cond; foo else nil end")
        let("corrected_source", proc (): void =
          "unless cond; foo end")
        itBehavesLike("offense registration")
        itBehavesLike("auto-correct", "if"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo end")))
    context("given a case statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        context("using semicolons", proc (): void =
          let("source", proc (): void =
            "case v; when a; foo; when b; bar; else nil end")
          let("corrected_source", proc (): void =
            "case v; when a; foo; when b; bar; end")
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "case"))
        context("when the result is assigned to a variable", proc (): void =
          let("source", proc (): void =
            @["foobar = case v", "         when a", "           foo",
              "         when b", "           bar", "         else",
              "           nil", "         end"].join("\n"))
          let("corrected_source", proc (): void =
            @["foobar = case v", "         when a", "           foo",
              "         when b", "           bar", "         end"].join("\n"))
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "case")))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; else b; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; end"))))
  context("configured to warn on empty else and nil in else", proc (): void =
    let("config", proc (): void =
      Config.new())
    context("given an if-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        let("source", proc (): void =
          "if a; foo else end")
        let("corrected_source", proc (): void =
          "if a; foo end")
        itBehavesLike("offense registration")
        itBehavesLike("auto-correct", "if"))
      context("with an else-clause containing only the literal nil", proc (): void =
        context("with one elsif", proc (): void =
          let("source", proc (): void =
            "if a; foo elsif b; bar else nil end")
          let("corrected_source", proc (): void =
            "if a; foo elsif b; bar end")
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "if"))
        context("with multiple elsifs", proc (): void =
          let("source", proc (): void =
            "if a; foo elsif b; bar; elsif c; bar else nil end")
          let("corrected_source", proc (): void =
            "if a; foo elsif b; bar; elsif c; bar end")
          itBehavesLike("offense registration")
          itBehavesLike("auto-correct", "if")))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo end")))
    context("given an unless-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        let("source", proc (): void =
          "unless cond; foo else end")
        let("corrected_source", proc (): void =
          "unless cond; foo end")
        itBehavesLike("offense registration")
        itBehavesLike("auto-correct", "if"))
      context("with an else-clause containing only the literal nil", proc (): void =
        let("source", proc (): void =
          "unless cond; foo else nil end")
        let("corrected_source", proc (): void =
          "unless cond; foo end")
        itBehavesLike("offense registration")
        itBehavesLike("auto-correct", "if"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo end")))
    context("given a case statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        let("source", proc (): void =
          "case v; when a; foo else end")
        let("corrected_source", proc (): void =
          "case v; when a; foo end")
        itBehavesLike("offense registration")
        itBehavesLike("auto-correct", "case"))
      context("with an else-clause containing only the literal nil", proc (): void =
        let("source", proc (): void =
          "case v; when a; foo; when b; bar; else nil end")
        let("corrected_source", proc (): void =
          "case v; when a; foo; when b; bar; end")
        itBehavesLike("offense registration")
        itBehavesLike("auto-correct", "case"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; else b; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; end"))))
  context("with nested if and case statement", proc (): void =
    let("config", proc (): void =
      Config.new())
    let("source", proc (): void =
      """        def foo
          if @params
            case @params[:x]
            when :a
              :b
            else
              nil
            end
          else
            :c
          end
        end
""".stripIndent)
    let("corrected_source", proc (): void =
      """        def foo
          if @params
            case @params[:x]
            when :a
              :b
            end
          else
            :c
          end
        end
""".stripIndent)
    itBehavesLike("offense registration")
    itBehavesLike("auto-correct", "case"))
