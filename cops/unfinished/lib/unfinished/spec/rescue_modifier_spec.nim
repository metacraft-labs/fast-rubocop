
import
  rescue_modifier, test_tools

suite "RescueModifier":
  var cop = RescueModifier()
  let("config", proc (): void =
    Config.new())
  test "registers an offense for modifier rescue":
    expectOffense("""      method rescue handle
      ^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
""".stripIndent)
  test "registers an offense for modifier rescue around parallel assignment":
    expectOffense("""      a, b = 1, 2 rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
""".stripIndent)
  test "handles more complex expression with modifier rescue":
    expectOffense("""      method1 or method2 rescue handle
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
""".stripIndent)
  test "handles modifier rescue in normal rescue":
    expectOffense("""      begin
        test rescue modifier_handle
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
      rescue
        normal_handle
      end
""".stripIndent)
  test "handles modifier rescue in a method":
    expectOffense("""      def a_method
        test rescue nil
        ^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
      end
""".stripIndent)
  test "does not register an offense for normal rescue":
    expectNoOffenses("""      begin
        test
      rescue
        handle
      end
""".stripIndent)
  test "does not register an offense for normal rescue with ensure":
    expectNoOffenses("""      begin
        test
      rescue
        handle
      ensure
        cleanup
      end
""".stripIndent)
  test "does not register an offense for nested normal rescue":
    expectNoOffenses("""      begin
        begin
          test
        rescue
          handle_inner
        end
      rescue
        handle_outer
      end
""".stripIndent)
  context("when an instance method has implicit begin", proc (): void =
    test "accepts normal rescue":
      expectNoOffenses("""        def some_method
          test
        rescue
          handle
        end
""".stripIndent)
    test "handles modifier rescue in body of implicit begin":
      expectOffense("""        def some_method
          test rescue modifier_handle
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        rescue
          normal_handle
        end
""".stripIndent))
  context("when a singleton method has implicit begin", proc (): void =
    test "accepts normal rescue":
      expectNoOffenses("""        def self.some_method
          test
        rescue
          handle
        end
""".stripIndent)
    test "handles modifier rescue in body of implicit begin":
      expectOffense("""        def self.some_method
          test rescue modifier_handle
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `rescue` in its modifier form.
        rescue
          normal_handle
        end
""".stripIndent))
  context("autocorrect", proc (): void =
    test "corrects basic rescue modifier":
      var newSource = autocorrectSource("        foo rescue bar\n".stripIndent)
      expect(newSource).to(eq("""        begin
          foo
        rescue
          bar
        end
""".stripIndent))
    test "corrects complex rescue modifier":
      var newSource = autocorrectSource("        foo || bar rescue bar\n".stripIndent)
      expect(newSource).to(eq("""        begin
          foo || bar
        rescue
          bar
        end
""".stripIndent))
    test "corrects rescue modifier nested inside of def":
      var
        source = """        def foo
          test rescue modifier_handle
        end
""".stripIndent
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("""        def foo
          begin
            test
          rescue
            modifier_handle
          end
        end
""".stripIndent))
    test "corrects nested rescue modifier":
      var
        source = """        begin
          test rescue modifier_handle
        rescue
          normal_handle
        end
""".stripIndent
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("""        begin
          begin
            test
          rescue
            modifier_handle
          end
        rescue
          normal_handle
        end
""".stripIndent))
    test "corrects doubled rescue modifiers":
      var newSource = autocorrectSourceWithLoop(
          "        blah rescue 1 rescue 2\n".stripIndent)
      expect(newSource).to(eq("""        begin
          begin
            blah
          rescue
            1
          end
        rescue
          2
        end
""".stripIndent)))
  describe("excluded file", proc (): void =
    var cop = RescueModifier()
    let("config", proc (): void =
      Config.new())
    test "processes excluded files with issue":
      expectNoOffenses("foo rescue bar"))
