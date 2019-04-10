
import
  multiline_if_then, test_tools

suite "MultilineIfThen":
  var cop = MultilineIfThen()
  test "does not get confused by empty elsif branch":
    expectNoOffenses("""      if cond
      elsif cond
      end
""".stripIndent)
  test "registers an offense for then in multiline if":
    expectOffense("""      if cond then
              ^^^^ Do not use `then` for multi-line `if`.
      end
      if cond then	
              ^^^^ Do not use `then` for multi-line `if`.
      end
      if cond then
              ^^^^ Do not use `then` for multi-line `if`.
      end
      if cond
      then
      ^^^^ Do not use `then` for multi-line `if`.
      end
      if cond then # bad
              ^^^^ Do not use `then` for multi-line `if`.
      end
""".stripIndent)
  test "registers an offense for then in multiline elsif":
    expectOffense("""      if cond1
        a
      elsif cond2 then
                  ^^^^ Do not use `then` for multi-line `elsif`.
        b
      end
""".stripIndent)
  test "accepts multiline if without then":
    expectNoOffenses("""      if cond
      end
""".stripIndent)
  test "accepts table style if/then/elsif/ends":
    expectNoOffenses("""      if    @io == $stdout then str << "$stdout"
      elsif @io == $stdin  then str << "$stdin"
      elsif @io == $stderr then str << "$stderr"
      else                      str << @io.class.to_s
      end
""".stripIndent)
  test "does not get confused by a then in a when":
    expectNoOffenses("""      if a
        case b
        when c then
        end
      end
""".stripIndent)
  test "does not get confused by a commented-out then":
    expectNoOffenses("""      if a # then
        b
      end
      if c # then
      end
""".stripIndent)
  test "does not raise an error for an implicit match if":
    expect(proc (): void =
      inspectSource("""        if //
        end
""".stripIndent)).notTo(
        raiseError)
  test "registers an offense for then in multiline unless":
    expectOffense("""      unless cond then
                  ^^^^ Do not use `then` for multi-line `unless`.
      end
""".stripIndent)
  test "accepts multiline unless without then":
    expectNoOffenses("""      unless cond
      end
""".stripIndent)
  test "does not get confused by a postfix unless":
    expectNoOffenses("two unless one")
  test "does not get confused by a nested postfix unless":
    expectNoOffenses("""      if two
        puts 1
      end unless two
""".stripIndent)
  test "does not raise an error for an implicit match unless":
    expect(proc (): void =
      inspectSource("""        unless //
        end
""".stripIndent)).notTo(
        raiseError)
  test "auto-corrects the usage of \"then\" in multiline if":
    var newSource = autocorrectSource("""      if cond then
        something
      end
""".stripIndent)
    expect(newSource).to(eq("""      if cond
        something
      end
""".stripIndent))
