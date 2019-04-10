
import
  block_nesting, test_tools

RSpec.describe(BlockNesting, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"Max": 2}.newTable())
  test "accepts `Max` levels of nesting":
    expectNoOffenses("""      if a
        if b
          puts b
        end
      end
""".stripIndent)
  context("`Max + 1` levels of `if` nesting", proc (): void =
    test "registers an offense":
      expectOffense("""        if a
          if b
            if cinspect_source
            ^^^^^^^^^^^^^^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
        end
""".stripIndent)
      expect(cop().configToAllowOffenses["exclude_limit"]).to(eq()))
  context("`Max + 2` levels of `if` nesting", proc (): void =
    test "registers an offense":
      expectOffense("""        if a
          if b
            if c
            ^^^^ Avoid more than 2 levels of block nesting.
              if d
                puts d
              end
            end
          end
        end
""".stripIndent)
      expect(cop().configToAllowOffenses["exclude_limit"]).to(eq()))
  context("Multiple nested `ifs` at same level", proc (): void =
    test "registers 2 offenses":
      expectOffense("""        if a
          if b
            if c
            ^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
          if d
            if e
            ^^^^ Avoid more than 2 levels of block nesting.
              puts e
            end
          end
        end
""".stripIndent)
      expect(cop().configToAllowOffenses["exclude_limit"]).to(eq()))
  context("nested `case`", proc (): void =
    test "registers an offense":
      expectOffense("""        if a
          if b
            case c
            ^^^^^^ Avoid more than 2 levels of block nesting.
              when C
                puts C
            end
          end
        end
""".stripIndent))
  context("nested `while`", proc (): void =
    test "registers an offense":
      expectOffense("""        if a
          if b
            while c
            ^^^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
        end
""".stripIndent))
  context("nested modifier `while`", proc (): void =
    test "registers an offense":
      expectOffense("""        if a
          if b
            begin
            ^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end while c
          end
        end
""".stripIndent))
  context("nested `until`", proc (): void =
    test "registers an offense":
      expectOffense("""        if a
          if b
            until c
            ^^^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
        end
""".stripIndent))
  context("nested modifier `until`", proc (): void =
    test "registers an offense":
      expectOffense("""        if a
          if b
            begin
            ^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end until c
          end
        end
""".stripIndent))
  context("nested `for`", proc (): void =
    test "registers an offense":
      expectOffense("""        if a
          if b
            for c in [1,2] do
            ^^^^^^^^^^^^^^^^^ Avoid more than 2 levels of block nesting.
              puts c
            end
          end
        end
""".stripIndent))
  context("nested `rescue`", proc (): void =
    test "registers an offense":
      expectOffense("""        if a
          if b
            begin
              puts c
            rescue
            ^^^^^^ Avoid more than 2 levels of block nesting.
              puts x
            end
          end
        end
""".stripIndent))
  test "accepts if/elsif":
    expectNoOffenses("""      if a
      elsif b
      elsif c
      elsif d
      end
""".stripIndent)
  context("when CountBlocks is false", proc (): void =
    let("cop_config", proc (): void =
      {"Max": 2, "CountBlocks": false}.newTable())
    test "accepts nested multiline blocks":
      expectNoOffenses("""        if a
          if b
            [1, 2].each do |c|
              puts c
            end
          end
        end
""".stripIndent)
    test "accepts nested inline blocks":
      expectNoOffenses("""        if a
          if b
            [1, 2].each { |c| puts c }
          end
        end
""".stripIndent))
  context("when CountBlocks is true", proc (): void =
    let("cop_config", proc (): void =
      {"Max": 2, "CountBlocks": true}.newTable())
    context("nested multiline block", proc (): void =
      test "registers an offense":
        expectOffense("""          if a
            if b
              [1, 2].each do |c|
              ^^^^^^^^^^^^^^^^^^ Avoid more than 2 levels of block nesting.
                puts c
              end
            end
          end
""".stripIndent))
    context("nested inline block", proc (): void =
      test "registers an offense":
        expectOffense("""          if a
            if b
              [1, 2].each { |c| puts c }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid more than 2 levels of block nesting.
            end
          end
""".stripIndent))))
