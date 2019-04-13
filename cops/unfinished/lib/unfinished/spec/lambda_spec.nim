
import
  lambda, test_tools

RSpec.describe(Lambda, "config", proc (): void =
  var cop = ()
  sharedExamples("registers an offense", proc (message: string): void =
    test "registers an offense":
      inspectSource(source())
      expect(cop().offenses.size).to(eq(1))
      expect(cop().messages).to(eq(@[message])))
  sharedExamples("auto-correct", proc (expected: string): void =
    test "auto-corrects":
      var newSource = autocorrectSource(source())
      expect(newSource).to(eq(expected)))
  context("with enforced `lambda` style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "lambda"}.newTable())
    context("with a single line lambda literal", proc (): void =
      context("with arguments", proc (): void =
        let("source", proc (): void =
          "f = ->(x) { x }")
        itBehavesLike("registers an offense",
                      "Use the `lambda` method for all lambdas.")
        itBehavesLike("auto-correct", "f = lambda { |x| x }"))
      context("without arguments", proc (): void =
        let("source", proc (): void =
          "f = -> { x }")
        itBehavesLike("registers an offense",
                      "Use the `lambda` method for all lambdas.")
        itBehavesLike("auto-correct", "f = lambda { x }")))
    context("with a multiline lambda literal", proc (): void =
      context("with arguments", proc (): void =
        let("source", proc (): void =
          """            f = ->(x) do
              x
            end
""".stripIndent)
        itBehavesLike("registers an offense",
                      "Use the `lambda` method for all lambdas.")
        itBehavesLike("auto-correct", """          f = lambda do |x|
            x
          end
""".stripIndent))
      context("without arguments", proc (): void =
        let("source", proc (): void =
          """            f = -> do
              x
            end
""".stripIndent)
        itBehavesLike("registers an offense",
                      "Use the `lambda` method for all lambdas.")
        itBehavesLike("auto-correct", """          f = lambda do
            x
          end
""".stripIndent))))
  context("with enforced `literal` style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "literal"}.newTable())
    context("with a single line lambda method call", proc (): void =
      context("with arguments", proc (): void =
        let("source", proc (): void =
          "f = lambda { |x| x }")
        itBehavesLike("registers an offense", """Use the `-> { ... }` lambda literal syntax for all lambdas.""")
        itBehavesLike("auto-correct", "f = ->(x) { x }"))
      context("without arguments", proc (): void =
        let("source", proc (): void =
          "f = lambda { x }")
        itBehavesLike("registers an offense", """Use the `-> { ... }` lambda literal syntax for all lambdas.""")
        itBehavesLike("auto-correct", "f = -> { x }")))
    context("with a multiline lambda method call", proc (): void =
      context("with arguments", proc (): void =
        let("source", proc (): void =
          """            f = lambda do |x|
              x
            end
""".stripIndent)
        itBehavesLike("registers an offense", """Use the `-> { ... }` lambda literal syntax for all lambdas.""")
        itBehavesLike("auto-correct", """          f = ->(x) do
            x
          end
""".stripIndent))
      context("without arguments", proc (): void =
        let("source", proc (): void =
          """            f = lambda do
              x
            end
""".stripIndent)
        itBehavesLike("registers an offense", """Use the `-> { ... }` lambda literal syntax for all lambdas.""")
        itBehavesLike("auto-correct", """          f = -> do
            x
          end
""".stripIndent))))
  context("with default `line_count_dependent` style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "line_count_dependent"}.newTable())
    context("with a single line lambda method call", proc (): void =
      context("with arguments", proc (): void =
        let("source", proc (): void =
          "f = lambda { |x| x }")
        itBehavesLike("registers an offense", """Use the `-> { ... }` lambda literal syntax for single line lambdas.""")
        itBehavesLike("auto-correct", "f = ->(x) { x }"))
      context("without arguments", proc (): void =
        let("source", proc (): void =
          "f = lambda { x }")
        itBehavesLike("registers an offense", """Use the `-> { ... }` lambda literal syntax for single line lambdas.""")
        itBehavesLike("auto-correct", "f = -> { x }")))
    context("with a multiline lambda method call", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          l = lambda do |x|
            x
          end
""".stripIndent))
    context("with a single line lambda literal", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          lambda = ->(x) { x }
          lambda.(1)
""".stripIndent))
    context("with a multiline lambda literal", proc (): void =
      context("with arguments", proc (): void =
        let("source", proc (): void =
          """            f = ->(x) do
              x
            end
""".stripIndent)
        itBehavesLike("registers an offense",
                      "Use the `lambda` method for multiline lambdas.")
        itBehavesLike("auto-correct", """          f = lambda do |x|
            x
          end
""".stripIndent))
      context("without arguments", proc (): void =
        let("source", proc (): void =
          """            f = -> do
              x
            end
""".stripIndent)
        itBehavesLike("registers an offense",
                      "Use the `lambda` method for multiline lambdas.")
        itBehavesLike("auto-correct", """          f = lambda do
            x
          end
""".stripIndent)))
    context("unusual lack of spacing", proc (): void =
      context("without any spacing", proc (): void =
        let("source", proc (): void =
          """            ->(x)do
              x
            end
""".stripIndent)
        itBehavesLike("auto-correct", """          lambda do |x|
            x
          end
""".stripIndent))
      context("without spacing after arguments", proc (): void =
        let("source", proc (): void =
          """            -> (x)do
              x
            end
""".stripIndent)
        itBehavesLike("auto-correct", """          lambda do |x|
            x
          end
""".stripIndent))
      context("without spacing before arguments", proc (): void =
        let("source", proc (): void =
          """            ->(x) do
              x
            end
""".stripIndent)
        itBehavesLike("auto-correct", """          lambda do |x|
            x
          end
""".stripIndent))
      context("with a multiline lambda literal", proc (): void =
        context("with empty arguments", proc (): void =
          let("source", proc (): void =
            """              ->()do
                x
              end
""".stripIndent)
          itBehavesLike("auto-correct", """            lambda do
              x
            end
""".stripIndent))
        context("with no arguments and bad spacing", proc (): void =
          let("source", proc (): void =
            """              -> ()do
                x
              end
""".stripIndent)
          itBehavesLike("auto-correct", """            lambda do
              x
            end
""".stripIndent))
        context("with no arguments and no spacing", proc (): void =
          let("source", proc (): void =
            """              ->do
                x
              end
""".stripIndent)
          itBehavesLike("auto-correct", """            lambda do
              x
            end
""".stripIndent))
        context("without parentheses", proc (): void =
          let("source", proc (): void =
            """              -> hello do
                puts hello
              end
""".stripIndent)
          itBehavesLike("registers an offense",
                        "Use the `lambda` method for multiline lambdas.")
          itBehavesLike("auto-correct", """            lambda do |hello|
              puts hello
            end
""".stripIndent))
        context("with no parentheses and bad spacing", proc (): void =
          let("source", proc (): void =
            """              ->   hello  do
                puts hello
              end
""".stripIndent)
          itBehavesLike("registers an offense",
                        "Use the `lambda` method for multiline lambdas.")
          itBehavesLike("auto-correct", """            lambda do |hello|
              puts hello
            end
""".stripIndent))
        context("with no parentheses and many args", proc (): void =
          let("source", proc (): void =
            """              ->   hello, user  do
                puts hello
              end
""".stripIndent)
          itBehavesLike("registers an offense",
                        "Use the `lambda` method for multiline lambdas.")
          itBehavesLike("auto-correct", """            lambda do |hello, user|
              puts hello
            end
""".stripIndent))))
    context("when calling a lambda method without a block", proc (): void =
      test "does not register an offense":
        expectNoOffenses("l = lambda.test"))
    context("with a multiline lambda literal as an argument", proc (): void =
      let("source", proc (): void =
        """          has_many :kittens, -> do
            where(cats: Cat.young.where_values_hash)
          end, source: cats
""".stripIndent)
      itBehavesLike("registers an offense",
                    "Use the `lambda` method for multiline lambdas.")
      itBehavesLike("auto-correct", """        has_many :kittens, lambda {
          where(cats: Cat.young.where_values_hash)
        }, source: cats
""".stripIndent))
    context("with a multiline braces lambda literal as a keyword argument", proc (): void =
      let("source", proc (): void =
        """          has_many opt: -> do
            where(cats: Cat.young.where_values_hash)
          end
""".stripIndent)
      itBehavesLike("registers an offense",
                    "Use the `lambda` method for multiline lambdas.")
      itBehavesLike("auto-correct", """        has_many opt: lambda {
          where(cats: Cat.young.where_values_hash)
        }
""".stripIndent))
    context("with a multiline do-end lambda literal as a keyword argument", proc (): void =
      let("source", proc (): void =
        """          has_many opt: -> {
            where(cats: Cat.young.where_values_hash)
          }
""".stripIndent)
      itBehavesLike("registers an offense",
                    "Use the `lambda` method for multiline lambdas.")
      itBehavesLike("auto-correct", """        has_many opt: lambda {
          where(cats: Cat.young.where_values_hash)
        }
""".stripIndent))
    context("with a multiline do-end lambda as a parenthesized kwarg", proc (): void =
      let("source", proc (): void =
        """          has_many(
            opt: -> do
              where(cats: Cat.young.where_values_hash)
            end
          )
""".stripIndent)
      itBehavesLike("registers an offense",
                    "Use the `lambda` method for multiline lambdas.")
      itBehavesLike("auto-correct", """        has_many(
          opt: lambda do
            where(cats: Cat.young.where_values_hash)
          end
        )
""".stripIndent)))
  context("when using safe navigation operator", proc (): void =
    let("ruby_version", proc (): void =
      0.0)
    test "does not break":
      expectNoOffenses("""        foo&.bar do |_|
          baz
        end
""".stripIndent)))
