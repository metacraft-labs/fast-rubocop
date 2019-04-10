
import
  space_before_first_arg, test_tools

RSpec.describe(SpaceBeforeFirstArg, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"AllowForAlignment": true}.newTable())
  context("for method calls without parentheses", proc (): void =
    test """registers an offense for method call with two spaces before the first arg""":
      expectOffense("""        something  x
                 ^^ Put one space between the method name and the first argument.
        a.something  y, z
                   ^^ Put one space between the method name and the first argument.
""".stripIndent)
    test "auto-corrects extra space":
      var newSource = autocorrectSource("""        something  x
        a.something   y, z
""".stripIndent)
      expect(newSource).to(eq("""        something x
        a.something y, z
""".stripIndent))
    context("when using safe navigation operator", "ruby23", proc (): void =
      test """registers an offense for method call with two spaces before the first arg""":
        expectOffense("""          a&.something  y, z
                      ^^ Put one space between the method name and the first argument.
""".stripIndent)
      test "auto-corrects extra space":
        var newSource = autocorrectSource("          a&.something  y, z\n".stripIndent)
        expect(newSource).to(eq("          a&.something y, z\n".stripIndent)))
    test """registers an offense for method call with no spaces before the first arg""":
      inspectSource("""        something'hello'
        a.something'hello world'
""".stripIndent)
      expect(cop().messages).to(eq(@["""Put one space between the method name and the first argument."""] *
          2))
    test "auto-corrects missing space":
      var newSource = autocorrectSource("""        something'hello'
        a.something'hello world'
""".stripIndent)
      expect(newSource).to(eq("""        something 'hello'
        a.something 'hello world'
""".stripIndent))
    test "accepts a method call with one space before the first arg":
      expectNoOffenses("""        something x
        a.something y, z
""".stripIndent)
    test "accepts + operator":
      expectNoOffenses("""        something +
          x
""".stripIndent)
    test "accepts setter call":
      expectNoOffenses("""        something.x =
          y
""".stripIndent)
    test "accepts multiple space containing line break":
      expectNoOffenses("""        something \
          x
""".stripIndent)
    context("when AllowForAlignment is true", proc (): void =
      test "accepts method calls with aligned first arguments":
        expectNoOffenses("""          form.inline_input   :full_name,     as: :string
          form.disabled_input :password,      as: :passwd
          form.masked_input   :zip_code,      as: :string
          form.masked_input   :email_address, as: :email
          form.masked_input   :phone_number,  as: :tel
""".stripIndent))
    context("when AllowForAlignment is false", proc (): void =
      let("cop_config", proc (): void =
        {"AllowForAlignment": false}.newTable())
      test "does not accept method calls with aligned first arguments":
        expectOffense("""          form.inline_input   :full_name,     as: :string
                           ^^^ Put one space between the method name and the first argument.
          form.disabled_input :password,      as: :passwd
          form.masked_input   :zip_code,      as: :string
                           ^^^ Put one space between the method name and the first argument.
          form.masked_input   :email_address, as: :email
                           ^^^ Put one space between the method name and the first argument.
          form.masked_input   :phone_number,  as: :tel
                           ^^^ Put one space between the method name and the first argument.
""".stripIndent)))
  context("for method calls with parentheses", proc (): void =
    test "accepts a method call without space":
      expectNoOffenses("""        something(x)
        a.something(y, z)
""".stripIndent)
    test "accepts a method call with space after the left parenthesis":
      expectNoOffenses("something(  x  )")))
