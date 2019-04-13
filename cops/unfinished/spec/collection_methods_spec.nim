
import
  tables

import
  collection_methods, test_tools

RSpec.describe(CollectionMethods, "config", proc (): void =
  var
    copConfig = {"PreferredMethods": {"collect": "map", "inject": "reduce",
                                   "detect": "find", "find_all": "select"}.newTable()}.newTable()
    cop = ()
  let("cop_config", proc (): void =
    copConfig)
  for method, preferredMethod in copConfig["PreferredMethods"]:
    test """registers an offense for (lvar :method) with block""":
      inspectSource("""[1, 2, 3].(lvar :method) { |e| e + 1 }""")
      expect(cop().offenses.size).to(eq(1))
      expect(cop().messages).to(eq(@["""Prefer `(lvar :preferred_method)` over `(lvar :method)`."""]))
    test """registers an offense for (lvar :method) with proc param""":
      inspectSource("""[1, 2, 3].(lvar :method)(&:test)""")
      expect(cop().offenses.size).to(eq(1))
      expect(cop().messages).to(eq(@["""Prefer `(lvar :preferred_method)` over `(lvar :method)`."""]))
    test """accepts (lvar :method) with more than 1 param""":
      expectNoOffenses("""        [1, 2, 3].(lvar :method)(other, &:test)
""".stripIndent)
    test """accepts (lvar :method) without a block""":
      expectNoOffenses("""        [1, 2, 3].(lvar :method)
""".stripIndent)
    test "auto-corrects to preferred method":
      var newSource = autocorrectSource("some.collect(&:test)")
      expect(newSource).to(eq("some.map(&:test)")))
