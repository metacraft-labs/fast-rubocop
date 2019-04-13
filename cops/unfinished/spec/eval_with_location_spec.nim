
import
  eval_with_location, test_tools

suite "EvalWithLocation":
  var cop = EvalWithLocation()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when using `#eval` without any arguments":
    expectOffense("""      eval <<-CODE
      ^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
""".stripIndent)
  test "registers an offense when using `#eval` with `binding` only":
    expectOffense("""      eval <<-CODE, binding
      ^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
""".stripIndent)
  test "registers an offense when using `#eval` without lineno":
    expectOffense("""      eval <<-CODE, binding, __FILE__
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
""".stripIndent)
  test "registers an offense when using `#eval` with an incorrect line number":
    expectOffense("""      eval 'do_something', binding, __FILE__, __LINE__ + 1
                                              ^^^^^^^^^^^^ Use `__LINE__` instead of `__LINE__ + 1`, as they are used by backtraces.
""".stripIndent)
  test """registers an offense when using `#eval` with a heredoc and an incorrect line number""":
    expectOffense("""      eval <<-CODE, binding, __FILE__, __LINE__ + 2
                                       ^^^^^^^^^^^^ Use `__LINE__ + 1` instead of `__LINE__ + 2`, as they are used by backtraces.
        do_something
      CODE
""".stripIndent)
  test "registers an offense when using `#eval` with a string on a new line ":
    expectOffense("""      eval('puts 42',
           binding,
           __FILE__,
           __LINE__)
           ^^^^^^^^ Use `__LINE__ - 3` instead of `__LINE__`, as they are used by backtraces.
""".stripIndent)
  test "registers an offense when using `#class_eval` without any arguments":
    expectOffense("""      C.class_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
""".stripIndent)
  test "registers an offense when using `#module_eval` without any arguments":
    expectOffense("""      M.module_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
""".stripIndent)
  test "registers an offense when using `#instance_eval` without any arguments":
    expectOffense("""      foo.instance_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
""".stripIndent)
  test "registers an offense when using `#class_eval` with an incorrect lineno":
    expectOffense("""      C.class_eval <<-CODE, __FILE__, __LINE__
                                      ^^^^^^^^ Use `__LINE__ + 1` instead of `__LINE__`, as they are used by backtraces.
        do_something
      CODE
""".stripIndent)
  test "accepts `eval` with a heredoc, a filename and `__LINE__ + 1`":
    expectNoOffenses("""      eval <<-CODE, binding, __FILE__, __LINE__ + 1
        do_something
      CODE
""".stripIndent)
  test "accepts `eval` with a code that is a variable":
    expectNoOffenses("""      code = something
      eval code
""".stripIndent)
  test "accepts `eval` with a string, a filename and `__LINE__`":
    expectNoOffenses("      eval \'do_something\', binding, __FILE__, __LINE__\n".stripIndent)
  test "accepts `eval` with a string, a filename and `__LINE__` on a new line":
    expectNoOffenses("""      eval 'do_something', binding, __FILE__,
           __LINE__ - 1
""".stripIndent)
