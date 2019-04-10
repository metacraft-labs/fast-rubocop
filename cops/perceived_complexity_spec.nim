
import
  perceived_complexity, test_tools

RSpec.describe(PerceivedComplexity, "config", proc (): void =
  var cop = ()
  context("when Max is 1", proc (): void =
    let("cop_config", proc (): void =
      {"Max": 1}.newTable())
    test "accepts a method with no decision points":
      expectNoOffenses("""        def method_name
          call_foo
        end
""".stripIndent)
    test "accepts an empty method":
      expectNoOffenses("""        def method_name
        end
""".stripIndent)
    test "accepts an empty `define_method`":
      expectNoOffenses("""        define_method :method_name do
        end
""".stripIndent)
    test "accepts complex code outside of methods":
      expectNoOffenses("""        def method_name
          call_foo
        end

        if first_condition then
          call_foo if second_condition && third_condition
          call_bar if fourth_condition || fifth_condition
        end
""".stripIndent)
    test "registers an offense for an if modifier":
      expectOffense("""        def self.method_name
        ^^^^^^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          call_foo if some_condition
        end
""".stripIndent)
    test "registers an offense for an unless modifier":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          call_foo unless some_condition
        end
""".stripIndent)
    test "registers an offense for elsif and else blocks":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [4/1]
          if first_condition then
            call_foo
          elsif second_condition then
            call_bar
          else
            call_bam
          end
        end
""".stripIndent)
    test "registers an offense for a ternary operator":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          value = some_condition ? 1 : 2
        end
""".stripIndent)
    test "registers an offense for a while block":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          while some_condition do
            call_foo
          end
        end
""".stripIndent)
    test "registers an offense for an until block":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          until some_condition do
            call_foo
          end
        end
""".stripIndent)
    test "registers an offense for a for block":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          for i in 1..2 do
            call_method
          end
        end
""".stripIndent)
    test "registers an offense for a rescue block":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          begin
            call_foo
          rescue Exception
            call_bar
          end
        end
""".stripIndent)
    test "registers an offense for a case/when block":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [3/1]
          case value
          when 1 then call_foo_1
          when 2 then call_foo_2
          when 3 then call_foo_3
          when 4 then call_foo_4
          end
        end
""".stripIndent)
    test """registers an offense for a case/when block without an expression after case""":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [3/1]
          case
          when value == 1
            call_foo
          when value == 2
            call_bar
          end
        end
""".stripIndent)
    test "registers an offense for &&":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          call_foo && call_bar
        end
""".stripIndent)
    test "registers an offense for and":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          call_foo and call_bar
        end
""".stripIndent)
    test "registers an offense for ||":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          call_foo || call_bar
        end
""".stripIndent)
    test "registers an offense for or":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          call_foo or call_bar
        end
""".stripIndent)
    test "deals with nested if blocks containing && and ||":
      expectOffense("""        def method_name
        ^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [6/1]
          if first_condition then
            call_foo if second_condition && third_condition
            call_bar if fourth_condition || fifth_condition
          end
        end
""".stripIndent)
    test "counts only a single method":
      expectOffense("""        def method_name_1
        ^^^^^^^^^^^^^^^^^ Perceived complexity for method_name_1 is too high. [2/1]
          call_foo if some_condition
        end

        def method_name_2
        ^^^^^^^^^^^^^^^^^ Perceived complexity for method_name_2 is too high. [2/1]
          call_foo if some_condition
        end
""".stripIndent)
    test "registers an offense for a `define_method`":
      expectOffense("""        define_method :method_name do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [2/1]
          call_foo if some_condition
        end
""".stripIndent))
  context("when Max is 2", proc (): void =
    let("cop_config", proc (): void =
      {"Max": 2}.newTable())
    test "counts stupid nested if and else blocks":
      expectOffense("""        def method_name                   # 1
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Perceived complexity for method_name is too high. [7/2]
          if first_condition then         # 2
            call_foo
          else                            # 3
            if second_condition then      # 4
              call_bar
            else                          # 5
              call_bam if third_condition # 6
            end
            call_baz if fourth_condition  # 7
          end
        end
""".stripIndent)))
