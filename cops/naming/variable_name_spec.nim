
import
  types

import
  variable_name, test_tools

RSpec.describe(VariableName, "config", proc () =
  subject("cop", proc () =
    describedClass.new(config()))
  sharedExamples("always accepted", proc () =
    it("accepts screaming snake case globals", proc () =
      expectNoOffenses("$MY_GLOBAL = 0"))
    it("accepts screaming snake case constants", proc () =
      expectNoOffenses("MY_CONSTANT = 0"))
    it("accepts assigning to camel case constant", proc () =
      expectNoOffenses("Paren = Struct.new :left, :right, :kind"))
    it("accepts assignment with indexing of self", proc () =
      expectNoOffenses("self[:a] = b")))
  context("when configured for snake_case", proc () =
    let("cop_config", proc (): Table[string, string] =
      {"EnforcedStyle": "snake_case"}.newTable())
    it("registers an offense for camel case in local variable name", proc () =
      expectOffense("""        myLocal = 1
        ^^^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for correct + opposite", proc () =
      expectOffense("""        my_local = 1
        myLocal = 1
        ^^^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for camel case in instance variable name", proc () =
      expectOffense("""        @myAttribute = 3
        ^^^^^^^^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for camel case in class variable name", proc () =
      expectOffense("""        @@myAttr = 2
        ^^^^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for camel case local variables marked as unused", proc () =
      expectOffense("""        _myLocal = 1
        ^^^^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for method arguments", proc () =
      expectOffense("""        def method(funnyArg); end
                   ^^^^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for default method arguments", proc () =
      expectOffense("""        def foo(optArg = 1); end
                ^^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for rest arguments", proc () =
      expectOffense("""        def foo(*restArg); end
                 ^^^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for keyword arguments", proc () =
      expectOffense("""        def foo(kwArg: 1); end
                ^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for keyword rest arguments", proc () =
      expectOffense("""        def foo(**kwRest); end
                  ^^^^^^ Use snake_case for variable names.
""".stripIndent))
    it("registers an offense for block arguments", proc () =
      expectOffense("""        def foo(&blockArg); end
                 ^^^^^^^^ Use snake_case for variable names.
""".stripIndent))
    includeExamples("always accepted"))
  context("when configured for camelCase", proc () =
    let("cop_config", proc (): Table[string, string] =
      {"EnforcedStyle": "camelCase"}.newTable())
    it("registers an offense for snake case in local variable name", proc () =
      expectOffense("""        my_local = 1
        ^^^^^^^^ Use camelCase for variable names.
""".stripIndent))
    it("registers an offense for opposite + correct", proc () =
      expectOffense("""        my_local = 1
        ^^^^^^^^ Use camelCase for variable names.
        myLocal = 1
""".stripIndent))
    it("accepts camel case in local variable name", proc () =
      expectNoOffenses("myLocal = 1"))
    it("accepts camel case in instance variable name", proc () =
      expectNoOffenses("@myAttribute = 3"))
    it("accepts camel case in class variable name", proc () =
      expectNoOffenses("@@myAttr = 2"))
    it("registers an offense for snake case in method parameter", proc () =
      expectOffense("""        def method(funny_arg); end
                   ^^^^^^^^^ Use camelCase for variable names.
""".stripIndent))
    it("accepts camel case local variables marked as unused", proc () =
      expectNoOffenses("_myLocal = 1"))
    it("registers an offense for default method arguments", proc () =
      expectOffense("""        def foo(opt_arg = 1); end
                ^^^^^^^ Use camelCase for variable names.
""".stripIndent))
    it("registers an offense for rest arguments", proc () =
      expectOffense("""        def foo(*rest_arg); end
                 ^^^^^^^^ Use camelCase for variable names.
""".stripIndent))
    it("registers an offense for keyword arguments", proc () =
      expectOffense("""        def foo(kw_arg: 1); end
                ^^^^^^ Use camelCase for variable names.
""".stripIndent))
    it("registers an offense for keyword rest arguments", proc () =
      expectOffense("""        def foo(**kw_rest); end
                  ^^^^^^^ Use camelCase for variable names.
""".stripIndent))
    it("registers an offense for block arguments", proc () =
      expectOffense("""        def foo(&block_arg); end
                 ^^^^^^^^^ Use camelCase for variable names.
""".stripIndent))
    includeExamples("always accepted")))
