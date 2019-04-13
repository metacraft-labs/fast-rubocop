
import
  class_and_module_children, test_tools

RSpec.describe(ClassAndModuleChildren, "config", proc (): void =
  var cop = ()
  context("nested style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "nested"}.newTable())
    test "registers an offense for not nested classes":
      expectOffense("""        class FooClass::BarClass
              ^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
""".stripIndent)
    test "registers an offense for not nested classes with explicit superclass":
      expectOffense("""        class FooClass::BarClass < Super
              ^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
""".stripIndent)
    test "registers an offense for not nested modules":
      expectOffense("""        module FooModule::BarModule
               ^^^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
""".stripIndent)
    test "accepts nested children":
      expectNoOffenses("""        class FooClass
          class BarClass
          end
        end

        module FooModule
          module BarModule
          end
        end
""".stripIndent)
    test "accepts :: in parent class on inheritance":
      expectNoOffenses("""        class FooClass
          class BarClass
          end
        end

        class BazClass < FooClass::BarClass
        end
""".stripIndent))
  context("compact style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "compact"}.newTable())
    test "registers a offense for classes with nested children":
      expectOffense("""        class FooClass
              ^^^^^^^^ Use compact module/class definition instead of nested style.
          class BarClass
          end
        end
""".stripIndent)
    test "registers a offense for modules with nested children":
      expectOffense("""        module FooModule
               ^^^^^^^^^ Use compact module/class definition instead of nested style.
          module BarModule
          end
        end
""".stripIndent)
    test "accepts compact style for classes/modules":
      expectNoOffenses("""        class FooClass::BarClass
        end

        module FooClass::BarModule
        end
""".stripIndent)
    test "accepts nesting for classes/modules with more than one child":
      expectNoOffenses("""        class FooClass
          class BarClass
          end
          class BazClass
          end
        end

        module FooModule
          module BarModule
          end
          class BazModule
          end
        end
""".stripIndent)
    test "accepts class/module with single method":
      expectNoOffenses("""        class FooClass
          def bar_method
          end
        end
""".stripIndent)
    test "accepts nesting for classes with an explicit superclass":
      expectNoOffenses("""        class FooClass < Super
          class BarClass
          end
        end
""".stripIndent))
  context("autocorrect", proc (): void =
    let("cop_config", proc (): void =
      {"AutoCorrect": "true", "EnforcedStyle": enforcedStyle()}.newTable())
    context("nested style", proc (): void =
      let("enforced_style", proc (): void =
        "nested")
      test "corrects a not nested class":
        var
          source = """          class FooClass::BarClass
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""          module FooClass
            class BarClass
            end
          end
""".stripIndent))
      test "corrects a not nested class with explicit superclass":
        var
          source = """        class FooClass::BarClass < Super
        end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""          module FooClass
            class BarClass < Super
            end
          end
""".stripIndent))
      test "corrects a not nested module":
        var
          source = """          module FooClass::BarClass
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""          module FooClass
            module BarClass
            end
          end
""".stripIndent))
      test "does not correct nested children":
        var
          source = """          class FooClass
            class BarClass
            end
          end

          module FooModule
            module BarModule
            end
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq(source))
      test "does not correct :: in parent class on inheritance":
        var
          source = """          class FooClass
            class BarClass
            end
          end

          class BazClass < FooClass::BarClass
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq(source)))
    context("compact style", proc (): void =
      let("enforced_style", proc (): void =
        "compact")
      test "corrects nested children":
        var
          source = """          class FooClass
            class BarClass
            end
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""          class FooClass::BarClass
          end
""".stripIndent))
      test "corrects modules with nested children":
        var
          source = """          module FooModule
            module BarModule
            end
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""          module FooModule::BarModule
          end
""".stripIndent))
      test "does not correct compact style for classes/modules":
        var
          source = """          class FooClass::BarClass
          end

          module FooClass::BarModule
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq(source))
      test "does not correct nested classes/modules with more than one child":
        var
          source = """          class FooClass
            class BarClass
            end
            class BazClass
            end
          end

          module FooModule
            module BarModule
            end
            class BazModule
            end
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq(source))
      test "does not correct class/module with single method":
        var
          source = """          class FooClass
            def bar_method
            end
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq(source))
      test "does not correct nesting for classes with an explicit superclass":
        var
          source = """          class FooClass < Super
            class BarClass
            end
          end
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq(source)))))
