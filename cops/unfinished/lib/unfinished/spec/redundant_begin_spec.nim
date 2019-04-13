
import
  redundant_begin, test_tools

RSpec.describe(RedundantBegin, "config", proc (): void =
  var cop = ()
  test "reports an offense for single line def with redundant begin block":
    expectOffense("""      def func; begin; x; y; rescue; z end; end
                ^^^^^ Redundant `begin` block detected.
""".stripIndent)
  test "reports an offense for def with redundant begin block":
    expectOffense("""      def func
        begin
        ^^^^^ Redundant `begin` block detected.
          ala
        rescue => e
          bala
        end
      end
""".stripIndent)
  test "reports an offense for defs with redundant begin block":
    expectOffense("""      def Test.func
        begin
        ^^^^^ Redundant `begin` block detected.
          ala
        rescue => e
          bala
        end
      end
""".stripIndent)
  test "accepts a def with required begin block":
    expectNoOffenses("""      def func
        begin
          ala
        rescue => e
          bala
        end
        something
      end
""".stripIndent)
  test "accepts a defs with required begin block":
    expectNoOffenses("""      def Test.func
        begin
          ala
        rescue => e
          bala
        end
        something
      end
""".stripIndent)
  test "accepts a def with a begin block after a statement":
    expectNoOffenses("""      def Test.func
        something
        begin
          ala
        rescue => e
          bala
        end
      end
""".stripIndent)
  test """auto-corrects source separated by newlines by removing redundant begin blocks""":
    var
      src = """      def func
        begin
          foo
          bar
        rescue
          baz
        end
      end
""".stripIndent
      resultSrc = """      def func
        
          foo
          bar
        rescue
          baz
        
      end
""".stripIndent
      newSource = autocorrectSource(src)
    expect(newSource).to(eq(resultSrc))
  test """auto-corrects source separated by semicolons by removing redundant begin blocks""":
    var
      src = "  def func; begin; x; y; rescue; z end end"
      resultSrc = "  def func; ; x; y; rescue; z  end"
      newSource = autocorrectSource(src)
    expect(newSource).to(eq(resultSrc))
  test "doesn\'t modify spacing when auto-correcting":
    var
      src = """      def method
        begin
          BlockA do |strategy|
            foo
          end

          BlockB do |portfolio|
            foo
          end

        rescue => e # some problem
          bar
        end
      end
""".stripIndent
      resultSrc = """      def method
        
          BlockA do |strategy|
            foo
          end

          BlockB do |portfolio|
            foo
          end

        rescue => e # some problem
          bar
        
      end
""".stripIndent
      newSource = autocorrectSource(src)
    expect(newSource).to(eq(resultSrc))
  test "auto-corrects when there are trailing comments":
    var
      src = """      def method
        begin # comment 1
          do_some_stuff
        rescue # comment 2
        end # comment 3
      end
""".stripIndent
      resultSrc = """      def method
         # comment 1
          do_some_stuff
        rescue # comment 2
         # comment 3
      end
""".stripIndent
      newSource = autocorrectSource(src)
    expect(newSource).to(eq(resultSrc))
  context("< Ruby 2.5", "ruby24", proc (): void =
    test "accepts a do-end block with a begin-end":
      expectNoOffenses("""        do_something do
          begin
            foo
          rescue => e
            bar
          end
        end
""".stripIndent))
  context(">= ruby 2.5", "ruby25", proc (): void =
    test "registers an offense for a do-end block with redundant begin-end":
      expectOffense("""        do_something do
          begin
          ^^^^^ Redundant `begin` block detected.
            foo
          rescue => e
            bar
          end
        end
""".stripIndent)
    test "accepts a {} block with a begin-end":
      expectNoOffenses("""        do_something {
          begin
            foo
          rescue => e
            bar
          end
        }
""".stripIndent)
    test "accepts a block with a begin block after a statement":
      expectNoOffenses("""        do_something do
          something
          begin
            ala
          rescue => e
            bala
          end
        end
""".stripIndent)
    test "accepts a stabby lambda with a begin-end":
      expectNoOffenses("""        -> do
          begin
            foo
          rescue => e
            bar
          end
        end
""".stripIndent)
    test "accepts super with block":
      expectNoOffenses("""        def a_method
          super do |arg|
            foo
          rescue => e
            bar
          end
        end
""".stripIndent)))
