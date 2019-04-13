
import
  missing_else, test_tools

suite "MissingElse":
  var cop = MissingElse()
  context("UnlessElse enabled", proc (): void =
    let("config", proc (): void =
      Config.new())
    context("given an if-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo elsif b; bar else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            if cond; foo end
            ^^^^^^^^^^^^^^^^ `if` condition requires an `else`-clause.
""".stripIndent)))
    context("given an unless-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else end"))
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
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; else b; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            case v; when a; foo; when b; bar; end
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `case` condition requires an `else`-clause.
""".stripIndent))))
  context("UnlessElse disabled", proc (): void =
    let("config", proc (): void =
      Config.new())
    context("given an if-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo elsif b; bar else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            if cond; foo end
            ^^^^^^^^^^^^^^^^ `if` condition requires an `else`-clause.
""".stripIndent)))
    context("given an unless-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            unless cond; foo end
            ^^^^^^^^^^^^^^^^^^^^ `if` condition requires an `else`-clause.
""".stripIndent)))
    context("given a case statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; else b; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            case v; when a; foo; when b; bar; end
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `case` condition requires an `else`-clause.
""".stripIndent))))
  context("EmptyElse enabled and set to warn on empty", proc (): void =
    let("config", proc (): void =
      var styles = @["if", "case", "both"]
      Config.new())
    context("given an if-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo elsif b; bar else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            if cond; foo end
            ^^^^^^^^^^^^^^^^ `if` condition requires an `else`-clause with `nil` in it.
""".stripIndent)))
    context("given an unless-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            unless cond; foo end
            ^^^^^^^^^^^^^^^^^^^^ `if` condition requires an `else`-clause with `nil` in it.
""".stripIndent)))
    context("given a case statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; else b; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            case v; when a; foo; when b; bar; end
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `case` condition requires an `else`-clause with `nil` in it.
""".stripIndent))))
  context("EmptyElse enabled and set to warn on nil", proc (): void =
    let("config", proc (): void =
      var styles = @["if", "case", "both"]
      Config.new())
    context("given an if-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo elsif b; bar else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            if cond; foo end
            ^^^^^^^^^^^^^^^^ `if` condition requires an empty `else`-clause.
""".stripIndent)))
    context("given an unless-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            unless cond; foo end
            ^^^^^^^^^^^^^^^^^^^^ `if` condition requires an empty `else`-clause.
""".stripIndent)))
    context("given a case statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; else b; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            case v; when a; foo; when b; bar; end
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `case` condition requires an empty `else`-clause.
""".stripIndent))))
  context("configured to warn only on empty if", proc (): void =
    let("config", proc (): void =
      var styles = @["if", "case", "both"]
      Config.new())
    context("given an if-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo elsif b; bar else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            if cond; foo end
            ^^^^^^^^^^^^^^^^ `if` condition requires an empty `else`-clause.
""".stripIndent)))
    context("given an unless-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("unless cond; foo else bar; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            unless cond; foo end
            ^^^^^^^^^^^^^^^^^^^^ `if` condition requires an empty `else`-clause.
""".stripIndent)))
    context("given a case statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; else b; nil end"))
      context("with no else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; end"))))
  context("configured to warn only on empty case", proc (): void =
    let("config", proc (): void =
      var styles = @["if", "case", "both"]
      Config.new())
    context("given an if-statement", proc (): void =
      context("with a completely empty else-clause", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("if a; foo elsif b; bar else nil end"))
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
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo else end"))
      context("with an else-clause containing only the literal nil", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; when b; bar; else nil end"))
      context("with an else-clause with side-effects", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("case v; when a; foo; else b; nil end"))
      context("with no else-clause", proc (): void =
        test "registers an offense":
          expectOffense("""            case v; when a; foo; when b; bar; end
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `case` condition requires an empty `else`-clause.
""".stripIndent))))
