
import
  non_local_exit_from_iterator, test_tools

suite "NonLocalExitFromIterator":
  var cop = NonLocalExitFromIterator()
  context("inspection", proc (): void =
    before(proc (): void =
      inspectSource(source()))
    let("message", proc (): void =
      """Non-local exit from iterator, without return value. `next`, `break`, `Array#find`, `Array#any?`, etc. is preferred.""")
    sharedExamplesFor("offense detector", proc (): void =
      test "registers an offense":
        expect(cop().offenses.size).to(eq(1))
        expect(cop().offenses[0].message()).to(eq(message()))
        expect(cop().offenses[0].severity.name).to(eq("warning"))
        expect(cop().highlights).to(eq(@["return"])))
    context("when block is followed by method chain", proc (): void =
      context("and has single argument", proc (): void =
        let("source", proc (): void =
          """          items.each do |item|
            return if item.stock == 0
            item.update!(foobar: true)
          end
""")
        itBehavesLike("offense detector")
        it(proc (): void =
          expect(cop().offenses[0].line).to(eq(2))))
      context("and has multiple arguments", proc (): void =
        let("source", proc (): void =
          """          items.each_with_index do |item, i|
            return if item.stock == 0
            item.update!(foobar: true)
          end
""")
        itBehavesLike("offense detector")
        it(proc (): void =
          expect(cop().offenses[0].line).to(eq(2))))
      context("and has no argument", proc (): void =
        let("source", proc (): void =
          """          item.with_lock do
            return if item.stock == 0
            item.update!(foobar: true)
          end
""")
        it(proc (): void =
          expect(cop().offenses.isEmpty).to(be(true)))))
    context("when block is not followed by method chain", proc (): void =
      let("source", proc (): void =
        """        transaction do
          return unless update_necessary?
          find_each do |item|
            return if item.stock == 0 # false-negative...
            item.update!(foobar: true)
          end
        end
""")
      it(proc (): void =
        expect(cop().offenses.isEmpty).to(be(true))))
    context("when block is lambda", proc (): void =
      let("source", proc (): void =
        """        items.each(lambda do |item|
          return if item.stock == 0
          item.update!(foobar: true)
        end)
        items.each -> (item) {
          return if item.stock == 0
          item.update!(foobar: true)
        }
""")
      it(proc (): void =
        expect(cop().offenses.isEmpty).to(be(true))))
    context("when lambda is inside of block followed by method chain", proc (): void =
      let("source", proc (): void =
        """        RSpec.configure do |config|
          # some configuration

          if Gem.loaded_specs["paper_trail"].version < Gem::Version.new("4.0.0")
            current_behavior = ActiveSupport::Deprecation.behavior
            ActiveSupport::Deprecation.behavior = lambda do |message, callstack|
              return if message =~ /foobar/
              Array.wrap(current_behavior).each do |behavior|
                behavior.call(message, callstack)
              end
            end

            # more configuration
          end
        end
""")
      it(proc (): void =
        expect(cop().offenses.isEmpty).to(be(true))))
    context("when block in middle of nest is followed by method chain", proc (): void =
      let("source", proc (): void =
        """        transaction do
          return unless update_necessary?
          items.each do |item|
            return if item.nil?
            item.with_lock do
              return if item.stock == 0
              item.very_complicated_update_operation!
            end
          end
        end
""")
      test "registers offenses":
        expect(cop().offenses.size).to(eq(2))
        expect(cop().offenses[0].message()).to(eq(message()))
        expect(cop().offenses[0].severity.name).to(eq("warning"))
        expect(cop().offenses[0].line).to(eq(4))
        expect(cop().offenses[1].message()).to(eq(message()))
        expect(cop().offenses[1].severity.name).to(eq("warning"))
        expect(cop().offenses[1].line).to(eq(6))
        expect(cop().highlights).to(eq(@["return", "return"])))
    context("when return with value", proc (): void =
      let("source", proc (): void =
        """        def find_first_sold_out_item(items)
          items.each do |item|
            return item if item.stock == 0
            item.foobar!
          end
        end
""")
      it(proc (): void =
        expect(cop().offenses.isEmpty).to(be(true))))
    context("when the message is define_method", proc (): void =
      let("source", proc (): void =
        """        [:method_one, :method_two].each do |method_name|
          define_method(method_name) do
            return if predicate?
          end
        end
""")
      it(proc (): void =
        expect(cop().offenses.isEmpty).to(be(true))))
    context("when the message is define_singleton_method", proc (): void =
      let("source", proc (): void =
        """        str = 'foo'
        str.define_singleton_method :bar do |baz|
          return unless baz
          replace baz
        end
""")
      it(proc (): void =
        expect(cop().offenses.isEmpty).to(be(true))))
    context("when the return is within a nested method definition", proc (): void =
      context("with an instance method definition", proc (): void =
        let("source", proc (): void =
          """          Foo.configure do |c|
            def bar
              return if baz?
            end
          end
""")
        it(proc (): void =
          expect(cop().offenses.isEmpty).to(be(true))))
      context("with a class method definition", proc (): void =
        let("source", proc (): void =
          """          Foo.configure do |c|
            def self.bar
              return if baz?
            end
          end
""")
        it(proc (): void =
          expect(cop().offenses.isEmpty).to(be(true))))))
