
import
  class_methods, test_tools

suite "ClassMethods":
  var cop = ClassMethods()
  test "registers an offense for methods using a class name":
    expectOffense("""      class Test
        def Test.some_method
            ^^^^ Use `self.some_method` instead of `Test.some_method`.
          do_something
        end
      end
""".stripIndent)
  test "registers an offense for methods using a module name":
    expectOffense("""      module Test
        def Test.some_method
            ^^^^ Use `self.some_method` instead of `Test.some_method`.
          do_something
        end
      end
""".stripIndent)
  test "does not register an offense for methods using self":
    expectNoOffenses("""      module Test
        def self.some_method
          do_something
        end
      end
""".stripIndent)
  test "does not register an offense for other top-level singleton methods":
    expectNoOffenses("""      class Test
        X = Something.new

        def X.some_method
          do_something
        end
      end
""".stripIndent)
  test "does not register an offense outside class/module bodies":
    expectNoOffenses("""      def Test.some_method
        do_something
      end
""".stripIndent)
  test "autocorrects class name to self":
    var
      src = """      class Test
        def Test.some_method
          do_something
        end
      end
""".stripIndent
      correctSource = """      class Test
        def self.some_method
          do_something
        end
      end
""".stripIndent
      newSource = autocorrectSource(src)
    expect(newSource).to(eq(correctSource))
