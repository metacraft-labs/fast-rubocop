
import
  safe_navigation_consistency, test_tools

RSpec.describe(SafeNavigationConsistency, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"Whitelist": @["present?", "blank?", "try", "presence"]}.newTable())
  context("target_ruby_version >= 2.3", "ruby23", proc (): void =
    test "allows && without safe navigation":
      expectNoOffenses("        foo.bar && foo.baz\n".stripIndent)
    test "allows || without safe navigation":
      expectNoOffenses("        foo.bar || foo.baz\n".stripIndent)
    test "allows safe navigation when different variables are used":
      expectNoOffenses("        foo&.bar || foobar.baz\n".stripIndent)
    test "allows calls to methods that nil responds to":
      expectNoOffenses("        return true if a.nil? || a&.whatever?\n".stripIndent)
    test "registers an offense when using safe navigation on the left of &&":
      expectOffense("""        foo&.bar && foo.baz
        ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test "registers an offense when using safe navigation on the right of &&":
      expectOffense("""        foo.bar && foo&.baz
        ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test "registers an offense when using safe navigation on the left of ||":
      expectOffense("""        foo&.bar || foo.baz
        ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test "registers an offense when using safe navigation on the right of ||":
      expectOffense("""        foo.bar || foo&.baz
        ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test """registers an offense when there is code before or after the condition""":
      expectOffense("""        foo = nil
        foo&.bar || foo.baz
        ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
        something
""".stripIndent)
    test "registers an offense for non dot method calls":
      expectOffense("""        foo&.zero? || foo > 5
        ^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test "registers an offense for assignment":
      expectOffense("""        foo&.bar && foo.baz = 1
        ^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test """registers an offense when using safe navigation inside of separated conditions""":
      expectOffense("""        foo&.bar && foobar.baz && foo.qux
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test """registers an offense when using safe navigation in conditions on the right hand side""":
      expectOffense("""        foobar.baz && foo&.bar && foo.qux
                      ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test "registers multiple offenses":
      expectOffense("""        foobar.baz && foo&.bar && foo.qux && foo.foobar
                      ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test """registers an offense when using unsafe navigation with both && and ||""":
      expectOffense("""        foo&.bar && foo.baz || foo.qux
        ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test """registers an offense when using unsafe navigation with grouped conditions""":
      expectOffense("""        foo&.bar && (foo.baz || foo.qux)
        ^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test """registers an offense when unsafe navigation appears before safe navigation""":
      expectOffense("""        foo.bar && foo.baz || foo&.qux
                   ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test """registers an offense when using unsafe navigation and the safe navigation appears in a group""":
      expectOffense("""        (foo&.bar && foo.baz) || foo.qux
         ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    test """registers a single offense when safe navigation is used multiple times""":
      expectOffense("""        foo&.bar && foo&.baz || foo.qux
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
""".stripIndent)
    context("auto-correct", proc (): void =
      test "does not correct non dot methods":
        var newSource = autocorrectSource("          foo&.start_with?(\'a\') || foo =~ /b/\n".stripIndent)
        expect(newSource).to(eq("          foo&.start_with?(\'a\') || foo =~ /b/\n".stripIndent))
      test "corrects unsafe navigation on the rhs of &&":
        var newSource = autocorrectSource("          foo&.bar && foo.baz\n".stripIndent)
        expect(newSource).to(eq("          foo&.bar && foo&.baz\n".stripIndent))
      test "corrects unsafe navigation on the lhs of &&":
        var newSource = autocorrectSource("          foo.bar && foo&.baz\n".stripIndent)
        expect(newSource).to(eq("          foo&.bar && foo&.baz\n".stripIndent))
      test "corrects unsafe navigation on the rhs of ||":
        var newSource = autocorrectSource("          foo&.bar || foo.baz\n".stripIndent)
        expect(newSource).to(eq("          foo&.bar || foo&.baz\n".stripIndent))
      test "corrects unsafe navigation on the lhs of ||":
        var newSource = autocorrectSource("          foo.bar || foo&.baz\n".stripIndent)
        expect(newSource).to(eq("          foo&.bar || foo&.baz\n".stripIndent))
      test "corrects unsafe navigation inside of separated conditions":
        var newSource = autocorrectSource("          foo&.bar && foobar.baz && foo.qux\n".stripIndent)
        expect(newSource).to(eq("          foo&.bar && foobar.baz && foo&.qux\n".stripIndent))
      test "corrects unsafe navigation in conditions on the right hand side":
        var newSource = autocorrectSource("          foobar.baz && foo&.bar && foo.qux\n".stripIndent)
        expect(newSource).to(eq("          foobar.baz && foo&.bar && foo&.qux\n".stripIndent))
      test "corrects unsafe assignment":
        var newSource = autocorrectSource("          foo&.bar && foo.baz = 1\n".stripIndent)
        expect(newSource).to(eq("          foo&.bar && foo&.baz = 1\n".stripIndent))
      test "corrects multiple offenses":
        var newSource = autocorrectSource("          foobar.baz && foo&.bar && foo.qux && foo.foobar\n".stripIndent)
        expect(newSource).to(eq("          foobar.baz && foo&.bar && foo&.qux && foo&.foobar\n".stripIndent))
      test "corrects using unsafe navigation with both && and ||":
        var newSource = autocorrectSource("          foo&.bar && foo.baz || foo.qux\n".stripIndent)
        expect(newSource).to(eq("          foo&.bar && foo&.baz || foo&.qux\n".stripIndent))
      test "corrects using unsafe navigation with grouped conditions":
        var newSource = autocorrectSource("          foo&.bar && (foo.baz || foo.qux)\n".stripIndent)
        expect(newSource).to(eq("          foo&.bar && (foo&.baz || foo&.qux)\n".stripIndent))
      test "corrects unsafe navigation appears before safe navigation":
        var newSource = autocorrectSource("          foo.bar && foo.baz || foo&.qux\n".stripIndent)
        expect(newSource).to(eq("          foo&.bar && foo&.baz || foo&.qux\n".stripIndent))
      test """corrects unsafe navigation when the safe navigation appears in a group""":
        var newSource = autocorrectSource("          (foo&.bar && foo.baz) || foo.qux\n".stripIndent)
        expect(newSource).to(eq("          (foo&.bar && foo&.baz) || foo&.qux\n".stripIndent))
      test "correct unsafe navigation on a method chain":
        var newSource = autocorrectSource("          foo.bar&.baz && foo.bar.qux\n".stripIndent)
        expect(newSource).to(eq("          foo.bar&.baz && foo.bar&.qux\n".stripIndent)))))
