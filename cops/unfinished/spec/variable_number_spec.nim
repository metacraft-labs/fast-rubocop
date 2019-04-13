
import
  sequtils

import
  variable_number, test_tools

RSpec.describe(VariableNumber, "config", proc (): void =
  var cop = ()
  sharedExamples("offense", proc (style: string; variable: Array;
                                styleToAllowOffenses: NilClass): void =
    test """registers an offense for (send
  (send nil :Array
    (lvar :variable)) :first) in (lvar :style)""":
      inspectSource(Array(variable).mapIt:
        """(lvar :v) = 1""".join("\n"))
      expect(cop().messages).to(eq(@["""Use (lvar :style) for variable numbers."""]))
      expect(cop().highlights).to(eq(Array(variable)[0]))
      var configToAllowOffenses = if styleToAllowOffenses:
        {"EnforcedStyle": `$`()}.newTable()
      else:
        {"Enabled": false}.newTable()
      expect(cop().configToAllowOffenses).to(eq(configToAllowOffenses)))
  sharedExamples("accepts", proc (style: string; variable: string): void =
    test """accepts (lvar :variable) in (lvar :style)""":
      expectNoOffenses("""(lvar :variable) = 1"""))
  context("when configured for snake_case", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "snake_case"}.newTable())
    itBehavesLike("offense", "snake_case", "local1", "normalcase")
    itBehavesLike("offense", "snake_case", "@local1", "normalcase")
    itBehavesLike("offense", "snake_case", "@@local1", "normalcase")
    itBehavesLike("offense", "snake_case", "camelCase1", "normalcase")
    itBehavesLike("offense", "snake_case", "@camelCase1", "normalcase")
    itBehavesLike("offense", "snake_case", "_unused1", "normalcase")
    itBehavesLike("offense", "snake_case", "aB1", "normalcase")
    itBehavesLike("offense", "snake_case", @["a1", "a_2"], )
    itBehavesLike("accepts", "snake_case", "local_1")
    itBehavesLike("accepts", "snake_case", "local_12")
    itBehavesLike("accepts", "snake_case", "local_123")
    itBehavesLike("accepts", "snake_case", "local_")
    itBehavesLike("accepts", "snake_case", "aB_1")
    itBehavesLike("accepts", "snake_case", "a_1_b")
    itBehavesLike("accepts", "snake_case", "a_1_b_1")
    itBehavesLike("accepts", "snake_case", "_")
    itBehavesLike("accepts", "snake_case", "_foo")
    itBehavesLike("accepts", "snake_case", "@foo")
    itBehavesLike("accepts", "snake_case", "@__foo__")
    test "registers an offense for normal case numbering in method parameter":
      expectOffense("""        def method(arg1); end
                   ^^^^ Use snake_case for variable numbers.
""".stripIndent)
    test """registers an offense for normal case numbering in method camel case
     parameter""":
      expectOffense("""        def method(funnyArg1); end
                   ^^^^^^^^^ Use snake_case for variable numbers.
""".stripIndent))
  context("when configured for normal", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "normalcase"}.newTable())
    itBehavesLike("offense", "normalcase", "local_1", "snake_case")
    itBehavesLike("offense", "normalcase", "sha_256", "snake_case")
    itBehavesLike("offense", "normalcase", "@local_1", "snake_case")
    itBehavesLike("offense", "normalcase", "@@local_1", "snake_case")
    itBehavesLike("offense", "normalcase", "myAttribute_1", "snake_case")
    itBehavesLike("offense", "normalcase", "@myAttribute_1", "snake_case")
    itBehavesLike("offense", "normalcase", "_myLocal_1", "snake_case")
    itBehavesLike("offense", "normalcase", "localFOO_1", "snake_case")
    itBehavesLike("offense", "normalcase", "local_FOO_1", "snake_case")
    itBehavesLike("offense", "normalcase", @["a_1", "a2"], )
    itBehavesLike("accepts", "normalcase", "local1")
    itBehavesLike("accepts", "normalcase", "local_")
    itBehavesLike("accepts", "normalcase", "user1_id")
    itBehavesLike("accepts", "normalcase", "sha256")
    itBehavesLike("accepts", "normalcase", "foo10_bar")
    itBehavesLike("accepts", "normalcase", "target_u2f_device")
    itBehavesLike("accepts", "normalcase", "localFOO1")
    itBehavesLike("accepts", "normalcase", "snake_case")
    itBehavesLike("accepts", "normalcase", "user_1_id")
    itBehavesLike("accepts", "normalcase", "_")
    itBehavesLike("accepts", "normalcase", "_foo")
    itBehavesLike("accepts", "normalcase", "@foo")
    itBehavesLike("accepts", "normalcase", "@__foo__")
    test "registers an offense for snake case numbering in method parameter":
      expectOffense("""        def method(arg_1); end
                   ^^^^^ Use normalcase for variable numbers.
""".stripIndent)
    test """registers an offense for snake case numbering in method camel case
     parameter""":
      expectOffense("""        def method(funnyArg_1); end
                   ^^^^^^^^^^ Use normalcase for variable numbers.
""".stripIndent))
  context("when configured for non integer", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "non_integer"}.newTable())
    itBehavesLike("offense", "non_integer", "local_1", "snake_case")
    itBehavesLike("offense", "non_integer", "local1", "normalcase")
    itBehavesLike("offense", "non_integer", "@local_1", "snake_case")
    itBehavesLike("offense", "non_integer", "@local1", "normalcase")
    itBehavesLike("offense", "non_integer", "myAttribute_1", "snake_case")
    itBehavesLike("offense", "non_integer", "myAttribute1", "normalcase")
    itBehavesLike("offense", "non_integer", "@myAttribute_1", "snake_case")
    itBehavesLike("offense", "non_integer", "@myAttribute1", "normalcase")
    itBehavesLike("offense", "non_integer", "_myLocal_1", "snake_case")
    itBehavesLike("offense", "non_integer", "_myLocal1", "normalcase")
    itBehavesLike("offense", "non_integer", @["a_1", "aone"], )
    itBehavesLike("accepts", "non_integer", "localone")
    itBehavesLike("accepts", "non_integer", "local_one")
    itBehavesLike("accepts", "non_integer", "local_")
    itBehavesLike("accepts", "non_integer", "@foo")
    itBehavesLike("accepts", "non_integer", "@@foo")
    itBehavesLike("accepts", "non_integer", "fooBar")
    itBehavesLike("accepts", "non_integer", "_")
    itBehavesLike("accepts", "non_integer", "_foo")
    itBehavesLike("accepts", "non_integer", "@__foo__")
    test "registers an offense for snake case numbering in method parameter":
      expectOffense("""        def method(arg_1); end
                   ^^^^^ Use non_integer for variable numbers.
""".stripIndent)
    test "registers an offense for normal case numbering in method parameter":
      expectOffense("""        def method(arg1); end
                   ^^^^ Use non_integer for variable numbers.
""".stripIndent)
    test """registers an offense for snake case numbering in method camel case
     parameter""":
      expectOffense("""        def method(myArg_1); end
                   ^^^^^^^ Use non_integer for variable numbers.
""".stripIndent)
    test """registers an offense for normal case numbering in method camel case
     parameter""":
      expectOffense("""        def method(myArg1); end
                   ^^^^^^ Use non_integer for variable numbers.
""".stripIndent)))
