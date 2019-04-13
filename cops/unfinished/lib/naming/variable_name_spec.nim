
import
  types

import
  variable_name, test_tools

RSpec.describe(VariableName, "config", proc () =
  var cop = ()
  sharedExamples("always accepted", proc () =
    test "accepts screaming snake case globals":
      expectNoOffenses("$MY_GLOBAL = 0")
    test "accepts screaming snake case constants":
      expectNoOffenses("MY_CONSTANT = 0")
    test "accepts assigning to camel case constant":
      expectNoOffenses("Paren = Struct.new :left, :right, :kind")
    test "accepts assignment with indexing of self":
      expectNoOffenses("self[:a] = b"))
  context("when configured for snake_case", proc () =
    let("cop_config", proc (): Table[string, string] =
      {"EnforcedStyle": "snake_case"}.newTable())
    test "registers an offense for camel case in local variable name":
      expectOffense("""        myLocal = 1
        ^^^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for correct + opposite":
      expectOffense("""        my_local = 1
        myLocal = 1
        ^^^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for camel case in instance variable name":
      expectOffense("""        @myAttribute = 3
        ^^^^^^^^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for camel case in class variable name":
      expectOffense("""        @@myAttr = 2
        ^^^^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for camel case local variables marked as unused":
      expectOffense("""        _myLocal = 1
        ^^^^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for method arguments":
      expectOffense("""        def method(funnyArg); end
                   ^^^^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for default method arguments":
      expectOffense("""        def foo(optArg = 1); end
                ^^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for rest arguments":
      expectOffense("""        def foo(*restArg); end
                 ^^^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for keyword arguments":
      expectOffense("""        def foo(kwArg: 1); end
                ^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for keyword rest arguments":
      expectOffense("""        def foo(**kwRest); end
                  ^^^^^^ Use snake_case for variable names.
""".stripIndent)
    test "registers an offense for block arguments":
      expectOffense("""        def foo(&blockArg); end
                 ^^^^^^^^ Use snake_case for variable names.
""".stripIndent)
    includeExamples("always accepted"))
  context("when configured for camelCase", proc () =
    let("cop_config", proc (): Table[string, string] =
      {"EnforcedStyle": "camelCase"}.newTable())
    test "registers an offense for snake case in local variable name":
      expectOffense("""        my_local = 1
        ^^^^^^^^ Use camelCase for variable names.
""".stripIndent)
    test "registers an offense for opposite + correct":
      expectOffense("""        my_local = 1
        ^^^^^^^^ Use camelCase for variable names.
        myLocal = 1
""".stripIndent)
    test "accepts camel case in local variable name":
      expectNoOffenses("myLocal = 1")
    test "accepts camel case in instance variable name":
      expectNoOffenses("@myAttribute = 3")
    test "accepts camel case in class variable name":
      expectNoOffenses("@@myAttr = 2")
    test "registers an offense for snake case in method parameter":
      expectOffense("""        def method(funny_arg); end
                   ^^^^^^^^^ Use camelCase for variable names.
""".stripIndent)
    test "accepts camel case local variables marked as unused":
      expectNoOffenses("_myLocal = 1")
    test "registers an offense for default method arguments":
      expectOffense("""        def foo(opt_arg = 1); end
                ^^^^^^^ Use camelCase for variable names.
""".stripIndent)
    test "registers an offense for rest arguments":
      expectOffense("""        def foo(*rest_arg); end
                 ^^^^^^^^ Use camelCase for variable names.
""".stripIndent)
    test "registers an offense for keyword arguments":
      expectOffense("""        def foo(kw_arg: 1); end
                ^^^^^^ Use camelCase for variable names.
""".stripIndent)
    test "registers an offense for keyword rest arguments":
      expectOffense("""        def foo(**kw_rest); end
                  ^^^^^^^ Use camelCase for variable names.
""".stripIndent)
    test "registers an offense for block arguments":
      expectOffense("""        def foo(&block_arg); end
                 ^^^^^^^^^ Use camelCase for variable names.
""".stripIndent)
    includeExamples("always accepted")))
