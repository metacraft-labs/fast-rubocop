
import
  types

import
  method_length, test_tools

RSpec.describe(MethodLength, "config", proc () =
  var cop = ()
  let("cop_config", proc (): Table[string, int] =
    {"Max": 5, "CountComments": false}.newTable())
  context("when method is an instance method", proc () =
    test "registers an offense":
      expectOffense("""        def m
        ^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
""".stripIndent))
  context("when method is defined with `define_method`", proc () =
    test "registers an offense":
      expectOffense("""        define_method(:m) do
        ^^^^^^^^^^^^^^^^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
""".stripIndent))
  context("when method is a class method", proc () =
    test "registers an offense":
      expectOffense("""        def self.m
        ^^^^^^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
""".stripIndent))
  context("when method is defined on a singleton class", proc () =
    test "registers an offense":
      expectOffense("""        class K
          class << self
            def m
            ^^^^^ Method has too many lines. [6/5]
              a = 1
              a = 2
              a = 3
              a = 4
              a = 5
              a = 6
            end
          end
        end
""".stripIndent))
  test "accepts a method with less than 5 lines":
    expectNoOffenses("""      def m
        a = 1
        a = 2
        a = 3
        a = 4
      end
""".stripIndent)
  test """accepts a method with multiline arguments and less than 5 lines of body""":
    expectNoOffenses("""      def m(x,
            y,
            z)
        a = 1
        a = 2
        a = 3
        a = 4
      end
""".stripIndent)
  test "does not count blank lines":
    expectNoOffenses("""      def m()
        a = 1
        a = 2
        a = 3
        a = 4


        a = 7
      end
""".stripIndent)
  test "accepts empty methods":
    expectNoOffenses("""      def m()
      end
""".stripIndent)
  test "is not fooled by one-liner methods, syntax #1":
    expectNoOffenses("""      def one_line; 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
""".stripIndent)
  test "is not fooled by one-liner methods, syntax #2":
    expectNoOffenses("""      def one_line(test) 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
""".stripIndent)
  test "properly counts lines when method ends with block":
    expectOffense("""      def m
      ^^^^^ Method has too many lines. [6/5]
        something do
          a = 2
          a = 3
          a = 4
          a = 5
        end
      end
""".stripIndent)
  test "does not count commented lines by default":
    expectNoOffenses("""      def m()
        a = 1
        #a = 2
        a = 3
        #a = 4
        a = 5
        a = 6
      end
""".stripIndent)
  context("when CountComments is enabled", proc () =
    before(proc () =
      copConfig().[]=("CountComments", true))
    test "also counts commented lines":
      expectOffense("""        def m
        ^^^^^ Method has too many lines. [6/5]
          a = 1
          #a = 2
          a = 3
          #a = 4
          a = 5
          a = 6
        end
""".stripIndent))
  context("when method is defined in `ExcludedMethods`", proc () =
    before(proc () =
      copConfig().[]=("ExcludedMethods", @["foo"]))
    test "still rejects other methods with more than 5 lines":
      expectOffense("""        def m 
        ^^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
""".stripIndent)
    test "accepts the foo method with more than 5 lines":
      expectNoOffenses("""        def foo
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
""".stripIndent)))
