
import
  types

import
  begin_block, test_tools

suite "BeginBlock":
  var cop = BeginBlock()
  test "reports an offense for a BEGIN block":
    expectOffense("""      BEGIN { test }
      ^^^^^ Avoid the use of `BEGIN` blocks.
""".stripIndent)
