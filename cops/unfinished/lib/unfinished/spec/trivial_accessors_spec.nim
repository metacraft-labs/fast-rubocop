
import
  trivial_accessors, test_tools

RSpec.describe(TrivialAccessors, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {:}.newTable())
  test "registers an offense on instance reader":
    expectOffense("""      def foo
      ^^^ Use `attr_reader` to define trivial reader methods.
        @foo
      end
""".stripIndent)
    expectCorrection("      attr_reader :foo\n".stripIndent)
  test "registers an offense on instance writer":
    expectOffense("""      def foo=(val)
      ^^^ Use `attr_writer` to define trivial writer methods.
        @foo = val
      end
""".stripIndent)
    expectCorrection("      attr_writer :foo\n".stripIndent)
  test "registers an offense on class reader":
    expectOffense("""      def self.foo
      ^^^ Use `attr_reader` to define trivial reader methods.
        @foo
      end
""".stripIndent)
    expectCorrection("""      class << self
        attr_reader :foo
      end
""".stripIndent)
  test "registers an offense on class writer":
    expectOffense("""      def self.foo(val)
      ^^^ Use `attr_writer` to define trivial writer methods.
        @foo = val
      end
""".stripIndent)
    expectNoCorrections
  test "registers an offense on reader with braces":
    expectOffense("""      def foo()
      ^^^ Use `attr_reader` to define trivial reader methods.
        @foo
      end
""".stripIndent)
    expectCorrection("      attr_reader :foo\n".stripIndent)
  test "registers an offense on writer without braces":
    expectOffense("""      def foo= val
      ^^^ Use `attr_writer` to define trivial writer methods.
        @foo = val
      end
""".stripIndent)
    expectCorrection("      attr_writer :foo\n".stripIndent)
  test "registers an offense on one-liner reader":
    expectOffense("""      def foo; @foo; end
      ^^^ Use `attr_reader` to define trivial reader methods.
""".stripIndent)
    expectCorrection("      attr_reader :foo\n".stripIndent)
  test "registers an offense on one-liner writer":
    expectOffense("""      def foo(val); @foo=val; end
      ^^^ Use `attr_writer` to define trivial writer methods.
""".stripIndent)
    expectNoCorrections
  test "registers an offense on DSL-style trivial writer":
    expectOffense("""      def foo(val)
      ^^^ Use `attr_writer` to define trivial writer methods.
        @foo = val
      end
""".stripIndent)
    expectNoCorrections
  test "registers an offense on reader with `private`":
    expectOffense("""      private def foo
              ^^^ Use `attr_reader` to define trivial reader methods.
        @foo
      end
""".stripIndent)
    expectNoCorrections
  test "accepts non-trivial reader":
    expectNoOffenses("""      def test
        some_function_call
        @test
      end
""".stripIndent)
  test "accepts non-trivial writer":
    expectNoOffenses("""      def test(val)
        some_function_call(val)
        @test = val
        log(val)
      end
""".stripIndent)
  test "accepts splats":
    expectNoOffenses("""      def splatomatic(*values)
        @splatomatic = values
      end
""".stripIndent)
  test "accepts blocks":
    expectNoOffenses("""      def something(&block)
        @b = block
      end
""".stripIndent)
  test "accepts expressions within reader":
    expectNoOffenses("""      def bar
        @bar + foo
      end
""".stripIndent)
  test "accepts expressions within writer":
    expectNoOffenses("""      def bar(val)
        @bar = val + foo
      end
""".stripIndent)
  test "accepts an initialize method looking like a writer":
    expectNoOffenses("""       def initialize(value)
         @top = value
       end
""".stripIndent)
  test "accepts reader with different ivar name":
    expectNoOffenses("""      def foo
        @fo
      end
""".stripIndent)
  test "accepts writer with different ivar name":
    expectNoOffenses("""      def foo(val)
        @fo = val
      end
""".stripIndent)
  test "accepts writer in a module":
    expectNoOffenses("""      module Foo
        def bar=(bar)
          @bar = bar
        end
      end
""".stripIndent)
  test "accepts writer nested within a module":
    expectNoOffenses("""      module Foo
        begin
          def bar=(bar)
            @bar = bar
          end
        end
      end
""".stripIndent)
  test "accepts reader nested within a module":
    expectNoOffenses("""      module Foo
        begin
          def bar
            @bar
          end
        end
      end
""".stripIndent)
  test "accepts writer nested within an instance_eval call":
    expectNoOffenses("""      something.instance_eval do
        begin
          def bar=(bar)
            @bar = bar
          end
        end
      end
""".stripIndent)
  test "accepts reader nested within an instance_eval calll":
    expectNoOffenses("""      something.instance_eval do
        begin
          def bar
            @bar
          end
        end
      end
""".stripIndent)
  test "flags a reader inside a class, inside an instance_eval call":
    expectOffense("""      something.instance_eval do
        class << @blah
          begin
            def bar
            ^^^ Use `attr_reader` to define trivial reader methods.
              @bar
            end
          end
        end
      end
""".stripIndent)
    expectCorrection("""      something.instance_eval do
        class << @blah
          begin
            attr_reader :bar
          end
        end
      end
""".stripIndent)
  context("exact name match disabled", proc (): void =
    let("cop_config", proc (): void =
      {"ExactNameMatch": false}.newTable())
    test "registers an offense when names mismatch in writer":
      expectOffense("""        def foo(val)
        ^^^ Use `attr_writer` to define trivial writer methods.
          @f = val
        end
""".stripIndent)
      expectNoCorrections
    test "registers an offense when names mismatch in reader":
      expectOffense("""        def foo
        ^^^ Use `attr_reader` to define trivial reader methods.
          @f
        end
""".stripIndent)
      expectNoCorrections)
  context("disallow predicates", proc (): void =
    let("cop_config", proc (): void =
      {"AllowPredicates": false}.newTable())
    test "does not accept predicate-like reader":
      expectOffense("""        def foo?
        ^^^ Use `attr_reader` to define trivial reader methods.
          @foo
        end
""".stripIndent)
      expectNoCorrections)
  context("allow predicates", proc (): void =
    let("cop_config", proc (): void =
      {"AllowPredicates": true}.newTable())
    test "accepts predicate-like reader":
      expectNoOffenses("""        def foo?
          @foo
        end
""".stripIndent))
  context("with whitelist", proc (): void =
    let("cop_config", proc (): void =
      {"Whitelist": @["to_foo", "bar="]}.newTable())
    test "accepts whitelisted reader":
      expectNoOffenses("""         def to_foo
           @foo
         end
""".stripIndent)
    test "accepts whitelisted writer":
      expectNoOffenses("""         def bar=(bar)
           @bar = bar
         end
""".stripIndent)
    context("with AllowPredicates: false", proc (): void =
      let("cop_config", proc (): void =
        {"AllowPredicates": false, "Whitelist": @["foo?"]}.newTable())
      test "accepts whitelisted predicate":
        expectNoOffenses("""           def foo?
             @foo
           end
""".stripIndent)))
  context("with DSL allowed", proc (): void =
    let("cop_config", proc (): void =
      {"AllowDSLWriters": true}.newTable())
    test "accepts DSL-style writer":
      expectNoOffenses("""        def foo(val)
         @foo = val
        end
""".stripIndent))
  context("ignore class methods", proc (): void =
    let("cop_config", proc (): void =
      {"IgnoreClassMethods": true}.newTable())
    test "accepts class reader":
      expectNoOffenses("""        def self.foo
          @foo
        end
""".stripIndent)
    test "accepts class writer":
      expectNoOffenses("""        def self.foo(val)
          @foo = val
        end
""".stripIndent)))
