
import
  ambiguous_block_association, test_tools

suite "AmbiguousBlockAssociation":
  var cop = AmbiguousBlockAssociation()
  sharedExamples("accepts", proc (code: string): void =
    test "does not register an offense":
      expectNoOffenses(code))
  itBehavesLike("accepts", "foo == bar { baz a }")
  itBehavesLike("accepts", "foo ->(a) { bar a }")
  itBehavesLike("accepts", "some_method(a) { |el| puts el }")
  itBehavesLike("accepts", "some_method(a) do;puts a;end")
  itBehavesLike("accepts", "some_method a do;puts \"dev\";end")
  itBehavesLike("accepts", "some_method a do |e|;puts e;end")
  itBehavesLike("accepts", "Foo.bar(a) { |el| puts el }")
  itBehavesLike("accepts", "env ENV.fetch(\"ENV\") { \"dev\" }")
  itBehavesLike("accepts", "env(ENV.fetch(\"ENV\") { \"dev\" })")
  itBehavesLike("accepts", "{ f: \"b\"}.fetch(:a) do |e|;puts e;end")
  itBehavesLike("accepts", "Hash[some_method(a) { |el| el }]")
  itBehavesLike("accepts", "foo = lambda do |diagnostic|;end")
  itBehavesLike("accepts", "Proc.new { puts \"proc\" }")
  itBehavesLike("accepts", "expect { order.save }.to(change { orders.size })")
  itBehavesLike("accepts", "scope :active, -> { where(status: \"active\") }")
  itBehavesLike("accepts", "assert_equal posts.find { |p| p.title == \"Foo\" }, results.first")
  itBehavesLike("accepts", "assert_equal(posts.find { |p| p.title == \"Foo\" }, results.first)")
  itBehavesLike("accepts", "assert_equal(results.first, posts.find { |p| p.title == \"Foo\" })")
  itBehavesLike("accepts",
                "allow(cop).to receive(:on_int) { raise RuntimeError }")
  itBehavesLike("accepts",
                "allow(cop).to(receive(:on_int) { raise RuntimeError })")
  context("without parentheses", proc (): void =
    context("without receiver", proc (): void =
      test "registers an offense":
        expectOffense("""          some_method a { |el| puts el }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| puts el }` to make sure that the block will be associated with the `a` method call.
""".stripIndent))
    context("with receiver", proc (): void =
      test "registers an offense":
        expectOffense("""          Foo.some_method a { |el| puts el }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| puts el }` to make sure that the block will be associated with the `a` method call.
""".stripIndent)
      context("when using safe navigation operator", "ruby23", proc (): void =
        test "registers an offense":
          expectOffense("""            Foo&.some_method a { |el| puts el }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| puts el }` to make sure that the block will be associated with the `a` method call.
""".stripIndent)))
    context("rspec expect {}.to change {}", proc (): void =
      test "registers an offense":
        expectOffense("""          expect { order.expire }.to change { order.events }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `change { order.events }` to make sure that the block will be associated with the `change` method call.
""".stripIndent))
    context("as a hash key", proc (): void =
      test "registers an offense":
        expectOffense("""          Hash[some_method a { |el| el }]
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| el }` to make sure that the block will be associated with the `a` method call.
""".stripIndent))
    context("with assignment", proc (): void =
      test "registers an offense":
        expectOffense("""          foo = some_method a { |el| puts el }
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Parenthesize the param `a { |el| puts el }` to make sure that the block will be associated with the `a` method call.
""".stripIndent)))
