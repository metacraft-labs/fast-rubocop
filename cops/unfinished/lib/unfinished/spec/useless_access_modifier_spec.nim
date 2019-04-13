
import
  tables

import
  useless_access_modifier, test_tools

suite "UselessAccessModifier":
  var cop = UselessAccessModifier()
  let("config", proc (): void =
    Config.new)
  context("when an access modifier has no effect", proc (): void =
    test "registers an offense":
      expectOffense("""        class SomeClass
          def some_method
            puts 10
          end
          private
          ^^^^^^^ Useless `private` access modifier.
          def self.some_method
            puts 10
          end
        end
""".stripIndent))
  context("when an access modifier has no methods", proc (): void =
    test "registers an offense":
      expectOffense("""        class SomeClass
          def some_method
            puts 10
          end
          protected
          ^^^^^^^^^ Useless `protected` access modifier.
        end
""".stripIndent))
  context("when an access modifier is followed by attr_*", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        class SomeClass
          protected
          attr_accessor :some_property
          public
          attr_reader :another_one
          private
          attr :yet_again, true
          protected
          attr_writer :just_for_good_measure
        end
""".stripIndent))
  context("""when an access modifier is followed by a class method defined on constant""", proc (): void =
    test "registers an offense":
      expectOffense("""        class SomeClass
          protected
          ^^^^^^^^^ Useless `protected` access modifier.
          def SomeClass.some_method
          end
        end
""".stripIndent))
  context("when there are consecutive access modifiers", proc (): void =
    test "registers an offense":
      expectOffense("""        class SomeClass
         private
         private
         ^^^^^^^ Useless `private` access modifier.
          def some_method
            puts 10
          end
          def some_other_method
            puts 10
          end
        end
""".stripIndent))
  context("when passing method as symbol", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        class SomeClass
          def some_method
            puts 10
          end
          private :some_method
        end
""".stripIndent))
  context("when class is empty save modifier", proc (): void =
    test "registers an offense":
      expectOffense("""        class SomeClass
          private
          ^^^^^^^ Useless `private` access modifier.
        end
""".stripIndent))
  context("when multiple class definitions in file but only one has offense", proc (): void =
    test "registers an offense":
      expectOffense("""        class SomeClass
          private
          ^^^^^^^ Useless `private` access modifier.
        end
        class SomeOtherClass
        end
""".stripIndent))
  context("when using inline modifiers", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        class SomeClass
          private def some_method
            puts 10
          end
        end
""".stripIndent))
  context("""when only a constant or local variable is defined after the modifier""", proc (): void =
    for bindingName in @["CONSTANT", "some_var"]:
      test "registers an offense":
        expectOffense("""          class SomeClass
            private
            ^^^^^^^ Useless `private` access modifier.
            (lvar :binding_name) = 1
          end
""".stripIndent))
  context("when a def is an argument to a method call", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        class SomeClass
          private
          helper_method def some_method
            puts 10
          end
        end
""".stripIndent))
  context("when private_class_method is used without arguments", proc (): void =
    test "registers an offense":
      expectOffense("""        class SomeClass
          private_class_method
          ^^^^^^^^^^^^^^^^^^^^ Useless `private_class_method` access modifier.

          def self.some_method
            puts 10
          end
        end
""".stripIndent))
  context("when private_class_method is used with arguments", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        class SomeClass
          private_class_method def self.some_method
            puts 10
          end
        end
""".stripIndent))
  context("when using ActiveSupport\'s `concerning` method", proc (): void =
    let("config", proc (): void =
      Config.new())
    test "is aware that this creates a new scope":
      expectNoOffenses("""        class SomeClass
          concerning :FirstThing do
            def foo
            end
            private

            def method
            end
          end

          concerning :SecondThing do
            def omg
            end
            private
            def method
            end
          end
         end
""".stripIndent)
    test "still points out redundant uses within the block":
      expectOffense("""        class SomeClass
          concerning :FirstThing do
            def foo
            end
            private

            def method
            end
          end

          concerning :SecondThing do
            def omg
            end
            private
            def method
            end
            private
            ^^^^^^^ Useless `private` access modifier.
            def another_method
            end
          end
         end
""".stripIndent))
  context("when using ActiveSupport behavior when Rails is not eabled", proc (): void =
    test "reports offenses":
      expectOffense("""        module SomeModule
          extend ActiveSupport::Concern
          class_methods do
            def some_public_class_method
            end
            private
            def some_private_class_method
            end
          end
          def some_public_instance_method
          end
          private
          ^^^^^^^ Useless `private` access modifier.
          def some_private_instance_method
          end
        end
""".stripIndent))
  context("when using the class_methods method from ActiveSupport::Concern", proc (): void =
    let("config", proc (): void =
      Config.new())
    test "is aware that this creates a new scope":
      expectNoOffenses("""        module SomeModule
          extend ActiveSupport::Concern
          class_methods do
            def some_public_class_method
            end
            private
            def some_private_class_method
            end
          end
          def some_public_instance_method
          end
          private
          def some_private_instance_method
          end
        end
""".stripIndent))
  context("when using a known method-creating method", proc (): void =
    let("config", proc (): void =
      Config.new())
    test "is aware that this creates a new method":
      expectNoOffenses("""        class SomeClass
          private

          delegate :foo, to: :bar
        end
""".stripIndent)
    test "still points out redundant uses within the module":
      expectOffense("""        class SomeClass
          delegate :foo, to: :bar

          private
          ^^^^^^^ Useless `private` access modifier.
        end
""".stripIndent))
  sharedExamples("at the top of the body", proc (keyword: string): void =
    test "registers an offense for `public`":
      expectOffense("""        (lvar :keyword) A
          public
          ^^^^^^ Useless `public` access modifier.
          def method
          end
        end
""".stripIndent)
    test "doesn\'t register an offense for `protected`":
      expectNoOffenses("""        (lvar :keyword) A
          protected
          def method
          end
        end
""".stripIndent)
    test "doesn\'t register an offense for `private`":
      expectNoOffenses("""        (lvar :keyword) A
          private
          def method
          end
        end
""".stripIndent))
  sharedExamples("repeated visibility modifiers", proc (keyword: string;
      modifier: string): void =
    test """registers an offense when `(lvar :modifier)` is repeated""":
      var src = """        (lvar :keyword) A
          (if
  (send
    (lvar :modifier) :==
    (str "private"))
  (str "protected")
  (str "private"))
          def method1
          end
          (lvar :modifier)
          (lvar :modifier)
          def method2
          end
        end
""".stripIndent
      inspectSource(src)
      expect(cop().offenses.size).to(eq(1)))
  sharedExamples("non-repeated visibility modifiers", proc (keyword: string): void =
    test "registers an offense even when `public` is not repeated":
      expectOffense("""        (lvar :keyword) A
          def method1
          end
          public
          ^^^^^^ Useless `public` access modifier.
          def method2
          end
        end
""".stripIndent)
    test "doesn\'t register an offense when `protected` is not repeated":
      expectNoOffenses("""        (lvar :keyword) A
          def method1
          end
          protected
          def method2
          end
        end
""".stripIndent)
    test "doesn\'t register an offense when `private` is not repeated":
      expectNoOffenses("""        (lvar :keyword) A
          def method1
          end
          private
          def method2
          end
        end
""".stripIndent))
  sharedExamples("at the end of the body", proc (keyword: string; modifier: string): void =
    test """registers an offense for trailing `(lvar :modifier)`""":
      var src = """        (lvar :keyword) A
          def method1
          end
          def method2
          end
          (lvar :modifier)
        end
""".stripIndent
      inspectSource(src)
      expect(cop().offenses.size).to(eq(1)))
  sharedExamples("nested in a begin..end block", proc (keyword: string;
      modifier: string): void =
    test """still flags repeated `(lvar :modifier)`""":
      var src = """        (lvar :keyword) A
          (if
  (send
    (lvar :modifier) :==
    (str "private"))
  (str "protected")
  (str "private"))
          def blah
          end
          begin
            def method1
            end
            (lvar :modifier)
            (lvar :modifier)
            def method2
            end
          end
        end
""".stripIndent
      inspectSource(src)
      expect(cop().offenses.size).to(eq(1))
    if modifier == "public":
    else:
      test "doesn\'t flag an access modifier from surrounding scope":
        expectNoOffenses("""          (lvar :keyword) A
            (lvar :modifier)
            begin
              def method1
              end
            end
          end
""".stripIndent)
  )
  sharedExamples("unused visibility modifiers", proc (keyword: string): void =
    test """registers an error when visibility is immediately changed without any intervening defs""":
      expectOffense("""        (lvar :keyword) A
          private
          def method1
          end
          public
          ^^^^^^ Useless `public` access modifier.
          private
          def method2
          end
        end
""".stripIndent))
  sharedExamples("conditionally defined method", proc (keyword: string;
      modifier: string): void =
    for conditionalType in @["if", "unless"]:
      test """doesn't register an offense for (lvar :conditional_type)""":
        expectNoOffenses("""          (lvar :keyword) A
            (lvar :modifier)
            (lvar :conditional_type) x
              def method1
              end
            end
          end
""".stripIndent))
  sharedExamples("methods defined in an iteration", proc (keyword: string;
      modifier: string): void =
    for iterationMethod in @["each", "map"]:
      test """doesn't register an offense for (lvar :iteration_method)""":
        expectNoOffenses("""          (lvar :keyword) A
            (lvar :modifier)
            [1, 2].(lvar :iteration_method) do |i|
              define_method("method#{i}") do
                i
              end
            end
          end
""".stripIndent))
  sharedExamples("method defined with define_method", proc (keyword: string;
      modifier: string): void =
    test "doesn\'t register an offense if a block is passed":
      expectNoOffenses("""        (lvar :keyword) A
          (lvar :modifier)
          define_method(:method1) do
          end
        end
""".stripIndent)
    for procType in @["lambda", "proc", "->"]:
      test """doesn't register an offense if a (lvar :proc_type) is passed""":
        expectNoOffenses("""          (lvar :keyword) A
            (lvar :modifier)
            define_method(:method1, (lvar :proc_type) { })
          end
""".stripIndent))
  sharedExamples("method defined on a singleton class", proc (keyword: string;
      modifier: string): void =
    context("inside a class", proc (): void =
      test "doesn\'t register an offense if a method is defined":
        expectNoOffenses("""          (lvar :keyword) A
            class << self
              (lvar :modifier)
              define_method(:method1) do
              end
            end
          end
""".stripIndent)
      test """doesn't register an offense if the modifier is the same as outside the meta-class""":
        expectNoOffenses("""          (lvar :keyword) A
            (lvar :modifier)
            def method1
            end
            class << self
              (lvar :modifier)
              def method2
              end
            end
          end
""".stripIndent)
      test "registers an offense if no method is defined":
        var src = """          (lvar :keyword) A
            class << self
              (lvar :modifier)
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(1))
      test "registers an offense if no method is defined after the modifier":
        var src = """          (lvar :keyword) A
            class << self
              def method1
              end
              (lvar :modifier)
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(1))
      test """registers an offense even if a non-singleton-class method is defined""":
        var src = """          (lvar :keyword) A
            def method1
            end
            class << self
              (lvar :modifier)
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(1)))
    context("outside a class", proc (): void =
      test "doesn\'t register an offense if a method is defined":
        expectNoOffenses("""          class << A
            (lvar :modifier)
            define_method(:method1) do
            end
          end
""".stripIndent)
      test "registers an offense if no method is defined":
        var src = """          class << A
            (lvar :modifier)
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(1))
      test "registers an offense if no method is defined after the modifier":
        var src = """          class << A
            def method1
            end
            (lvar :modifier)
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(1))))
  sharedExamples("method defined using class_eval", proc (modifier: string): void =
    test "doesn\'t register an offense if a method is defined":
      expectNoOffenses("""        A.class_eval do
          (lvar :modifier)
          define_method(:method1) do
          end
        end
