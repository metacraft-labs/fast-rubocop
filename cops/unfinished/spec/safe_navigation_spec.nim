
import
  safe_navigation, test_tools

RSpec.describe(SafeNavigation, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"ConvertCodeThatCanStartToReturnNil": false}.newTable())
  let("message", proc (): void =
    """Use safe navigation (`&.`) instead of checking if an object exists before calling the method.""")
  context("target_ruby_version >= 2.3", "ruby23", proc (): void =
    test "allows calls to methods not safeguarded by respond_to":
      expectNoOffenses("foo.bar")
    test "allows calls using safe navigation":
      expectNoOffenses("foo&.bar")
    test "allows calls on nil":
      expectNoOffenses("nil&.bar")
    test "allows an object check before hash access":
      expectNoOffenses("foo && foo[:bar]")
    test "allows an object check before a negated predicate":
      expectNoOffenses("foo && !foo.bar?")
    test "allows an object check before a nil check on a short chain":
      expectNoOffenses("user && user.thing.nil?")
    test "allows an object check before a method chain longer than 2 methods":
      expectNoOffenses("user && user.one.two.three")
    test "allows an object check before a long chain with a block":
      expectNoOffenses("user && user.thing.plus.another { |a| a}.other_thing")
    test "allows an object check before a nil check on a long chain":
      expectNoOffenses("user && user.thing.plus.some.other_thing.nil?")
    test "allows an object check before a blank check":
      expectNoOffenses("user && user.thing.blank?")
    test "allows an object check before a negated predicate method chain":
      expectNoOffenses("foo && !foo.bar.baz?")
    test """allows method call that is used in a comparison safe guarded by an object check""":
      expectNoOffenses("foo.bar > 2 if foo")
    test """allows method call that is used in a regex comparison safe guarded by an object check""":
      expectNoOffenses("foo.bar =~ /baz/ if foo")
    test """allows method call that is used in a negated regex comparison safe guarded by an object check""":
      expectNoOffenses("foo.bar !~ /baz/ if foo")
    test """allows method call that is used in a spaceship comparison safe guarded by an object check""":
      expectNoOffenses("foo.bar <=> baz if foo")
    test """allows an object check before a method call that is used in a comparison""":
      expectNoOffenses("foo && foo.bar > 2")
    test """allows an object check before a method call that is used in a regex comparison""":
      expectNoOffenses("foo && foo.bar =~ /baz/")
    test """allows an object check before a method call that is used in a negated regex comparison""":
      expectNoOffenses("foo && foo.bar !~ /baz/")
    test """allows an object check before a method call that is used in a spaceship comparison""":
      expectNoOffenses("foo && foo.bar <=> baz")
    test """allows an object check before a method chain that is used in a comparison""":
      expectNoOffenses("foo && foo.bar.baz > 2")
    test """allows a method chain that is used in a comparison safe guarded by an object check""":
      expectNoOffenses("foo.bar.baz > 2 if foo")
    test """allows a method call safeguarded with a negative check for the object when using `unless`""":
      expectNoOffenses("obj.do_something unless obj")
    test """allows a method call safeguarded with a negative check for the object when using `if`""":
      expectNoOffenses("obj.do_something if !obj")
    test """allows method calls that do not get called using . safe guarded by an object check""":
      expectNoOffenses("foo + bar if foo")
    test """allows chained method calls during arithmetic operations safe guarded by an object check""":
      expectNoOffenses("foo.baz + bar if foo")
    test """allows chained method calls during assignment safe guardedby an object check""":
      expectNoOffenses("foo.baz = bar if foo")
    test """allows object checks in the condition of an elsif statement and a method call on that object in the body""":
      expectNoOffenses("""        if foo
          something
        elsif bar
          bar.baz
        end
""".stripIndent)
    test """allows a method call as a parameter when the parameter is safe guarded with an object check""":
      expectNoOffenses("foo(bar.baz) if bar")
    sharedExamples("all variable types", proc (variable: string): void =
      context("modifier if", proc (): void =
        test """registers an offense for a method call that nil responds to safe guarded by an object check""":
          inspectSource("""(lvar :variable).to_i if (lvar :variable)""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call on an accessor safeguarded by a check for the accessed variable""":
          inspectSource("""(lvar :variable)[1].bar if (lvar :variable)[1]""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call safeguarded with a check for the object""":
          inspectSource("""(lvar :variable).bar if (lvar :variable)""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with params safeguarded with a check for the object""":
          inspectSource("""(lvar :variable).bar(baz) if (lvar :variable)""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with a block safeguarded with a check for the object""":
          inspectSource("""(lvar :variable).bar { |e| e.qux } if (lvar :variable)""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with params and a block safeguarded with a check for the object""":
          inspectSource("""(lvar :variable).bar(baz) { |e| e.qux } if (lvar :variable)""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call safeguarded with a negative check for the object""":
          inspectSource("""(lvar :variable).bar unless !(lvar :variable)""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with params safeguarded with a negative check for the object""":
          inspectSource("""(lvar :variable).bar(baz) unless !(lvar :variable)""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with a block safeguarded with a negative check for the object""":
          inspectSource("""(lvar :variable).bar { |e| e.qux } unless !(lvar :variable)""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with params and a block safeguarded with a negative check for the object""":
          inspectSource("""            (lvar :variable).bar(baz) { |e| e.qux } unless !(lvar :variable)
""".stripIndent)
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call safeguarded with a nil check for the object""":
          inspectSource("""(lvar :variable).bar unless (lvar :variable).nil?""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with params safeguarded with a nil check for the object""":
          inspectSource("""(lvar :variable).bar(baz) unless (lvar :variable).nil?""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with a block safeguarded with a nil check for the object""":
          inspectSource("""            (lvar :variable).bar { |e| e.qux } unless (lvar :variable).nil?
""".stripIndent)
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with params and a block safeguarded with a nil check for the object""":
          inspectSource("""            (lvar :variable).bar(baz) { |e| e.qux } unless (lvar :variable).nil?
""".stripIndent)
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call safeguarded with a negative nil check for the object""":
          inspectSource("""(lvar :variable).bar if !(lvar :variable).nil?""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with params safeguarded with a negative nil check for the object""":
          inspectSource("""(lvar :variable).bar(baz) if !(lvar :variable).nil?""")
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with a block safeguarded with a negative nil check for the object""":
          inspectSource("""            (lvar :variable).bar { |e| e.qux } if !(lvar :variable).nil?
""".stripIndent)
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a method call with params and a block safeguarded with a negative nil check for the object""":
          inspectSource("""            (lvar :variable).bar(baz) { |e| e.qux } if !(lvar :variable).nil?
""".stripIndent)
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a chained method call safeguarded with a negative nil check for the object""":
          inspectSource("""            (lvar :variable).one.two(baz) { |e| e.qux } if !(lvar :variable).nil?
""".stripIndent)
          expect(cop().messages).to(eq(@[message()])))
      context("if expression", proc (): void =
        test """registers an offense for a single method call inside of a check for the object""":
          inspectSource("""            if (lvar :variable)
              (lvar :variable).bar
            end
""".stripIndent)
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a single method call inside of a non-nil check for the object""":
          inspectSource("""            if !(lvar :variable).nil?
              (lvar :variable).bar
            end
""".stripIndent)
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a single method call inside of an unless nil check for the object""":
          inspectSource("""            unless (lvar :variable).nil?
              (lvar :variable).bar
            end
""".stripIndent)
          expect(cop().messages).to(eq(@[message()]))
        test """registers an offense for a single method call inside of an unless negative check for the object""":
          inspectSource("""            unless !(lvar :variable)
              (lvar :variable).bar
            end
""".stripIndent)
          expect(cop().messages).to(eq(@[message()]))
        test """allows a single method call inside of a check for the object with an else""":
          expectNoOffenses("""            if (lvar :variable)
              (lvar :variable).bar
            else
              something
            end
""".stripIndent)
        context("ternary expression", proc (): void =
          test "allows ternary expression":
            expectNoOffenses("""              !(lvar :variable).nil? ? (lvar :variable).bar : something
""".stripIndent)))
      context("object check before method call", proc (): void =
        context("ConvertCodeThatCanStartToReturnNil true", proc (): void =
          let("cop_config", proc (): void =
            {"ConvertCodeThatCanStartToReturnNil": true}.newTable())
          test """registers an offense for a non-nil object check followed by a method call""":
            inspectSource("""!(lvar :variable).nil? && (lvar :variable).bar""")
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for a non-nil object check followed by a method call with params""":
            inspectSource("""!(lvar :variable).nil? && (lvar :variable).bar(baz)""")
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for a non-nil object check followed by a method call with a block""":
            inspectSource("""              !(lvar :variable).nil? && (lvar :variable).bar { |e| e.qux }
""".stripIndent)
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for a non-nil object check followed by a method call with params and a block""":
            inspectSource("""              !(lvar :variable).nil? && (lvar :variable).bar(baz) { |e| e.qux }
""".stripIndent)
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for an object check followed by a method call""":
            inspectSource("""(lvar :variable) && (lvar :variable).bar""")
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for an object check followed by a method call with params""":
            inspectSource("""(lvar :variable) && (lvar :variable).bar(baz)""")
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for an object check followed by a method call with a block""":
            inspectSource("""(lvar :variable) && (lvar :variable).bar { |e| e.qux }""")
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for an object check followed by a method call with params and a block""":
            inspectSource("""              (lvar :variable) && (lvar :variable).bar(baz) { |e| e.qux }
""".stripIndent)
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for a check for the object followed by a method call in the condition for an if expression""":
            inspectSource("""              if (lvar :variable) && (lvar :variable).bar
                something
              end
""".stripIndent)
            expect(cop().messages).to(eq(@[message()]))
          context("method chaining", proc (): void =
            test """registers an offense for an object check followed by chained method calls with blocks""":
              inspectSource("""                (lvar :variable) && (lvar :variable).one { |a| b}.two(baz) { |e| e.qux }
""".stripIndent)
              expect(cop().messages).to(eq(@[message()]))
            context("with Lint/SafeNavigationChain disabled", proc (): void =
              let("config", proc (): void =
                Config.new())
              test "allows an object check followed by chained method calls":
                expectNoOffenses("""                  (lvar :variable) && (lvar :variable).one.two.three(baz) { |e| e.qux }
""".stripIndent)
              test """allows an object check followed by chained method calls with blocks""":
                expectNoOffenses("""                  (lvar :variable) && (lvar :variable).one { |a| b }.two(baz) { |e| e.qux }
""".stripIndent))))
        context("ConvertCodeThatCanStartToReturnNil false", proc (): void =
          let("cop_config", proc (): void =
            {"ConvertCodeThatCanStartToReturnNil": false}.newTable())
          test "allows a non-nil object check followed by a method call":
            expectNoOffenses("""!(lvar :variable).nil? && (lvar :variable).bar""")
          test """allows a non-nil object check followed by a method call with params""":
            expectNoOffenses("""!(lvar :variable).nil? && (lvar :variable).bar(baz)""")
          test """allows a non-nil object check followed by a method call with a block""":
            expectNoOffenses("""              !(lvar :variable).nil? && (lvar :variable).bar { |e| e.qux }
""".stripIndent)
          test """allows a non-nil object check followed by a method call with params and a block""":
            expectNoOffenses("""              !(lvar :variable).nil? && (lvar :variable).bar(baz) { |e| e.qux }
""".stripIndent)
          test """registers an offense for an object check followed by a method calls that nil responds to """:
            inspectSource("""(lvar :variable) && (lvar :variable).to_i""")
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for an object check followed by a method call""":
            inspectSource("""(lvar :variable) && (lvar :variable).bar""")
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for an object check followed by a method call with params""":
            inspectSource("""(lvar :variable) && (lvar :variable).bar(baz)""")
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for an object check followed by a method call with a block""":
            inspectSource("""(lvar :variable) && (lvar :variable).bar { |e| e.qux }""")
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for an object check followed by a method call with params and a block""":
            inspectSource("""              (lvar :variable) && (lvar :variable).bar(baz) { |e| e.qux }
""".stripIndent)
            expect(cop().messages).to(eq(@[message()]))
          test """registers an offense for a check for the object followed by a method call in the condition for an if expression""":
            inspectSource("""              if (lvar :variable) && (lvar :variable).bar
                something
              end
""".stripIndent)
            expect(cop().messages).to(eq(@[message()])))
        test "allows a nil object check followed by a method call":
          expectNoOffenses("""(lvar :variable).nil? || (lvar :variable).bar""")
        test "allows a nil object check followed by a method call with params":
          expectNoOffenses("""(lvar :variable).nil? || (lvar :variable).bar(baz)""")
        test "allows a nil object check followed by a method call with a block":
          expectNoOffenses("""            (lvar :variable).nil? || (lvar :variable).bar { |e| e.qux }
""".stripIndent)
        test """allows a nil object check followed by a method call with params and a block""":
          expectNoOffenses("""            (lvar :variable).nil? || (lvar :variable).bar(baz) { |e| e.qux }
""".stripIndent)
        test "allows a non object check followed by a method call":
          expectNoOffenses("""!(lvar :variable) || (lvar :variable).bar""")
        test "allows a non object check followed by a method call with params":
          expectNoOffenses("""!(lvar :variable) || (lvar :variable).bar(baz)""")
        test "allows a non object check followed by a method call with a block":
          expectNoOffenses("""!(lvar :variable) || (lvar :variable).bar { |e| e.qux }""")
        test """allows a non object check followed by a method call with params and a block""":
          expectNoOffenses("""            !(lvar :variable) || (lvar :variable).bar(baz) { |e| e.qux }
""".stripIndent)))
    itBehavesLike("all variable types", "foo")
    itBehavesLike("all variable types", "FOO")
    itBehavesLike("all variable types", "FOO::BAR")
    itBehavesLike("all variable types", "@foo")
    itBehavesLike("all variable types", "@@foo")
    itBehavesLike("all variable types", "$FOO")
    context("respond_to?", proc (): void =
      test "allows method calls safeguarded by a respond_to check":
        expectNoOffenses("foo.bar if foo.respond_to?(:bar)")
      test """allows method calls safeguarded by a respond_to check to a different method""":
        expectNoOffenses("foo.bar if foo.respond_to?(:foobar)")
      test """allows method calls safeguarded by a respond_to check on adifferent variable but the same method""":
        expectNoOffenses("foo.bar if baz.respond_to?(:bar)")
      test """allows method calls safeguarded by a respond_to check on adifferent variable and method""":
        expectNoOffenses("foo.bar if baz.respond_to?(:foo)")
      test """allows enumerable accessor method calls safeguarded by a respond_to check""":
        expectNoOffenses("foo[0] if foo.respond_to?(:[])"))
    context("auto-correct", proc (): void =
      sharedExamples("all variable types", proc (variable: string): void =
        context("modifier if", proc (): void =
          test "corrects a method call safeguarded with a check for the object":
            var newSource = autocorrectSource(
                """(lvar :variable).bar if (lvar :variable)""")
            expect(newSource).to(eq("""(lvar :variable)&.bar"""))
          test """corrects a method call with params safeguarded with a check for the object""":
            var
              source = """(lvar :variable).bar(baz) if (lvar :variable)"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz)"""))
          test """corrects a method call with a block safeguarded with a check for the object""":
            var
              source = """(lvar :variable).bar { |e| e.qux } if (lvar :variable)"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }"""))
          test """corrects a method call with params and a block safeguarded with a check for the object""":
            var
              source = """(lvar :variable).bar(baz) { |e| e.qux } if (lvar :variable)"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz) { |e| e.qux }"""))
          test """corrects a method call safeguarded with a negative check for the object""":
            var
              source = """(lvar :variable).bar unless !(lvar :variable)"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar"""))
          test """corrects a method call with params safeguarded with a negative check for the object""":
            var
              source = """(lvar :variable).bar(baz) unless !(lvar :variable)"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz)"""))
          test """corrects a method call with a block safeguarded with a negative check for the object""":
            var
              source = """(lvar :variable).bar { |e| e.qux } unless !(lvar :variable)"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }"""))
          test """corrects a method call with params and a block safeguarded with a negative check for the object""":
            var
              source = """(lvar :variable).bar(baz) { |e| e.qux } unless !(lvar :variable)"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz) { |e| e.qux }"""))
          test """corrects a method call safeguarded with a nil check for the object""":
            var
              source = """(lvar :variable).bar unless (lvar :variable).nil?"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar"""))
          test """corrects a method call with params safeguarded with a nil check for the object""":
            var
              source = """(lvar :variable).bar(baz) unless (lvar :variable).nil?"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz)"""))
          test """corrects a method call with a block safeguarded with a nil check for the object""":
            var
              source = """(lvar :variable).bar { |e| e.qux } unless (lvar :variable).nil?"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }"""))
          test """corrects a method call with params and a block safeguarded with a nil check for the object""":
            var newSource = autocorrectSource("""              (lvar :variable).bar(baz) { |e| e.qux } unless (lvar :variable).nil?
""".stripIndent)
            expect(newSource).to(eq("""              (lvar :variable)&.bar(baz) { |e| e.qux }
""".stripIndent))
          test """corrects a method call safeguarded with a negative nil check for the object""":
            var
              source = """(lvar :variable).bar if !(lvar :variable).nil?"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar"""))
          test """corrects a method call with params safeguarded with a negative nil check for the object""":
            var
              source = """(lvar :variable).bar(baz) if !(lvar :variable).nil?"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz)"""))
          test """corrects a method call with a block safeguarded with a negative nil check for the object""":
            var
              source = """(lvar :variable).bar { |e| e.qux } if !(lvar :variable).nil?"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }"""))
          test """corrects a method call with params and a block safeguarded with a negative nil check for the object""":
            var
              source = """(lvar :variable).bar(baz) { |e| e.qux } if !(lvar :variable).nil?"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz) { |e| e.qux }"""))
          test """corrects a method call on an accessor safeguarded by a check for the accessed variable""":
            var
              source = """(lvar :variable)[1].bar if (lvar :variable)[1]"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""(lvar :variable)[1]&.bar"""))
          test """corrects a chained method call safeguarded with a negative nil check for the object""":
            var newSource = autocorrectSource("""              (lvar :variable).one.two(baz) { |e| e.qux } if !(lvar :variable).nil?
""".stripIndent)
            expect(newSource).to(eq("""              (lvar :variable)&.one&.two(baz) { |e| e.qux }
""".stripIndent))
          test """corrects a chained method call safeguarded with a check for the object""":
            var newSource = autocorrectSource("""              (lvar :variable).one.two(baz) { |e| e.qux } if (lvar :variable)
""".stripIndent)
            expect(newSource).to(eq("""              (lvar :variable)&.one&.two(baz) { |e| e.qux }
""".stripIndent))
          test """corrects a chained method call safeguarded with an unless nil check for the object""":
            var newSource = autocorrectSource("""              (lvar :variable).one.two(baz) { |e| e.qux } unless (lvar :variable).nil?
""".stripIndent)
            expect(newSource).to(eq("""              (lvar :variable)&.one&.two(baz) { |e| e.qux }
""".stripIndent)))
        context("if expression", proc (): void =
          test "corrects a single method call inside of a check for the object":
            var newSource = autocorrectSource("""              if (lvar :variable)
                (lvar :variable).bar
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar
"""))
          test """corrects a single method call with params inside of a check for the object""":
            var newSource = autocorrectSource("""              if (lvar :variable)
                (lvar :variable).bar(baz)
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz)
"""))
          test """corrects a single method call with a block inside of a check for the object""":
            var newSource = autocorrectSource("""              if (lvar :variable)
                (lvar :variable).bar { |e| e.qux }
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }
"""))
          test """corrects a single method call with params and a block inside of a check for the object""":
            var newSource = autocorrectSource("""              if (lvar :variable)
                (lvar :variable).bar(baz) { |e| e.qux }
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz) { |e| e.qux }
"""))
          test """corrects a single method call inside of a non-nil check for the object""":
            var newSource = autocorrectSource("""              if !(lvar :variable).nil?
                (lvar :variable).bar
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar
"""))
          test """corrects a single method call with params inside of a non-nil check for the object""":
            var newSource = autocorrectSource("""              if !(lvar :variable).nil?
                (lvar :variable).bar(baz)
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz)
"""))
          test """corrects a single method call with a block inside of a non-nil check for the object""":
            var newSource = autocorrectSource("""              if !(lvar :variable).nil?
                (lvar :variable).bar { |e| e.qux }
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }
"""))
          test """corrects a single method call with params and a block inside of a non-nil check for the object""":
            var newSource = autocorrectSource("""              if !(lvar :variable).nil?
                (lvar :variable).bar(baz) { |e| e.qux }
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz) { |e| e.qux }
"""))
          test """corrects a single method call inside of an unless nil check for the object""":
            var newSource = autocorrectSource("""              unless (lvar :variable).nil?
                (lvar :variable).bar
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar
"""))
          test """corrects a single method call with params inside of an unless nil check for the object""":
            var newSource = autocorrectSource("""              unless (lvar :variable).nil?
                (lvar :variable).bar(baz)
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz)
"""))
          test """corrects a single method call with a block inside of an unless nil check for the object""":
            var newSource = autocorrectSource("""              unless (lvar :variable).nil?
                (lvar :variable).bar { |e| e.qux }
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }
"""))
          test """corrects a single method call with params and a block inside of an unless nil check for the object""":
            var newSource = autocorrectSource("""              unless (lvar :variable).nil?
                (lvar :variable).bar(baz) { |e| e.qux }
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz) { |e| e.qux }
"""))
          test """corrects a single method call inside of an unless negative check for the object""":
            var newSource = autocorrectSource("""              unless !(lvar :variable)
                (lvar :variable).bar
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar
"""))
          test """corrects a single method call with params inside of an unless negative check for the object""":
            var newSource = autocorrectSource("""              unless !(lvar :variable)
                (lvar :variable).bar(baz)
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz)
"""))
          test """corrects a single method call with a block inside of an unless negative check for the object""":
            var newSource = autocorrectSource("""              unless !(lvar :variable)
                (lvar :variable).bar { |e| e.qux }
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }
"""))
          test """corrects a single method call with params and a block inside of an unless negative check for the object""":
            var newSource = autocorrectSource("""              unless !(lvar :variable)
                (lvar :variable).bar(baz) { |e| e.qux }
              end
""".stripIndent)
            expect(newSource).to(eq("""(lvar :variable)&.bar(baz) { |e| e.qux }
""")))
        context("object check before method call", proc (): void =
          context("ConvertCodeThatCanStartToReturnNil true", proc (): void =
            let("cop_config", proc (): void =
              {"ConvertCodeThatCanStartToReturnNil": true}.newTable())
            test "corrects an object check followed by a method call":
              var
                source = """(lvar :variable) && (lvar :variable).bar"""
                newSource = autocorrectSource(source)
              expect(newSource).to(eq("""(lvar :variable)&.bar"""))
            test """corrects an object check followed by a method call with params""":
              var
                source = """(lvar :variable) && (lvar :variable).bar(baz)"""
                newSource = autocorrectSource(source)
              expect(newSource).to(eq("""(lvar :variable)&.bar(baz)"""))
            test """corrects an object check followed by a method call with a block""":
              var
                source = """(lvar :variable) && (lvar :variable).bar { |e| e.qux }"""
                newSource = autocorrectSource(source)
              expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }"""))
            test """corrects an object check followed by a method call with params and a block""":
              var
                source = """(lvar :variable) && (lvar :variable).bar(baz) { |e| e.qux }"""
                newSource = autocorrectSource(source)
              expect(newSource).to(eq("""(lvar :variable)&.bar(baz) { |e| e.qux }"""))
            test "corrects a non-nil object check followed by a method call":
              var
                source = """!(lvar :variable).nil? && (lvar :variable).bar"""
                newSource = autocorrectSource(source)
              expect(newSource).to(eq("""(lvar :variable)&.bar"""))
            test """corrects a non-nil object check followed by a method call with params""":
              var
                source = """!(lvar :variable).nil? && (lvar :variable).bar(baz)"""
                newSource = autocorrectSource(source)
              expect(newSource).to(eq("""(lvar :variable)&.bar(baz)"""))
            test """corrects a non-nil object check followed by a method call with a block""":
              var
                source = """!(lvar :variable).nil? && (lvar :variable).bar { |e| e.qux }"""
                newSource = autocorrectSource(source)
              expect(newSource).to(eq("""(lvar :variable)&.bar { |e| e.qux }"""))
            test """corrects a non-nil object check followed by a method call with params and a block""":
              var
                source = """!(lvar :variable).nil? && (lvar :variable).bar(baz) { |e| e.qux }"""
                newSource = autocorrectSource(source)
              expect(newSource).to(eq("""(lvar :variable)&.bar(baz) { |e| e.qux }"""))
            test """corrects an object check followed by a method call and another check""":
              var
                source = """(lvar :variable) && (lvar :variable).bar && something"""
                newSource = autocorrectSource(source)
              expect(newSource).to(eq("""(lvar :variable)&.bar && something""")))
          context("method chaining", proc (): void =
            test """corrects an object check followed by a chained method call""":
              var newSource = autocorrectSource("""                (lvar :variable) && (lvar :variable).one.two
""".stripIndent)
              expect(newSource).to(eq("""                (lvar :variable)&.one&.two
""".stripIndent))
            test """corrects an object check followed by a chained method call with params""":
              var newSource = autocorrectSource("""                (lvar :variable) && (lvar :variable).one.two(baz)
""".stripIndent)
              expect(newSource).to(eq("""                (lvar :variable)&.one&.two(baz)
""".stripIndent))
            test """corrects an object check followed by a chained method call with a symbol proc""":
              var newSource = autocorrectSource("""                (lvar :variable) && (lvar :variable).one.two(&:baz)
""".stripIndent)
              expect(newSource).to(eq("""                (lvar :variable)&.one&.two(&:baz)
""".stripIndent))
            test """corrects an object check followed by a chained method call with a block""":
              var newSource = autocorrectSource("""                (lvar :variable) && (lvar :variable).one.two(baz) { |e| e.qux }
""".stripIndent)
              expect(newSource).to(eq("""                (lvar :variable)&.one&.two(baz) { |e| e.qux }
""".stripIndent))
            test """corrects an object check followed by multiple chained method calls with blocks""":
              var newSource = autocorrectSource("""                (lvar :variable) && (lvar :variable).one { |a| b}.two(baz) { |e| e.qux }
""".stripIndent)
              expect(newSource).to(eq("""                (lvar :variable)&.one { |a| b}&.two(baz) { |e| e.qux }
""".stripIndent)))))
      itBehavesLike("all variable types", "foo")
      itBehavesLike("all variable types", "FOO")
      itBehavesLike("all variable types", "FOO::BAR")
      itBehavesLike("all variable types", "@foo")
      itBehavesLike("all variable types", "@@foo")
      itBehavesLike("all variable types", "$FOO")))
  context("target_ruby_version < 2.3", "ruby22", proc (): void =
    test "allows a method call safeguarded by a check for the variable":
      expectNoOffenses("foo.bar if foo")))
