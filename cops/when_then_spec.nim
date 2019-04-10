
import
  when_then, test_tools

suite "WhenThen":
  var cop = WhenThen()
  test "registers an offense for when x;":
    expectOffense("""      case a
      when b; c
            ^ Do not use `when x;`. Use `when x then` instead.
      end
""".stripIndent)
  test "accepts when x then":
    expectNoOffenses("""      case a
      when b then c
      end
""".stripIndent)
  test "accepts ; separating statements in the body of when":
    expectNoOffenses("""      case a
      when b then c; d
      end

      case e
      when f
        g; h
      end
""".stripIndent)
  test "auto-corrects \"when x;\" with \"when x then\"":
    var newSource = autocorrectSource("""      case a
      when b; c
      end
""".stripIndent)
    expect(newSource).to(eq("""      case a
      when b then c
      end
""".stripIndent))
  context("when inspecting a case statement with an empty branch", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        case value
        when cond1
        end
""".stripIndent))
