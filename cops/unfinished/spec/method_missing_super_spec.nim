
import
  method_missing_super, test_tools

suite "MethodMissingSuper":
  var cop = MethodMissingSuper()
  describe("method_missing defined as an instance method", proc (): void =
    test "registers an offense when super is not called.":
      expectOffense("""        class Test
          def method_missing
          ^^^^^^^^^^^^^^^^^^ When using `method_missing`, fall back on `super`.
          end
        end
""".stripIndent)
    test "allows method_missing when super is called":
      expectNoOffenses("""        class Test
          def method_missing
            super
          end
        end
"""))
  describe("method_missing defined as a class method", proc (): void =
    test "registers an offense when super is not called.":
      expectOffense("""        class Test
          def self.method_missing
          ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, fall back on `super`.
          end
        end
""".stripIndent)
    test "allows method_missing when super is called":
      expectNoOffenses("""        class Test
          def self.method_missing
            super
          end
        end
"""))
