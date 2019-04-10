
import
  tables

import
  method_name, test_tools

RSpec.describe(MethodName, "config", proc (): void =
  var cop = ()
  sharedExamples("never accepted", proc (enforcedStyle: string): void =
    test "registers an offense for mixed snake case and camel case":
      expectOffense("""        def visit_Arel_Nodes_SelectStatement
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use (lvar :enforced_style) for method names.
        end
""".stripIndent)
    test "registers an offense for capitalized camel case":
      expectOffense("""        class MyClass
          def MyMethod
              ^^^^^^^^ Use (lvar :enforced_style) for method names.
          end
        end
""".stripIndent)
    test """registers an offense for singleton upper case method without corresponding class""":
      expectOffense("""        module Sequel
          def self.Model(source)
                   ^^^^^ Use (lvar :enforced_style) for method names.
          end
        end
""".stripIndent))
  sharedExamples("always accepted", proc (): void =
    test "accepts one line methods":
      expectNoOffenses("def body; \'\' end")
    test "accepts operator definitions":
      expectNoOffenses("""        def +(other)
          # ...
        end
""".stripIndent)
    test "accepts unary operator definitions":
      expectNoOffenses("        def ~@; end\n".stripIndent)
      expectNoOffenses("        def !@; end\n".stripIndent)
    for kind in @["class", "module"]:
      test """accepts class emitter method in a (lvar :kind)""":
        expectNoOffenses("""          (lvar :kind) Sequel
            def self.Model(source)
            end

            class Model
            end
          end
""".stripIndent)
      test """(str "accepts class emitter method in a ")defined inside another method""":
        expectNoOffenses("""          module DPN
            module Flow
              module BaseFlow
                class Start
                end
                def self.included(base)
                  def base.Start(aws_env, *args)
                  end
                end
              end
            end
          end
""".stripIndent))
  context("when configured for snake_case", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "snake_case"}.newTable())
    test "registers an offense for camel case in instance method name":
      expectOffense("""        def myMethod
            ^^^^^^^^ Use snake_case for method names.
          # ...
        end
""".stripIndent)
    test "registers an offense for opposite + correct":
      expectOffense("""        def my_method
        end
        def myMethod
            ^^^^^^^^ Use snake_case for method names.
        end
""".stripIndent)
    test "registers an offense for camel case in singleton method name":
      expectOffense("""        def self.myMethod
                 ^^^^^^^^ Use snake_case for method names.
          # ...
        end
""".stripIndent)
    test "accepts snake case in names":
      expectNoOffenses("""        def my_method
        end
""".stripIndent)
    test "registers an offense for singleton camelCase method within class":
      expectOffense("""        class Sequel
          def self.fooBar
                   ^^^^^^ Use snake_case for method names.
          end
        end
""".stripIndent)
    includeExamples("never accepted", "snake_case")
    includeExamples("always accepted", "snake_case"))
  context("when configured for camelCase", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "camelCase"}.newTable())
    test "accepts camel case in instance method name":
      expectNoOffenses("""        def myMethod
          # ...
        end
""".stripIndent)
    test "accepts camel case in singleton method name":
      expectNoOffenses("""        def self.myMethod
          # ...
        end
""".stripIndent)
    test "registers an offense for snake case in names":
      expectOffense("""        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
""".stripIndent)
    test "registers an offense for correct + opposite":
      expectOffense("""        def myMethod
        end
        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
""".stripIndent)
    test "registers an offense for singleton snake_case method within class":
      expectOffense("""        class Sequel
          def self.foo_bar
                   ^^^^^^^ Use camelCase for method names.
          end
        end
""".stripIndent)
    includeExamples("always accepted", "camelCase")
    includeExamples("never accepted", "camelCase")))
