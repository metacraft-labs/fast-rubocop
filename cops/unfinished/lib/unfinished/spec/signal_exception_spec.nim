
import
  signal_exception, test_tools

RSpec.describe(SignalException, "config", proc (): void =
  var cop = ()
  context("when enforced style is `semantic`", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "semantic"}.newTable())
    test "registers an offense for raise in begin section":
      expectOffense("""        begin
          raise
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
""".stripIndent)
    test "registers an offense for raise in def body":
      expectOffense("""        def test
          raise
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
""".stripIndent)
    test "registers an offense for fail in rescue section":
      expectOffense("""        begin
          fail
        rescue Exception
          fail
          ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
""".stripIndent)
    test "accepts raise in rescue section":
      expectNoOffenses("""        begin
          fail
        rescue Exception
          raise RuntimeError
        end
""".stripIndent)
    test "accepts raise in def with multiple rescues":
      expectNoOffenses("""        def test
          fail
        rescue StandardError
          # handle error
        rescue Exception
          raise
        end
""".stripIndent)
    test "registers an offense for fail in def rescue section":
      expectOffense("""        def test
          fail
        rescue Exception
          fail
          ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
""".stripIndent)
    test "registers an offense for fail in second rescue":
      expectOffense("""        def test
          fail
        rescue StandardError
          # handle error
        rescue Exception
          fail
          ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
""".stripIndent)
    test "registers only offense for one raise that should be fail":
      expectOffense("""        map do
          raise 'I'
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        end.flatten.compact
""".stripIndent)
    test "accepts raise in def rescue section":
      expectNoOffenses("""        def test
          fail
        rescue Exception
          raise
        end
""".stripIndent)
    test "accepts `raise` and `fail` with explicit receiver":
      expectNoOffenses("""        def test
          test.raise
        rescue Exception
          test.fail
        end
""".stripIndent)
    test """registers an offense for `raise` and `fail` with `Kernel` as explicit receiver""":
      expectOffense("""        def test
          Kernel.raise
                 ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        rescue Exception
          Kernel.fail
                 ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
        end
""".stripIndent)
    test "registers an offense for raise not in a begin/rescue/end":
      expectOffense("""        case cop_config['EnforcedStyle']
        when 'single_quotes' then true
        when 'double_quotes' then false
        else raise 'Unknown StringLiterals style'
             ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        end
""".stripIndent)
    test "registers one offense for each raise":
      expectOffense("""        cop.stub(:on_def) { raise RuntimeError }
                            ^^^^^ Use `fail` instead of `raise` to signal exceptions.
        cop.stub(:on_def) { raise RuntimeError }
                            ^^^^^ Use `fail` instead of `raise` to signal exceptions.
""".stripIndent)
    test "is not confused by nested begin/rescue":
      expectOffense("""        begin
          raise
          ^^^^^ Use `fail` instead of `raise` to signal exceptions.
          begin
            raise
            ^^^^^ Use `fail` instead of `raise` to signal exceptions.
          rescue
            fail
            ^^^^ Use `raise` instead of `fail` to rethrow exceptions.
          end
        rescue Exception
          #do nothing
        end
""".stripIndent)
    test "auto-corrects raise to fail when appropriate":
      var newSource = autocorrectSource("""        begin
          raise
        rescue Exception
          raise
        end
""".stripIndent)
      expect(newSource).to(eq("""        begin
          fail
        rescue Exception
          raise
        end
""".stripIndent))
    test "auto-corrects fail to raise when appropriate":
      var newSource = autocorrectSource("""        begin
          fail
        rescue Exception
          fail
        end
""".stripIndent)
      expect(newSource).to(eq("""        begin
          fail
        rescue Exception
          raise
        end
""".stripIndent)))
  context("when enforced style is `raise`", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "only_raise"}.newTable())
    test "registers an offense for fail in begin section":
      expectOffense("""        begin
          fail
          ^^^^ Always use `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
""".stripIndent)
    test "registers an offense for fail in def body":
      expectOffense("""        def test
          fail
          ^^^^ Always use `raise` to signal exceptions.
        rescue Exception
          #do nothing
        end
""".stripIndent)
    test "registers an offense for fail in rescue section":
      expectOffense("""        begin
          raise
        rescue Exception
          fail
          ^^^^ Always use `raise` to signal exceptions.
        end
""".stripIndent)
    test "accepts `fail` if a custom `fail` instance method is defined":
      expectNoOffenses("""        class A
          def fail(arg)
          end
          def other_method
            fail "message"
          end
        end
""".stripIndent)
    test "accepts `fail` if a custom `fail` singleton method is defined":
      expectNoOffenses("""        class A
          def self.fail(arg)
          end
          def self.other_method
            fail "message"
          end
        end
""".stripIndent)
    test "accepts `fail` with explicit receiver":
      expectNoOffenses("test.fail")
    test "registers an offense for `fail` with `Kernel` as explicit receiver":
      expectOffense("""        Kernel.fail
               ^^^^ Always use `raise` to signal exceptions.
""".stripIndent)
    test "auto-corrects fail to raise always":
      var newSource = autocorrectSource("""        begin
          fail
        rescue Exception
          fail
        end
""".stripIndent)
      expect(newSource).to(eq("""        begin
          raise
        rescue Exception
          raise
        end
""".stripIndent)))
  context("when enforced style is `fail`", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "only_fail"}.newTable())
    test "registers an offense for raise in begin section":
      expectOffense("""        begin
          raise
          ^^^^^ Always use `fail` to signal exceptions.
        rescue Exception
          #do nothing
        end
""".stripIndent)
    test "registers an offense for raise in def body":
      expectOffense("""        def test
          raise
          ^^^^^ Always use `fail` to signal exceptions.
        rescue Exception
          #do nothing
        end
""".stripIndent)
    test "registers an offense for raise in rescue section":
      expectOffense("""        begin
          fail
        rescue Exception
          raise
          ^^^^^ Always use `fail` to signal exceptions.
        end
""".stripIndent)
    test "accepts `raise` with explicit receiver":
      expectNoOffenses("test.raise")
    test "registers an offense for `raise` with `Kernel` as explicit receiver":
      expectOffense("""        Kernel.raise
               ^^^^^ Always use `fail` to signal exceptions.
""".stripIndent)
    test "auto-corrects raise to fail always":
      var newSource = autocorrectSource("""        begin
          raise
        rescue Exception
          raise
        end
""".stripIndent)
      expect(newSource).to(eq("""        begin
          fail
        rescue Exception
          fail
        end
""".stripIndent))))
