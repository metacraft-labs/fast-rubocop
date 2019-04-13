
import
  tables

import
  abc_size, test_tools

RSpec.describe(AbcSize, "config", proc (): void =
  var cop = ()
  context("when Max is 0", proc (): void =
    let("cop_config", proc (): void =
      {"Max": 0}.newTable())
    test "accepts an empty method":
      expectNoOffenses("""        def method_name
        end
""".stripIndent)
    test "accepts an empty `define_method`":
      expectNoOffenses("""        define_method :method_name do
        end
""".stripIndent)
    test "registers an offense for an if modifier":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [2.24/0]
          call_foo if some_condition # 0 + 2*2 + 1*1
        end
""".stripIndent)
    test "registers an offense for an assignment of a local variable":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [1/0]
          x = 1
        end
""".stripIndent)
    test "registers an offense for an assignment of an element":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [1.41/0]
          x[0] = 1
        end
""".stripIndent)
    test """registers an offense for complex content including A, B, and C scores""":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [6.4/0]
          my_options = Hash.new if 1 == 1 || 2 == 2 # 1, 3, 2
          my_options.each do |key, value|           # 0, 1, 0
            p key                                   # 0, 1, 0
            p value                                 # 0, 1, 0
          end
        end
""".stripIndent)
    test "registers an offense for a `define_method`":
      expectOffense("""        define_method :method_name do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [1/0]
          x = 1
        end
""".stripIndent)
    context("target_ruby_version >= 2.3", "ruby23", proc (): void =
      test "treats safe navigation method calls like regular method calls":
        expectOffense("""          def method_name
          ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [2/0]
            object&.do_something
          end
""".stripIndent)))
  context("when Max is 2", proc (): void =
    let("cop_config", proc (): void =
      {"Max": 2}.newTable())
    test "accepts two assignments":
      expectNoOffenses("""        def method_name
          x = 1
          y = 2
        end
""".stripIndent))
  context("when Max is 1.8", proc (): void =
    let("cop_config", proc (): void =
      {"Max": 0.0}.newTable())
    test "accepts a total score of 1.7":
      expectNoOffenses("""        def method_name
          y = 1 if y == 1
        end
""".stripIndent))
  for max, presentation in {0.0: "3.74/1.3", 0.0: "37.42/10.3", 0.0: "374.2/100.3",
                        0.0: "3742/1000"}.newTable():
    context("""when Max is (lvar :max)""", proc (): void =
      let("cop_config", proc (): void =
        {"Max": max}.newTable())
      test """reports size and max as (lvar :presentation)""":
        var code = @["  x = Hash.new if 1 == 1 || 2 == 2"] * max
        inspectSource(("def method_name", "end").join("\n"))
        expect(cop().messages).to(eq(@["""Assignment Branch Condition size for method_name is too (str "high. [")"""]))))
