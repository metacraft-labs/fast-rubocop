
import
  multiline_block_chain, test_tools

suite "MultilineBlockChain":
  var cop = MultilineBlockChain()
  context("with multi-line block chaining", proc (): void =
    test "registers an offense for a simple case":
      expectOffense("""        a do
          b
        end.c do
        ^^^^^ Avoid multi-line chains of blocks.
          d
        end
""".stripIndent)
    test "registers an offense for a slightly more complicated case":
      expectOffense("""        a do
          b
        end.c1.c2 do
        ^^^^^^^^^ Avoid multi-line chains of blocks.
          d
        end
""".stripIndent)
    test "registers two offenses for a chain of three blocks":
      expectOffense("""        a do
          b
        end.c do
        ^^^^^ Avoid multi-line chains of blocks.
          d
        end.e do
        ^^^^^ Avoid multi-line chains of blocks.
          f
        end
""".stripIndent)
    test """registers an offense for a chain where the second block is single-line""":
      expectOffense("""        Thread.list.find_all { |t|
          t.alive?
        }.map { |thread| thread.object_id }
        ^^^^^ Avoid multi-line chains of blocks.
""".stripIndent)
    test "accepts a chain where the first block is single-line":
      expectNoOffenses("""        Thread.list.find_all { |t| t.alive? }.map { |t|
          t.object_id
        }
""".stripIndent))
  test "accepts a chain of blocks spanning one line":
    expectNoOffenses("""      a { b }.c { d }
      w do x end.y do z end
""".stripIndent)
  test "accepts a multi-line block chained with calls on one line":
    expectNoOffenses("""      a do
        b
      end.c.d
""".stripIndent)
  test "accepts a chain of calls followed by a multi-line block":
    expectNoOffenses("""      a1.a2.a3 do
        b
      end
""".stripIndent)
