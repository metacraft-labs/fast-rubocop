
import
  heredoc_delimiter_case, test_tools

RSpec.describe(HeredocDelimiterCase, "config", proc (): void =
  var cop = ()
  let("config", proc (): void =
    Config.new())
  context("when enforced style is uppercase", proc (): void =
    let("cop_config", proc (): void =
      {"SupportedStyles": @["uppercase", "lowercase"], "EnforcedStyle": "uppercase"}.newTable())
    context("with an interpolated heredoc", proc (): void =
      test "registers an offense with a lowercase delimiter":
        expectOffense("""          <<-sql
            foo
          sql
          ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
      test "registers an offense with a camel case delimiter":
        expectOffense("""          <<-Sql
            foo
          Sql
          ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
      test "does not register an offense with an uppercase delimiter":
        expectNoOffenses("""          <<-SQL
            foo
          SQL
""".stripIndent))
    context("with a non-interpolated heredoc", proc (): void =
      context("when using single quoted delimiters", proc (): void =
        test "registers an offense with a lowercase delimiter":
          expectOffense("""            <<-'sql'
              foo
            sql
            ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
        test "registers an offense with a camel case delimiter":
          expectOffense("""            <<-'Sql'
              foo
            Sql
            ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
        test "does not register an offense with an uppercase delimiter":
          expectNoOffenses("""            <<-'SQL'
              foo
            SQL
""".stripIndent))
      context("when using double quoted delimiters", proc (): void =
        test "registers an offense with a lowercase delimiter":
          expectOffense("""            <<-"sql"
              foo
            sql
            ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
        test "registers an offense with a camel case delimiter":
          expectOffense("""            <<-"Sql"
              foo
            Sql
            ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
        test "does not register an offense with an uppercase delimiter":
          expectNoOffenses("""            <<-"SQL"
              foo
            SQL
""".stripIndent))
      context("when using back tick delimiters", proc (): void =
        test "registers an offense with a lowercase delimiter":
          expectOffense("""            <<-`sql`
              foo
            sql
            ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
        test "registers an offense with a camel case delimiter":
          expectOffense("""            <<-`Sql`
              foo
            Sql
            ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
        test "does not register an offense with an uppercase delimiter":
          expectNoOffenses("""            <<-`SQL`
              foo
            SQL
""".stripIndent))
      context("when using non-word delimiters", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            <<-'+'
              foo
            +
""".stripIndent)))
    context("with a squiggly heredoc", "ruby23", proc (): void =
      test "registers an offense with a lowercase delimiter":
        expectOffense("""          <<~sql
            foo
          sql
          ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
      test "registers an offense with a camel case delimiter":
        expectOffense("""          <<~Sql
            foo
          Sql
          ^^^ Use uppercase heredoc delimiters.
""".stripIndent)
      test "does not register an offense with an uppercase delimiter":
        expectNoOffenses("""          <<~SQL
            foo
          SQL
""".stripIndent)))
  context("when enforced style is lowercase", proc (): void =
    let("cop_config", proc (): void =
      {"SupportedStyles": @["uppercase", "lowercase"], "EnforcedStyle": "lowercase"}.newTable())
    context("with an interpolated heredoc", proc (): void =
      test "does not register an offense with a lowercase delimiter":
        expectNoOffenses("""          <<-sql
            foo
          sql
""".stripIndent)
      test "registers an offense with a camel case delimiter":
        expectOffense("""          <<-Sql
            foo
          Sql
          ^^^ Use lowercase heredoc delimiters.
""".stripIndent)
      test "registers an offense with an uppercase delimiter":
        expectOffense("""          <<-SQL
            foo
          SQL
          ^^^ Use lowercase heredoc delimiters.
""".stripIndent))
    context("with a non-interpolated heredoc", proc (): void =
      test "does not register an offense with a lowercase delimiter":
        expectNoOffenses("""          <<-'sql'
            foo
          sql
""".stripIndent)
      test "registers an offense with a camel case delimiter":
        expectOffense("""          <<-'Sql'
            foo
          Sql
          ^^^ Use lowercase heredoc delimiters.
""".stripIndent)
      test "registers an offense with an uppercase delimiter":
        expectOffense("""          <<-'SQL'
            foo
          SQL
          ^^^ Use lowercase heredoc delimiters.
""".stripIndent))
    context("with a squiggly heredoc", "ruby23", proc (): void =
      test "does not register an offense with a lowercase delimiter":
        expectNoOffenses("""          <<~sql
            foo
          sql
""".stripIndent)
      test "registers an offense with a camel case delimiter":
        expectOffense("""          <<~Sql
            foo
          Sql
          ^^^ Use lowercase heredoc delimiters.
""".stripIndent)
      test "registers an offense with an uppercase delimiter":
        expectOffense("""          <<~SQL
            foo
          SQL
          ^^^ Use lowercase heredoc delimiters.
""".stripIndent))))
