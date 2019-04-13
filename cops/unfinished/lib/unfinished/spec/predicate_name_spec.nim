
import
  predicate_name, test_tools

RSpec.describe(PredicateName, "config", proc (): void =
  var cop = ()
  context("with blacklisted prefixes", proc (): void =
    let("cop_config", proc (): void =
      {"NamePrefix": @["has_", "is_"], "NamePrefixBlacklist": @["has_", "is_"]}.newTable())
    test "registers an offense when method name starts with \"is\"":
      expectOffense("""        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `attr?`.
""".stripIndent)
    test "registers an offense when method name starts with \"has\"":
      expectOffense("""        def has_attr; end
            ^^^^^^^^ Rename `has_attr` to `attr?`.
""".stripIndent)
    test "accepts method name that starts with unknown prefix":
      expectNoOffenses("        def have_attr; end\n".stripIndent)
    test "accepts method name that is an assignment":
      expectNoOffenses("        def is_hello=; end\n".stripIndent)
    test "accepts method name when corrected name is invalid identifier":
      expectNoOffenses("        def is_2d?; end\n".stripIndent))
  context("without blacklisted prefixes", proc (): void =
    let("cop_config", proc (): void =
      {"NamePrefix": @["has_", "is_"], "NamePrefixBlacklist": @[]}.newTable())
    test "registers an offense when method name starts with \"is\"":
      expectOffense("""        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `is_attr?`.
""".stripIndent)
    test "registers an offense when method name starts with \"has\"":
      expectOffense("""        def has_attr; end
            ^^^^^^^^ Rename `has_attr` to `has_attr?`.
""".stripIndent)
    test "accepts method name that starts with unknown prefix":
      expectNoOffenses("        def have_attr; end\n".stripIndent)
    test "accepts method name when corrected name is invalid identifier":
      expectNoOffenses("        def is_2d?; end\n".stripIndent))
  context("with whitelisted predicate names", proc (): void =
    let("cop_config", proc (): void =
      {"NamePrefix": @["is_"], "NamePrefixBlacklist": @["is_"],
       "NameWhitelist": @["is_a?"]}.newTable())
    test "accepts method name which is in whitelist":
      expectNoOffenses("        def is_a?; end\n".stripIndent))
  context("with method definition macros", proc (): void =
    let("cop_config", proc (): void =
      {"NamePrefix": @["is_"], "NamePrefixBlacklist": @["is_"],
       "MethodDefinitionMacros": @["define_method", "def_node_matcher"]}.newTable())
    test "registers an offense when using `define_method`":
      expectOffense("""        define_method(:is_hello) do |method_name|
                      ^^^^^^^^^ Rename `is_hello` to `hello?`.
          method_name == 'hello'
        end
""".stripIndent)
    test "registers an offense when using an internal affair macro":
      expectOffense("""        def_node_matcher :is_hello, <<-PATTERN
                         ^^^^^^^^^ Rename `is_hello` to `hello?`.
          (send
            (send nil? :method_name) :==
            (str 'hello'))
        PATTERN
""".stripIndent)
    test "accepts method name when corrected name is invalid identifier":
      expectNoOffenses("""        define_method(:is_2d?) do |method_name|
          method_name == 'hello'
        end
""".stripIndent))
  context("without method definition macros", proc (): void =
    let("cop_config", proc (): void =
      {"NamePrefix": @["is_"], "NamePrefixBlacklist": @["is_"]}.newTable())
    test "registers an offense when using `define_method`":
      expectOffense("""        define_method(:is_hello) do |method_name|
                      ^^^^^^^^^ Rename `is_hello` to `hello?`.
          method_name == 'hello'
        end
""".stripIndent)
    test "does not register any offenses when using an internal affair macro":
      expectNoOffenses("""        def_node_matcher :is_hello, <<-PATTERN
                         ^^^^^^^^^ Rename `is_hello` to `hello?`.
          (send
            (send nil? :method_name) :==
            (str 'hello'))
        PATTERN
""".stripIndent)
    test "accepts method name when corrected name is invalid identifier":
      expectNoOffenses("""        define_method(:is_2d?) do |method_name|
          method_name == 'hello'
        end
""".stripIndent)))