""".stripIndent)
    test "registers an offense if no method is defined":
      var src = """        A.class_eval do
          (lvar :modifier)
        end
""".stripIndent
      inspectSource(src)
      expect(cop().offenses.size).to(eq(1))
    context("inside a class", proc (): void =
      test """registers an offense when a modifier is ouside the block and a method is defined only inside the block""":
        var src = """          class A
            (lvar :modifier)
            A.class_eval do
              def method1
              end
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(1))
      test """registers two offenses when a modifier is inside and outside the  block and no method is defined""":
        var src = """          class A
            (lvar :modifier)
            A.class_eval do
              (lvar :modifier)
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(2))))
  sharedExamples("def in new block", proc (klass: string; modifier: string): void =
    test """doesn't register an offense if a method is defined in (lvar :klass).new""":
      expectNoOffenses("""        (lvar :klass).new do
          (lvar :modifier)
          def foo
          end
        end
""".stripIndent)
    test """registers an offense if no method is defined in (lvar :klass).new""":
      var src = """        (lvar :klass).new do
          (lvar :modifier)
        end
""".stripIndent
      inspectSource(src)
      expect(cop().offenses.size).to(eq(1)))
  sharedExamples("method defined using instance_eval", proc (modifier: string): void =
    test "doesn\'t register an offense if a method is defined":
      expectNoOffenses("""        A.instance_eval do
          (lvar :modifier)
          define_method(:method1) do
          end
        end
""".stripIndent)
    test "registers an offense if no method is defined":
      var src = """        A.instance_eval do
          (lvar :modifier)
        end
""".stripIndent
      inspectSource(src)
      expect(cop().offenses.size).to(eq(1))
    context("inside a class", proc (): void =
      test """registers an offense when a modifier is ouside the block and a method is defined only inside the block""":
        var src = """          class A
            (lvar :modifier)
            self.instance_eval do
              def method1
              end
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(1))
      test """registers two offenses when a modifier is inside and outside the  and no method is defined""":
        var src = """          class A
            (lvar :modifier)
            self.instance_eval do
              (lvar :modifier)
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(2))))
  sharedExamples("nested modules", proc (keyword: string; modifier: string): void =
    test """doesn't register an offense for nested (lvar :keyword)s""":
      expectNoOffenses("""        (lvar :keyword) A
          (lvar :modifier)
          def method1
          end
          (lvar :keyword) B
            def method2
            end
            (lvar :modifier)
            def method3
            end
          end
        end
""".stripIndent)
    context("unused modifiers", proc (): void =
      test """registers an offense with a nested (lvar :keyword)""":
        var src = """          (lvar :keyword) A
            (lvar :modifier)
            (lvar :keyword) B
              (lvar :modifier)
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(2))
      test """registers an offense when outside a nested (lvar :keyword)""":
        var src = """          (lvar :keyword) A
            (lvar :modifier)
            (lvar :keyword) B
              def method1
              end
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(1))
      test """registers an offense when inside a nested (lvar :keyword)""":
        var src = """          (lvar :keyword) A
            (lvar :keyword) B
              (lvar :modifier)
            end
          end
""".stripIndent
        inspectSource(src)
        expect(cop().offenses.size).to(eq(1))))
  for modifier in @["protected", "private"]:
    itBehavesLike("method defined using class_eval", modifier)
    itBehavesLike("method defined using instance_eval", modifier)
  for klass in @["Class", "Module", "Struct"]:
    for modifier in @["protected", "private"]:
      itBehavesLike("def in new block", klass, modifier)
  for keyword in @["module", "class"]:
    itBehavesLike("at the top of the body", keyword)
    itBehavesLike("non-repeated visibility modifiers", keyword)
    itBehavesLike("unused visibility modifiers", keyword)
    for modifier in @["public", "protected", "private"]:
      itBehavesLike("repeated visibility modifiers", keyword, modifier)
      itBehavesLike("at the end of the body", keyword, modifier)
      itBehavesLike("nested in a begin..end block", keyword, modifier)
      if modifier == "public":
        continue
      itBehavesLike("conditionally defined method", keyword, modifier)
      itBehavesLike("methods defined in an iteration", keyword, modifier)
      itBehavesLike("method defined with define_method", keyword, modifier)
      itBehavesLike("method defined on a singleton class", keyword, modifier)
      itBehavesLike("nested modules", keyword, modifier)
