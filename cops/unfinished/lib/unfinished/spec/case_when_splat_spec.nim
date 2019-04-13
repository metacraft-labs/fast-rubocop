
import
  case_when_splat, test_tools

suite "CaseWhenSplat":
  var cop = CaseWhenSplat()
  test "allows case when without splat":
    expectNoOffenses("""      case foo
      when 1
        bar
      else
        baz
      end
""".stripIndent)
  test "allows splat on a variable in the last when condition":
    expectNoOffenses("""      case foo
      when 4
        foobar
      when *cond
        bar
      else
        baz
      end
""".stripIndent)
  test "allows multiple splat conditions on variables at the end":
    expectNoOffenses("""      case foo
      when 4
        foobar
      when *cond1
        bar
      when *cond2
        doo
      else
        baz
      end
""".stripIndent)
  test "registers an offense for case when with a splat in the first condition":
    expectOffense("""      case foo
      when *cond
      ^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        bar
      when 4
        foobar
      else
        baz
      end
""".stripIndent)
  test "registers an offense for case when with a splat without an else":
    expectOffense("""      case foo
      when *baz
      ^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        bar
      when 4
        foobar
      end
""".stripIndent)
  test "registers an offense for splat conditions in when then":
    expectOffense("""      case foo
      when *cond then bar
      ^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
      when 4 then baz
      end
""".stripIndent)
  test """registers an offense for a single when with splat expansion followed by another value""":
    expectOffense("""      case foo
      when *Foo, Bar
      ^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        nil
      end
""".stripIndent)
  test "registers an offense for multiple splat conditions at the beginning":
    expectOffense("""      case foo
      when *cond1
      ^^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        bar
      when *cond2
      ^^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        doo
      when 4
        foobar
      else
        baz
      end
""".stripIndent)
  test "registers an offense for multiple out of order splat conditions":
    expectOffense("""      case foo
      when *cond1
      ^^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        bar
      when 8
        barfoo
      when *SOME_CONSTANT
      ^^^^^^^^^^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        doo
      when 4
        foobar
      else
        baz
      end
""".stripIndent)
  test "registers an offense for splat condition that do not appear at the end":
    expectOffense("""      case foo
      when *cond1
      ^^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        bar
      when 8
        barfoo
      when *cond2
      ^^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        doo
      when 4
        foobar
      when *cond3
        doofoo
      else
        baz
      end
""".stripIndent)
  test "allows splat expansion on an array literal":
    expectNoOffenses("""      case foo
      when *[1, 2]
        bar
      when *[3, 4]
        bar
      when 5
        baz
      end
""".stripIndent)
  test "allows splat expansion on array literal as the last condition":
    expectNoOffenses("""      case foo
      when *[1, 2]
        bar
      end
""".stripIndent)
  test """registers an offense for a splat on a variable that proceeds a splat on an array literal as the last condition""":
    expectOffense("""      case foo
      when *cond
      ^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        bar
      when *[1, 2]
        baz
      end
""".stripIndent)
  test "registers an offense when splat is part of the condition":
    expectOffense("""      case foo
      when cond1, *cond2
      ^^^^^^^^^^^^^^^^^^ Reordering `when` conditions with a splat to the end of the `when` branches can improve performance.
        bar
      when cond3
        baz
      end
""".stripIndent)
  context("autocorrect", proc (): void =
    test """corrects a single when with splat expansion followed by another value""":
      var
        source = """        case foo
        when *Foo, Bar, Baz
          nil
        end
""".stripIndent
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("""        case foo
        when Bar, Baz, *Foo
          nil
        end
""".stripIndent))
    test """corrects a when with splat expansion followed by another value when there are multiple whens""":
      var
        source = """        case foo
        when *Foo, Bar
          nil
        when FooBar
          1
        end
""".stripIndent
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("""        case foo
        when FooBar
          1
        when Bar, *Foo
          nil
        end
""".stripIndent))
    test """corrects a when with multiple out of order splat expansions followed by other values when there are multiple whens""":
      var
        source = """        case foo
        when *Foo, Bar, *Baz, Qux
          nil
        when FooBar
          1
        end
""".stripIndent
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("""        case foo
        when FooBar
          1
        when Bar, Qux, *Foo, *Baz
          nil
        end
""".stripIndent))
    test "moves a single splat condition to the end of the when conditions":
      var newSource = autocorrectSource("""        case foo
        when *cond
          bar
        when 3
          baz
        end
""".stripIndent)
      expect(newSource).to(eq("""        case foo
        when 3
          baz
        when *cond
          bar
        end
""".stripIndent))
    test "moves multiple splat condition to the end of the when conditions":
      var newSource = autocorrectSourceWithLoop("""        case foo
        when *cond1
          bar
        when *cond2
          foobar
        when 5
          baz
        end
""".stripIndent)
      expect(newSource).to(eq("""        case foo
        when 5
          baz
        when *cond1
          bar
        when *cond2
          foobar
        end
""".stripIndent))
    test """moves multiple out of order splat condition to the end of the when conditions""":
      var newSource = autocorrectSourceWithLoop("""        case foo
        when *cond1
          bar
        when 3
          doo
        when *cond2
          foobar
        when 6
          baz
        end
""".stripIndent)
      expect(newSource).to(eq("""        case foo
        when 3
          doo
        when 6
          baz
        when *cond1
          bar
        when *cond2
          foobar
        end
""".stripIndent))
    test "corrects splat condition when using when then":
      var newSource = autocorrectSource("""        case foo
        when *cond then bar
        when 4 then baz
        end
""".stripIndent)
      expect(newSource).to(eq("""        case foo
        when 4 then baz
        when *cond then bar
        end
""".stripIndent))
    test "corrects nested case when statements":
      var newSource = autocorrectSource("""        def check
          case foo
          when *cond
            bar
          when 3
            baz
          end
        end
""".stripIndent)
      expect(newSource).to(eq("""        def check
          case foo
          when 3
            baz
          when *cond
            bar
          end
        end
""".stripIndent))
    test "corrects splat on a variable and leaves an array literal alone":
      var newSource = autocorrectSource("""        case foo
        when *cond
          bar
        when *[1, 2]
          baz
        end
""".stripIndent)
      expect(newSource).to(eq("""        case foo
        when *[1, 2]
          baz
        when *cond
          bar
        end
""".stripIndent))
    test "corrects a splat as part of the condition":
      var newSource = autocorrectSource("""        case foo
        when cond1, *cond2
          bar
        when cond3
          baz
        end
""".stripIndent)
      expect(newSource).to(eq("""        case foo
        when cond3
          baz
        when cond1, *cond2
          bar
        end
""".stripIndent))
    test "corrects an array followed by splat in the same condition":
      var newSource = autocorrectSource("""        case foo
        when *[cond1, cond2], *cond3
          bar
        when cond4
          baz
        end
""".stripIndent)
      expect(newSource).to(eq("""        case foo
        when cond4
          baz
        when *[cond1, cond2], *cond3
          bar
        end
""".stripIndent))
    test "corrects a splat followed by array in the same condition":
      var newSource = autocorrectSource("""        case foo
        when *cond1, *[cond2, cond3]
          bar
        when cond4
          baz
        end
""".stripIndent)
      expect(newSource).to(eq("""        case foo
        when cond4
          baz
        when *cond1, *[cond2, cond3]
          bar
        end
""".stripIndent)))
