
import
  class_structure, test_tools

RSpec.describe(ClassStructure, "config", proc (): void =
  var cop = ()
  let("config", proc (): void =
    Config.new())
  context("with a complete ordered example", proc (): void =
    test "does not create offense":
      expectNoOffenses("""        class Person
          # extend and include go first
          extend SomeModule
          include AnotherModule

          # inner classes
          CustomError = Class.new(StandardError)

          # constants are next
          SOME_CONSTANT = 20

          # afterwards we have attribute macros
          attr_reader :name

          # followed by other macros (if any)
          validates :name

          # public class methods are next in line
          def self.some_method
          end

          # initialization goes between class methods and other instance methods
          def initialize
          end

          # followed by other public instance methods
          def some_method
          end

          # protected and private methods are grouped near the end
          protected

          def some_protected_method
          end

          private

          def some_private_method
          end
        end
"""))
  context("simple example", proc (): void =
    specify(proc (): void =
      expectOffense("""        class Person
          CONST = 'wrong place'
          include AnotherModule
          ^^^^^^^^^^^^^^^^^^^^^ `module_inclusion` is supposed to appear before `constants`.
          extend SomeModule
        end
""".stripIndent))
    specify(proc (): void =
      expect(autocorrectSourceWithLoop("""        class Example
          CONST = 1
          include AnotherModule
          extend SomeModule
        end
""".stripIndent)).to(eq("""        class Example
          include AnotherModule
          extend SomeModule
          CONST = 1
        end
""".stripIndent))))
  context("with protected methods declared before private", proc (): void =
    let("code", proc (): void =
      """      class MyClass
        def public_method
        end

        private

        def first_private_method
        end

        def second_private_method
        end

        protected

        def first_protected_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ `protected_methods` is supposed to appear before `private_methods`.
        end

        def second_protected_method
        end
      end
""")
    it(proc (): void =
      expectOffense(code())))
  context("with attribute macros before after validations", proc (): void =
    let("code", proc (): void =
      """      class Person
        include AnotherModule
        extend SomeModule

        CustomError = Class.new(StandardError)

        validates :name

        attr_reader :name
        ^^^^^^^^^^^^^^^^^ `attribute_macros` is supposed to appear before `macros`.

        def self.some_public_class_method
        end

        def initialize
        end

        def some_public_method
        end

        def other_public_method
        end

        private :other_public_method

        private def something_inline
        end

        def yet_other_public_method
        end

        protected

        def some_protected_method
        end

        private

        def some_private_method
        end
      end
""")
    it(proc (): void =
      expectOffense(code())))
  describe("#autocorrect", proc (): void =
    context("when there is a comment in the macro method", proc (): void =
      test "autocorrects the offenses":
        var newSource = autocorrectSource("""          class Foo
            # This is a comment for macro method.
            validates :attr
            attr_reader :foo
          end
""".stripIndent)
        expect(newSource).to(eq("""          class Foo
            attr_reader :foo
            # This is a comment for macro method.
            validates :attr
          end
""".stripIndent)))))
