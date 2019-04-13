
import
  types

import
  inline_comment, test_tools

suite "InlineComment":
  var cop = InlineComment()
  test "registers an offense for a trailing inline comment":
    expectOffense("""      two = 1 + 1 # A trailing inline comment
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid trailing inline comments.
""".stripIndent)
  test "does not register an offense for special rubocop inline comments":
    expectNoOffenses("      two = 1 + 1 # rubocop:disable Layout/ExtraSpacing\n".stripIndent)
  test "does not register an offense for a standalone comment":
    expectNoOffenses("# A standalone comment")
