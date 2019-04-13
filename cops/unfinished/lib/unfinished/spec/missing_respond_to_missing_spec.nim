
import
  missing_respond_to_missing, test_tools

suite "MissingRespondToMissing":
  var cop = MissingRespondToMissing()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when respond_to_missing? is not implemented":
    expectOffense("""      class Test
        def method_missing
        ^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
""".stripIndent)
  test """registers an offense when method_missing is implemented as a class methods""":
    expectOffense("""      class Test
        def self.method_missing
        ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
""".stripIndent)
  test """allows method_missing and respond_to_missing? implemented as instance methods""":
    expectNoOffenses("""      class Test
        def respond_to_missing?
        end

        def method_missing
        end
      end
""".stripIndent)
  test """allows method_missing and respond_to_missing? implemented as class methods""":
    expectNoOffenses("""      class Test
        def self.respond_to_missing?
        end

        def self.method_missing
        end
      end
""".stripIndent)
  test """registers an offense respond_to_missing? is implemented as an instance method and method_missing is implemented as a class method""":
    expectOffense("""      class Test
        def self.method_missing
        ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end

        def respond_to_missing?
        end
      end
""".stripIndent)
  test """registers an offense respond_to_missing? is implemented as a class method and method_missing is implemented as an instance method""":
    expectOffense("""      class Test
        def self.respond_to_missing?
        end

        def method_missing
        ^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
""".stripIndent)
