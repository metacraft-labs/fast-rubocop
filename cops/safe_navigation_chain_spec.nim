
import
  tables

import
  safe_navigation_chain, test_tools

RSpec.describe(SafeNavigationChain, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"Whitelist": @["present?", "blank?", "try", "presence"]}.newTable())
  sharedExamples("accepts", proc (name: string; code: string): void =
    test """accepts usages of (lvar :name)""":
      expectNoOffenses(code))
  context("TargetRubyVersion >= 2.3", "ruby23", proc (): void =
    for name, code in @[@["ordinary method chain", "x.foo.bar.baz"], @[
        "ordinary method chain with argument", "x.foo(x).bar(y).baz(z)"], @[
        "method chain with safe navigation only", "x&.foo&.bar&.baz"], @[
        "method chain with safe navigation only with argument",
        "x&.foo(x)&.bar(y)&.baz(z)"],
                    @["safe navigation at last only", "x.foo.bar&.baz"], @[
        "safe navigation at last only with argument", "x.foo(x).bar(y)&.baz(z)"],
                    @["safe navigation with == operator", "x&.foo == bar"],
                    @["safe navigation with === operator", "x&.foo === bar"],
                    @["safe navigation with || operator", "x&.foo || bar"],
                    @["safe navigation with && operator", "x&.foo && bar"],
                    @["safe navigation with | operator", "x&.foo | bar"],
                    @["safe navigation with & operator", "x&.foo & bar"],
                    @["safe navigation with `nil?` method", "x&.foo.nil?"], @[
        "safe navigation with `present?` method", "x&.foo.present?"], @[
        "safe navigation with `blank?` method", "x&.foo.blank?"],
                    @["safe navigation with `try` method", "a&.b.try(:c)"], @[
        "safe navigation with assignment method", "x&.foo = bar"], @[
        "safe navigation with self assignment method", "x&.foo += bar"],
                    @["safe navigation with `to_d` method", "x&.foo.to_d"]]:
      includeExamples("accepts", name, code)
    test """registers an offense for ordinary method call exists after safe navigation method call""":
      expectOffense("""        x&.foo.bar
              ^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test """registers an offense for ordinary method call exists after safe navigation method call with an argument""":
      expectOffense("""        x&.foo(x).bar(y)
                 ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test """registers an offense for ordinary method chain exists after safe navigation method call""":
      expectOffense("""        something
        x&.foo.bar.baz
              ^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test """registers an offense for ordinary method chain exists after safe navigation method call with an argument""":
      expectOffense("""        x&.foo(x).bar(y).baz(z)
                 ^^^^^^^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test """registers an offense for ordinary method chain exists after safe navigation method call with a block-pass""":
      expectOffense("""        something
        x&.select(&:foo).bar
                        ^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test """registers an offense for ordinary method chain exists after safe navigation method call with a block""":
      expectOffense("""        something
        x&.select { |x| foo(x) }.bar
                                ^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test "registers an offense for safe navigation with < operator":
      expectOffense("""        x&.foo < bar
              ^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test "registers an offense for safe navigation with > operator":
      expectOffense("""        x&.foo > bar
              ^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test "registers an offense for safe navigation with <= operator":
      expectOffense("""        x&.foo <= bar
              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test "registers an offense for safe navigation with >= operator":
      expectOffense("""        x&.foo >= bar
              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test "registers an offense for safe navigation with + operator":
      expectOffense("""        x&.foo + bar
              ^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test "registers an offense for safe navigation with [] operator":
      expectOffense("""        x&.foo[bar]
              ^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    test "registers an offense for safe navigation with []= operator":
      expectOffense("""        x&.foo[bar] = baz
              ^^^^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
    context("proper highlighting", proc (): void =
      test "when there are methods before":
        expectOffense("""        something
        x&.foo.bar.baz
              ^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent)
      test "when there are methods after":
        expectOffense("""          x&.foo.bar.baz
                ^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
          something
""".stripIndent)
      test "when in a method":
        expectOffense("""          def something
            x&.foo.bar.baz
                  ^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
          end
""".stripIndent)
      test "when in a begin":
        expectOffense("""          begin
            x&.foo.bar.baz
                  ^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
          end
""".stripIndent)
      test "when used with a modifier if":
        expectOffense("""          x&.foo.bar.baz if something
                ^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
""".stripIndent))))
