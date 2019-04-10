
import
  uncommunicative_block_param_name, test_tools

RSpec.describe(UncommunicativeBlockParamName, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"MinNameLength": 2, "AllowNamesEndingInNumbers": false}.newTable())
  test "does not register for block without parameters":
    expectNoOffenses("""      something do
        do_stuff
      end
""".stripIndent)
  test "does not register for brace block without parameters":
    expectNoOffenses("      something { do_stuff }\n".stripIndent)
  test "does not register offense for valid parameter names":
    expectNoOffenses("      something { |foo, bar| do_stuff }\n".stripIndent)
  test "registers offense when param ends in number":
    expectOffense("""      something { |foo1, bar| do_stuff }
                   ^^^^ Do not end block parameter with a number.
""".stripIndent)
  test "registers offense when param is less than minimum length":
    expectOffense("""      something do |x|
                    ^ Block parameter must be at least 2 characters long.
        do_stuff
      end
""".stripIndent)
  test "registers offense when param contains uppercase characters":
    expectOffense("""      something { |number_One| do_stuff }
                   ^^^^^^^^^^ Only use lowercase characters for block parameter.
""".stripIndent)
  test "can register multiple offenses in one block":
    expectOffense("""      something do |y, num1, oFo|
                    ^ Block parameter must be at least 2 characters long.
                       ^^^^ Do not end block parameter with a number.
                             ^^^ Only use lowercase characters for block parameter.
        do_stuff
      end
""".stripIndent)
  context("with AllowedNames", proc (): void =
    let("cop_config", proc (): void =
      {"AllowedNames": @["foo1", "foo2"], "AllowNamesEndingInNumbers": false}.newTable())
    test "accepts specified block param names":
      expectNoOffenses("        something { |foo1, foo2| do_things }\n".stripIndent)
    test "registers unlisted offensive names":
      expectOffense("""        something { |bar, bar1| do_things }
                          ^^^^ Do not end block parameter with a number.
""".stripIndent))
  context("with ForbiddenNames", proc (): void =
    let("cop_config", proc (): void =
      {"ForbiddenNames": @["arg"]}.newTable())
    test "registers offense for param listed as forbidden":
      expectOffense("""        something { |arg| do_stuff }
                     ^^^ Do not use arg as a name for a block parameter.
""".stripIndent)
    test "accepts param that uses a forbidden name\'s letters":
      expectNoOffenses("        something { |foo_arg| do_stuff }\n".stripIndent))
  context("with AllowNamesEndingInNumbers", proc (): void =
    let("cop_config", proc (): void =
      {"AllowNamesEndingInNumbers": true}.newTable())
    test "accept params that end in numbers":
      expectNoOffenses("        something { |foo1, bar2, qux3| do_that_stuff }\n".stripIndent)))
