
import
  types

import
  begin_block, test_tools

RSpec.describe(BeginBlock, proc () =
  subject("cop", proc (): bool =
    describedClass.new)
  it("reports an offense for a BEGIN block", proc () =
    expectOffense("""      BEGIN { test }
      ^^^^^ Avoid the use of `BEGIN` blocks.
""".stripIndent)))
