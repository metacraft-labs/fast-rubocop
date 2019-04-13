
import
  empty_case_condition, test_tools

suite "EmptyCaseCondition":
  var cop = EmptyCaseCondition()
  let("message", proc (): void =
    "Do not use empty `case` condition, instead use an `if` expression.")
  sharedExamples("detect/correct empty case, accept non-empty case", proc (): void =
    test "registers an offense":
      inspectSource(source())
      expect(cop().messages).to(eq(@[message()]))
    test "correctly autocorrects":
      expect(autocorrectSource(source())).to(eq(correctedSource()))
    let("source_with_case", proc (): void =
      source().sub("case :a"))
    test "accepts the source with case":
      expectNoOffenses(sourceWithCase()))
  context("given a case statement with an empty case", proc (): void =
    context("with multiple when branches and an else", proc (): void =
      let("source", proc (): void =
        """          case
          when 1 == 2
            foo
          when 1 == 1
            bar
          else
            baz
          end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          if 1 == 2
            foo
          elsif 1 == 1
            bar
          else
            baz
          end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("with multiple when branches and an `else` with code comments", proc (): void =
      let("source", proc (): void =
        """          case
          # condition a
          # This is a multi-line comment
          when 1 == 2
            foo
          # condition b
          when 1 == 1
            bar
          # condition c
          else
            baz
          end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          # condition a
          # This is a multi-line comment
          if 1 == 2
            foo
          # condition b
          elsif 1 == 1
            bar
          # condition c
          else
            baz
          end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("with multiple when branches and no else", proc (): void =
      let("source", proc (): void =
        """          case
          when 1 == 2
            foo
          when 1 == 1
            bar
          end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          if 1 == 2
            foo
          elsif 1 == 1
            bar
          end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("with a single when branch and an else", proc (): void =
      let("source", proc (): void =
        """          case
          when 1 == 2
            foo
          else
            bar
          end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          if 1 == 2
            foo
          else
            bar
          end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("with a single when branch and no else", proc (): void =
      let("source", proc (): void =
        """          case
          when 1 == 2
            foo
          end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          if 1 == 2
            foo
          end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("with a when branch including comma-delimited alternatives", proc (): void =
      let("source", proc (): void =
        """          case
          when false
            foo
          when nil, false, 1
            bar
          when false, 1
            baz
          end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          if false
            foo
          elsif nil || false || 1
            bar
          elsif false || 1
            baz
          end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("with when branches using then", proc (): void =
      let("source", proc (): void =
        """          case
          when false then foo
          when nil, false, 1 then bar
          when false, 1 then baz
          end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          if false then foo
          elsif nil || false || 1 then bar
          elsif false || 1 then baz
          end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("with first when branch including comma-delimited alternatives", proc (): void =
      let("source", proc (): void =
        """          case
          when my.foo?, my.bar?
            something
          when my.baz?
            something_else
          end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          if my.foo? || my.bar?
            something
          elsif my.baz?
            something_else
          end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("when used as an argument of a method without comment", proc (): void =
      let("source", proc (): void =
        """          do_some_work case
                       when object.nil?
                         Object.new
                       else
                         object
                       end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          do_some_work if object.nil?
                         Object.new
                       else
                         object
                       end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("when used as an argument of a method with comment", proc (): void =
      let("source", proc (): void =
        """          # example.rb
          do_some_work case
                       when object.nil?
                         Object.new
                       else
                         object
                       end
""".stripIndent)
      let("corrected_source", proc (): void =
        """          # example.rb
          do_some_work if object.nil?
                         Object.new
                       else
                         object
                       end
""".stripIndent)
      itBehavesLike("detect/correct empty case, accept non-empty case"))
    context("""when using `return` in `when` clause and assigning the return value of `case`""", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          v = case
              when x.a
                1
              when x.b
                return 2
              end
""".stripIndent))
    context("""when using `return ... if` in `when` clause and assigning the return value of `case`""", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          v = case
              when x.a
                1
              when x.b
                return 2 if foo
              end
""".stripIndent))
    context("""when using `return` in `else` clause and assigning the return value of `case`""", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          v = case
              when x.a
                1
              else
                return 2
              end
""".stripIndent))
    context("""when using `return ... if` in `else` clause and assigning the return value of `case`""", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          v = case
              when x.a
                1
              else
                return 2 if foo
              end
""".stripIndent)))
