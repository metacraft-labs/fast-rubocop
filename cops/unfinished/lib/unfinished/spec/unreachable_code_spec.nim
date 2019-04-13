
import
  tables

import
  unreachable_code, test_tools

suite "UnreachableCode":
  var cop = UnreachableCode()
  for t in @["return", "next", "break", "retry", "redo", "throw", "raise", "fail", "exit",
          "exit!", "abort"]:
    test """registers an offense for `(lvar :t)` before other statements""":
      expectOffense(wrap("""        (lvar :t)
        bar
        ^^^ Unreachable code detected.
"""))
    test """registers an offense for `(lvar :t)` in `begin`""":
      expectOffense(wrap("""        begin
          (lvar :t)
          bar
          ^^^ Unreachable code detected.
        end
"""))
    test """registers an offense for `(lvar :t)` in all `if` branches""":
      expectOffense(wrap("""        if cond
          (lvar :t)
        else
          (lvar :t)
        end
        bar
        ^^^ Unreachable code detected.
"""))
    test """(str "registers an offense for `")with other expressions""":
      expectOffense(wrap("""        if cond
          something
          (lvar :t)
        else
          something2
          (lvar :t)
        end
        bar
        ^^^ Unreachable code detected.
"""))
    test """registers an offense for `(lvar :t)` in all `if` and `elsif` branches""":
      expectOffense(wrap("""        if cond
          something
          (lvar :t)
        elsif cond2
          something2
          (lvar :t)
        else
          something3
          (lvar :t)
        end
        bar
        ^^^ Unreachable code detected.
"""))
    test """registers an offense for `(lvar :t)` in all `case` branches""":
      expectOffense(wrap("""        case cond
        when 1
          something
          (lvar :t)
        when 2
          something2
          (lvar :t)
        else
          something3
          (lvar :t)
        end
        bar
        ^^^ Unreachable code detected.
"""))
    test """accepts code with conditional `(lvar :t)`""":
      expectNoOffenses(wrap("""        (lvar :t) if cond
        bar
"""))
    test """accepts `(lvar :t)` as the final expression""":
      expectNoOffenses(wrap("""        (lvar :t) if cond
"""))
    test """accepts `(lvar :t)` is in all `if` branchsi""":
      expectNoOffenses(wrap("""        if cond
          (lvar :t)
        else
          (lvar :t)
        end
"""))
    test """accepts `(lvar :t)` is in `if` branch only""":
      expectNoOffenses(wrap("""        if cond
          something
          (lvar :t)
        else
          something2
        end
        bar
"""))
    test """accepts `(lvar :t)` is in `if`, and without `else`""":
      expectNoOffenses(wrap("""        if cond
          something
          (lvar :t)
        end
        bar
"""))
    test """accepts `(lvar :t)` is in `else` branch only""":
      expectNoOffenses(wrap("""        if cond
          something
        else
          something2
          (lvar :t)
        end
        bar
"""))
    test """accepts `(lvar :t)` is not in `elsif` branch""":
      expectNoOffenses(wrap("""        if cond
          something
          (lvar :t)
        elsif cond2
          something2
        else
          something3
          (lvar :t)
        end
        bar
"""))
    test """accepts `(lvar :t)` is in `case` branch without else""":
      expectNoOffenses(wrap("""        case cond
        when 1
          something
          (lvar :t)
        when 2
          something2
          (lvar :t)
        end
        bar
"""))
