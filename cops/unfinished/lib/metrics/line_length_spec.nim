
import
  types

import
  line_length, test_tools

RSpec.describe(LineLength, "config", proc () =
  var cop = ()
  let("cop_config", proc (): Table[string, int] =
    {"Max": 80, "IgnoredPatterns": }.newTable())
  test "registers an offense for a line that\'s 81 characters wide":
    inspectSource("#" * 81)
    expect(self.cop().offenses.size).to(eq(1))
    expect(self.cop().offenses.first().message).to(
        eq("Line is too long. [81/80]"))
    expect(self.cop().configToAllowOffenses).to(
        eq(excludeLimit = {"Max": 81}.newTable()))
  test "highlights excessive characters":
    inspectSource("#" * 80 & "abc")
    expect(self.cop().highlights).to(eq(@["abc"]))
  test "accepts a line that\'s 80 characters wide":
    expectNoOffenses("#" * 80)
  test "registers an offense for long line before __END__ but not after":
    inspectSource(("#" * 150, "__END__", "#" * 200).join("\n"))
    expect(self.cop().messages).to(eq(@["Line is too long. [150/80]"]))
  context("when AllowURI option is enabled", proc () =
    let("cop_config", proc (): Table[string, int] =
      {"Max": 80, "AllowURI": true}.newTable())
    context("and all the excessive characters are part of an URL", proc () =
      test "accepts the line":
        expectNoOffenses("""          # Some documentation comment...
          # See: https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
""")
      context("and the URL is wrapped in single quotes", proc () =
        test "accepts the line":
          expectNoOffenses("            # See: \'https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c\'\n"))
      context("and the URL is wrapped in double quotes", proc () =
        test "accepts the line":
          expectNoOffenses("            # See: \"https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c\"\n")))
    context("and the excessive characters include a complete URL", proc () =
      test "registers an offense for the line":
        expectOffense("""          # See: http://google.com/, http://gmail.com/, https://maps.google.com/, http://plus.google.com/
                                                                                ^^^^^^^^^^^^^^^^^^^^^^^^^ Line is too long. [105/80]
"""))
    context("""and the excessive characters include part of an URL and another word""", proc () =
      test "registers an offense for the line":
        expectOffense("""          # See: https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c and
                                                                                                      ^^^^ Line is too long. [106/80]
          #   http://google.com/
"""))
    context("""and an error other than URI::InvalidURIError is raised while validating an URI-ish string""", proc () =
      let("cop_config", proc (): Table[string, int] =
        {"Max": 80, "AllowURI": true, "URISchemes": @["LDAP"]}.newTable())
      let("source", proc (): string =
        "        xxxxxxxxxxxxxxxxxxxxxxxxxxxxzxxxxxxxxxxx = LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY\n")
      test "does not crash":
        expect(proc () =
          inspectSource(source())).notTo(raiseError))
    context("and the URL does not have a http(s) scheme", proc () =
      let("source", proc (): string =
        "        xxxxxxxxxxxxxxxxxxxxxxxxxxxxzxxxxxxxxxxx = \'otherprotocol://a.very.long.line.which.violates.LineLength/sadf\'\n")
      test "rejects the line":
        inspectSource(source())
        expect(self.cop().offenses.size).to(eq(1))
      context("and the scheme has been configured", proc () =
        let("cop_config", proc (): Table[string, int] =
          {"Max": 80, "AllowURI": true, "URISchemes": @["otherprotocol"]}.newTable())
        test "does not register an offense":
          expectNoOffenses(source()))))
  context("when IgnoredPatterns option is set", proc () =
    let("cop_config", proc (): Table[string, int] =
      {"Max": 18, "IgnoredPatterns": ("^\\s*test\\s", )}.newTable())
    let("source", proc (): string =
      """        class ExampleTest < TestCase
          test 'some really long test description which exceeds length' do
          end
          def test_some_other_long_test_description_which_exceeds_length
          end
        end
""".stripIndent)
    test "accepts long lines matching a pattern but not other long lines":
      inspectSource(source())
      expect(self.cop().highlights).to(eq(@["< TestCase"])))
  context("when AllowHeredoc option is enabled", proc () =
    let("cop_config", proc (): Table[string, int] =
      {"Max": 80, "AllowHeredoc": true}.newTable())
    let("source", proc (): string =
      """      <<-SQL
        SELECT posts.id, posts.title, users.name FROM posts LEFT JOIN users ON posts.user_id = users.id;
      SQL
""")
    test "accepts long lines in heredocs":
      expectNoOffenses(source())
    context("when the source has no AST", proc () =
      let("source", proc (): string =
        "# this results in AST being nil")
      test "does not crash":
        expect(proc () =
          inspectSource(source())).notTo(raiseError))
    context("and only certain heredoc delimiters are whitelisted", proc () =
      let("cop_config", proc (): Table[string, int] =
        {"Max": 80, "AllowHeredoc": @["SQL", "OK"], "IgnoredPatterns": @[]}.newTable())
      let("source", proc (): string =
        """        foo(<<-DOC, <<-SQL, <<-FOO)
          1st offense: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          #{<<-OK}
            no offense (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          OK
          2nd offense: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        DOC
          no offense (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          #{<<-XXX}
            no offense (nested inside whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          XXX
          no offense (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        SQL
          3rd offense: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          #{<<-SQL}
            no offense (whitelisted): Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          SQL
          4th offense: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        FOO
""")
      test "rejects long lines in heredocs with not whitelisted delimiters":
        inspectSource(source())
        expect(self.cop().offenses.size).to(eq(4))))
  context("when AllowURI option is disabled", proc () =
    let("cop_config", proc (): Table[string, int] =
      {"Max": 80, "AllowURI": false}.newTable())
    context("and all the excessive characters are part of an URL", proc () =
      test "registers an offense for the line":
        expectOffense("""          # See: https://github.com/rubocop-hq/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
                                                                                ^^^^^^^^^^^^^^^^^^^^^^ Line is too long. [102/80]
""")))
  context("when IgnoreCopDirectives is disabled", proc () =
    let("cop_config", proc (): Table[string, int] =
      {"Max": 80, "IgnoreCopDirectives": false}.newTable())
    context("and the source is acceptable length", proc () =
      let("acceptable_source", proc (): string =
        "a" * 80)
      context("with a trailing Rubocop directive", proc () =
        let("cop_directive", proc (): string =
          " # rubcop:disable Metrics/SomeCop")
        let("source", proc (): string =
          acceptableSource() & copDirective())
        test "registers an offense for the line":
          inspectSource(source())
          expect(self.cop().offenses.size).to(eq(1))
        test "highlights the excess directive":
          inspectSource(source())
          expect(self.cop().highlights).to(eq(@[self.copDirective()])))
      context("with an inline comment", proc () =
        let("excess_comment", proc (): string =
          " ###")
        let("source", proc (): string =
          acceptableSource() & excessComment())
        test "highlights the excess comment":
          inspectSource(source())
          expect(self.cop().highlights).to(eq(@[self.excessComment()]))))
    context("and the source is too long and has a trailing cop directive", proc () =
      let("excess_with_directive", proc (): string =
        "b # rubocop:disable Metrics/AbcSize")
      let("source", proc (): string =
        "a" * 80 & excessWithDirective())
      test "highlights the excess source and cop directive":
        inspectSource(source())
        expect(self.cop().highlights).to(eq(@[self.excessWithDirective()]))))
  context("when IgnoreCopDirectives is enabled", proc () =
    let("cop_config", proc (): Table[string, int] =
      {"Max": 80, "IgnoreCopDirectives": true}.newTable())
    context("and the Rubocop directive is excessively long", proc () =
      let("source", proc (): string =
        "        # rubocop:disable Metrics/SomeReallyLongMetricNameThatShouldBeMuchShorterAndNeedsANameChange\n")
      test "accepts the line":
        expectNoOffenses(source()))
    context("and the Rubocop directive causes an excessive line length", proc () =
      let("source", proc (): string =
        """        def method_definition_that_is_just_under_the_line_length_limit(foo, bar) # rubocop:disable Metrics/AbcSize
          # complex method
        end
""")
      test "accepts the line":
        expectNoOffenses(source())
      context("and has explanatory text", proc () =
        let("source", proc (): string =
          """          def method_definition_that_is_just_under_the_line_length_limit(foo) # rubocop:disable Metrics/AbcSize inherently complex!
            # complex
          end
""")
        test "does not register an offense":
          expectNoOffenses(source())))
    context("and the source is too long", proc () =
      let("source", proc (): string =
        "a" * 80 & "bcd" & " # rubocop:enable Style/ClassVars")
      test "registers an offense for the line":
        inspectSource(source())
        expect(self.cop().offenses.size).to(eq(1))
      test "highlights only the non-directive part":
        inspectSource(source())
        expect(self.cop().highlights).to(eq(@["bcd"]))
      context("and the source contains non-directive # as comment", proc () =
        let("source", proc (): string =
          "          aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa # bbbbbbbbbbbbbb # rubocop:enable Style/ClassVars\'\n")
        test "registers an offense for the line":
          inspectSource(source())
          expect(self.cop().offenses.size).to(eq(1))
        test "highlights only the non-directive part":
          inspectSource(source())
          expect(self.cop().highlights).to(eq(@["bbbbbbb"])))
      context("and the source contains non-directive #s as non-comment", proc () =
        let("source", proc (): string =
          "          LARGE_DATA_STRING_PATTERN = %r{A([A-Za-z0-9+/#]*={0,2})#([A-Za-z0-9+/#]*={0,2})#([A-Za-z0-9+/#]*={0,2})z} # rubocop:disable LineLength\n")
        test "registers an offense for the line":
          inspectSource(source())
          expect(self.cop().offenses.size).to(eq(1))
        test "highlights only the non-directive part":
          inspectSource(source())
          expect(self.cop().highlights).to(
              eq(@["]*={0,2})#([A-Za-z0-9+/#]*={0,2})z}"])))))
  context("affecting by IndentationWidth from Layout\\Tab", proc () =
    sharedExamples("with tabs indentation", proc () =
      test """registers an offense for a line that's including 2 tab with size 2 and 28 other characters""":
        inspectSource("\t\t" & "#" * 28)
        expect(self.cop().offenses.size).to(eq(1))
        expect(self.cop().offenses.first().message).to(
            eq("Line is too long. [32/30]"))
        expect(self.cop().configToAllowOffenses).to(
            eq(excludeLimit = {"Max": 32}.newTable()))
      test "highlights excessive characters":
        inspectSource("\t" & "#" * 28 & "a")
        expect(self.cop().highlights).to(eq(@["a"]))
      test """accepts a line that's including 1 tab with size 2 and 28 other characters""":
        expectNoOffenses("\t" & "#" * 28))
    context("without AllowURI option", proc () =
      let("config", proc (): Config =
        initConfig())
      itBehavesLike("with tabs indentation"))
    context("with AllowURI option", proc () =
      let("config", proc (): Config =
        initConfig())
      itBehavesLike("with tabs indentation")
      test "accepts a line that\'s including URI":
        expectNoOffenses("\t\t# https://github.com/rubocop-hq/rubocop")
      test "accepts a line that\'s including URI and exceeds by 1 char":
        expectNoOffenses("\t\t# https://github.com/ruboco")
      test "accepts a line that\'s including URI with text":
        expectNoOffenses("\t\t# See https://github.com/rubocop-hq/rubocop")
      test "accepts a line that\'s including URI in quotes with text":
        expectNoOffenses("\t\t# See \'https://github.com/rubocop-hq/rubocop\'"))))
