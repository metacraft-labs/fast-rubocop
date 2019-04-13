
import
  types

import
  disjunctive_assignment_in_constructor, test_tools

RSpec.describe(DisjunctiveAssignmentInConstructor, "config", proc () =
  var cop = ()
  context("empty constructor", proc () =
    test "accepts":
      expectNoOffenses("""        class Banana
          def initialize
          end
        end
""".stripIndent))
  context("constructor does not have disjunctive assignment", proc () =
    test "accepts":
      expectNoOffenses("""        class Banana
          def initialize
            @delicious = true
          end
        end
""".stripIndent))
  context("constructor has disjunctive assignment", proc () =
    context("LHS is lvar", proc () =
      test "accepts":
        expectNoOffenses("""          class Banana
            def initialize
              delicious ||= true
            end
          end
""".stripIndent))
    context("LHS is ivar", proc () =
      test "registers an offense":
        expectOffense("""          class Banana
            def initialize
              @delicious ||= true
                         ^^^ Unnecessary disjunctive assignment. Use plain assignment.
            end
          end
""".stripIndent)
      context("constructor calls super after assignment", proc () =
        test "registers an offense":
          expectOffense("""            class Banana
              def initialize
                @delicious ||= true
                           ^^^ Unnecessary disjunctive assignment. Use plain assignment.
                super
              end
            end
""".stripIndent))
      context("constructor calls super before disjunctive assignment", proc () =
        test "accepts":
          expectNoOffenses("""            class Banana
              def initialize
                super
                @delicious ||= true
              end
            end
""".stripIndent))
      context("constructor calls any method before disjunctive assignment", proc () =
        test "accepts":
          expectNoOffenses("""            class Banana
              def initialize
                # With the limitations of static analysis, it's very difficult
                # to determine, after this method call, whether the disjunctive
                # assignment is necessary or not.
                absolutely_any_method
                @delicious ||= true
              end
            end
""".stripIndent)))))
