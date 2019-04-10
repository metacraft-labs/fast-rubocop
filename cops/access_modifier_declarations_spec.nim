
import
  tables

import
  access_modifier_declarations, test_tools

RSpec.describe(AccessModifierDeclarations, "config", proc (): void =
  var cop = ()
  context("when `group` is configured", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "group"}.newTable())
    for accessModifier in @["private", "protected", "public"]:
      test """offends when (lvar :access_modifier) is inlined with a method""":
        expectOffense("""          class Test
            (lvar :access_modifier) def foo; end
            (send
  (str "^") :*
  (send
    (lvar :access_modifier) :length)) `(lvar :access_modifier)` should not be inlined in method definitions.
          end
""".stripIndent)
      test """offends when (lvar :access_modifier) is inlined with a symbol""":
        expectOffense("""          class Test
            (lvar :access_modifier) :foo
            (send
  (str "^") :*
  (send
    (lvar :access_modifier) :length)) `(lvar :access_modifier)` should not be inlined in method definitions.

            def foo; end
          end
""".stripIndent)
      test """does not offend when (lvar :access_modifier) is not inlined""":
        expectNoOffenses("""          class Test
            (lvar :access_modifier)
          end
""".stripIndent)
      test """(str "does not offend when ")has a comment""":
        expectNoOffenses("""          class Test
            (lvar :access_modifier) # hey
          end
""".stripIndent))
  context("when `inline` is configured", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "inline"}.newTable())
    for accessModifier in @["private", "protected", "public"]:
      test """offends when (lvar :access_modifier) is not inlined""":
        expectOffense("""          class Test
            (lvar :access_modifier)
            (send
  (str "^") :*
  (send
    (lvar :access_modifier) :length)) `(lvar :access_modifier)` should be inlined in method definitions.
          end
""".stripIndent)
      test """offends when (lvar :access_modifier) is not inlined and has a comment""":
        expectOffense("""          class Test
            (lvar :access_modifier) # hey
            (send
  (str "^") :*
  (send
    (lvar :access_modifier) :length)) `(lvar :access_modifier)` should be inlined in method definitions.
          end
""".stripIndent)
      test """does not offend when (lvar :access_modifier) is inlined with a method""":
        expectNoOffenses("""          class Test
            (lvar :access_modifier) def foo; end
          end
""".stripIndent)
      test """does not offend when (lvar :access_modifier) is inlined with a symbol""":
        expectNoOffenses("""          class Test
            (lvar :access_modifier) :foo

            def foo; end
          end
""".stripIndent)))
