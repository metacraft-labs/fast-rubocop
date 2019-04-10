
import
  tables

import
  string_replacement, test_tools

suite "StringReplacement":
  var cop = StringReplacement()
  test "accepts methods other than gsub":
    expectNoOffenses("\'abc\'.insert(2, \'a\')")
  sharedExamples("accepts", proc (method: string): void =
    context("non deterministic parameters", proc (): void =
      test "accepts gsub when the length of the pattern is greater than 1":
        expectNoOffenses("""'abc'.(lvar :method)('ab', 'de')""")
      test "accepts the first param being a variable":
        expectNoOffenses("""          regex = /a/
          'abc'.(lvar :method)(regex, '1')
""".stripIndent)
      test "accepts the second param being a variable":
        expectNoOffenses("""          replacement = 'e'
          'abc'.(lvar :method)('abc', replacement)
""".stripIndent)
      test "accepts the both params being a variables":
        expectNoOffenses("""          regex = /a/
          replacement = 'e'
          'abc'.(lvar :method)(regex, replacement)
""".stripIndent)
      test "accepts gsub with only one param":
        expectNoOffenses("""'abc'.(lvar :method)('a')""")
      test "accepts gsub with a block":
        expectNoOffenses("""'abc'.(lvar :method)('a') { |s| s.upcase } """)
      test "accepts a pattern with string interpolation":
        expectNoOffenses("""          foo = 'a'
          'abc'.(lvar :method)("#{foo}", '1')
""".stripIndent)
      test "accepts a replacement with string interpolation":
        expectNoOffenses("""          foo = '1'
          'abc'.(lvar :method)('a', "#{foo}")
""".stripIndent)
      test "allows empty regex literal pattern":
        expectNoOffenses("""'abc'.(lvar :method)(//, '1')""")
      test "allows empty regex pattern from string":
        expectNoOffenses("""'abc'.(lvar :method)(Regexp.new(''), '1')""")
      test "allows empty regex pattern from regex":
        expectNoOffenses("""'abc'.(lvar :method)(Regexp.new(//), '1')""")
      test "allows regex literals with options":
        expectNoOffenses("""'abc'.(lvar :method)(/a/i, '1')""")
      test "allows regex with options":
        expectNoOffenses("""'abc'.(lvar :method)(Regexp.new(/a/i), '1')""")
      test "allows empty string pattern":
        expectNoOffenses("""'abc'.(lvar :method)('', '1')"""))
    test """accepts calls to gsub when the length of the pattern is shorter than the length of the replacement""":
      expectNoOffenses("""'abc'.(lvar :method)('a', 'ab')""")
    test """accepts calls to gsub when the length of the pattern is longer than the length of the replacement""":
      expectNoOffenses("""'abc'.(lvar :method)('ab', 'd')"""))
  itBehavesLike("accepts", "gsub")
  itBehavesLike("accepts", "gsub!")
  describe("deterministic regex", proc (): void =
    describe("regex literal", proc (): void =
      test "registers an offense when using space":
        expectOffense("""          'abc'.gsub(/ /, '')
                ^^^^^^^^^^^^^ Use `delete` instead of `gsub`.
""".stripIndent)
      for str in @["a", "b", "c", "\'", "\"", "%", "!", "=", "<", ">", "#", "&", ";", ":", "`",
                "~", "1", "2", "3", "-", "_", ",", "\\r", "\\\\", "\\y", "\\u1234", "\\x65"]:
        test """registers an offense when replacing (lvar :str) with a literal""":
          inspectSource("""'abc'.gsub(/(lvar :str)/, 'a')""")
          expect(cop().messages).to(eq(@["Use `tr` instead of `gsub`."]))
        test """registers an offense when deleting (lvar :str)""":
          inspectSource("""'abc'.gsub(/(lvar :str)/, '')""")
          expect(cop().messages).to(eq(@["Use `delete` instead of `gsub`."]))
      test """allows deterministic regex when the length of the pattern and the length of the replacement do not match""":
        expectNoOffenses("\'abc\'.gsub(/a/, \'def\')")
      test "registers an offense when escape characters in regex":
        inspectSource("\'abc\'.gsub(/\n/, \',\')")
        expect(cop().messages).to(eq(@["Use `tr` instead of `gsub`."]))
      test "registers an offense when using %r notation":
        expectOffense("""          '/abc'.gsub(%r{a}, 'd')
                 ^^^^^^^^^^^^^^^^ Use `tr` instead of `gsub`.
""".stripIndent))
    describe("regex constructor", proc (): void =
      test "registers an offense when only using word characters":
        expectOffense("""          'abc'.gsub(Regexp.new('b'), '2')
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tr` instead of `gsub`.
""".stripIndent)
      test "registers an offense when regex is built from regex":
        expectOffense("""          'abc'.gsub(Regexp.new(/b/), '2')
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tr` instead of `gsub`.
""".stripIndent)
      test "registers an offense when using compile":
        expectOffense("""          '123'.gsub(Regexp.compile('1'), 'a')
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `tr` instead of `gsub`.
""".stripIndent)))
  describe("non deterministic regex", proc (): void =
    test "allows regex containing a +":
      expectNoOffenses("\'abc\'.gsub(/a+/, \'def\')")
    test "allows regex containing a *":
      expectNoOffenses("\'abc\'.gsub(/a*/, \'def\')")
    test "allows regex containing a ^":
      expectNoOffenses("\'abc\'.gsub(/^/, \'\')")
    test "allows regex containing a $":
      expectNoOffenses("\'abc\'.gsub(/$/, \'\')")
    test "allows regex containing a ?":
      expectNoOffenses("\'abc\'.gsub(/a?/, \'def\')")
    test "allows regex containing a .":
      expectNoOffenses("\'abc\'.gsub(/./, \'a\')")
    test "allows regex containing a |":
      expectNoOffenses("\'abc\'.gsub(/a|b/, \'d\')")
    test "allows regex containing ()":
      expectNoOffenses("\'abc\'.gsub(/(ab)/, \'d\')")
    test "allows regex containing escaped ()":
      expectNoOffenses("\'(abc)\'.gsub(/(ab)/, \'d\')")
    test "allows regex containing {}":
      expectNoOffenses("\'abc\'.gsub(/a{3,}/, \'d\')")
    test "allows regex containing []":
      expectNoOffenses("\'abc\'.gsub(/[a-z]/, \'d\')")
    test "allows regex containing a backslash":
      expectNoOffenses("\"abc\".gsub(/\\s/, \"d\")")
    test "allows regex literal containing interpolations":
      expectNoOffenses("""        foo = 'a'
        "abc".gsub(/#{foo}/, "d")
""".stripIndent)
    test "allows regex constructor containing a string with interpolations":
      expectNoOffenses("""        foo = 'a'
        "abc".gsub(Regexp.new("#{foo}"), "d")
""".stripIndent)
    test "allows regex constructor containing regex with interpolations":
      expectNoOffenses("""        foo = 'a'
        "abc".gsub(Regexp.new(/#{foo}/), "d")
""".stripIndent))
  test """registers an offense when the pattern has non deterministic regex as a string""":
    expectOffense("""      'a + c'.gsub('+', '-')
              ^^^^^^^^^^^^^^ Use `tr` instead of `gsub`.
""".stripIndent)
  test """registers an offense when using gsub to find and replace a single character""":
    expectOffense("""      'abc'.gsub('a', '1')
            ^^^^^^^^^^^^^^ Use `tr` instead of `gsub`.
""".stripIndent)
  test """registers an offense when using gsub! to find and replace a single character """:
    expectOffense("""      'abc'.gsub!('a', '1')
            ^^^^^^^^^^^^^^^ Use `tr!` instead of `gsub!`.
""".stripIndent)
  test "registers an offense for gsub! when deleting one characters":
    expectOffense("""      'abc'.gsub!('a', '')
            ^^^^^^^^^^^^^^ Use `delete!` instead of `gsub!`.
""".stripIndent)
  test "registers an offense when using escape characters in the replacement":
    inspectSource("\'abc\'.gsub(\'a\', \'\n\')")
    expect(cop().messages).to(eq(@["Use `tr` instead of `gsub`."]))
  test "registers an offense when using escape characters in the pattern":
    inspectSource("\'abc\'.gsub(\'\n\', \',\')")
    expect(cop().messages).to(eq(@["Use `tr` instead of `gsub`."]))
  context("auto-correct", proc (): void =
    describe("corrects to tr", proc (): void =
      test "corrects when the length of the pattern and replacement are one":
        var newSource = autocorrectSource("\'abc\'.gsub(\'a\', \'d\')")
        expect(newSource).to(eq("\'abc\'.tr(\'a\', \'d\')"))
      test "corrects when the pattern is a regex literal":
        var newSource = autocorrectSource("\'abc\'.gsub(/a/, \'1\')")
        expect(newSource).to(eq("\'abc\'.tr(\'a\', \'1\')"))
      test "corrects when the pattern is a regex literal using %r":
        var newSource = autocorrectSource("\'abc\'.gsub(%r{a}, \'1\')")
        expect(newSource).to(eq("\'abc\'.tr(\'a\', \'1\')"))
      test "corrects when the pattern uses Regexp.new":
        var newSource = autocorrectSource("\'abc\'.gsub(Regexp.new(\'a\'), \'1\')")
        expect(newSource).to(eq("\'abc\'.tr(\'a\', \'1\')"))
      test "corrects when the pattern uses Regexp.compile":
        var newSource = autocorrectSource("\'abc\'.gsub(Regexp.compile(\'a\'), \'1\')")
        expect(newSource).to(eq("\'abc\'.tr(\'a\', \'1\')"))
      test "corrects when the replacement contains a new line character":
        var newSource = autocorrectSource("\'abc\'.gsub(\'a\', \'\n\')")
        expect(newSource).to(eq("\'abc\'.tr(\'a\', \'\n\')"))
      test "corrects when the replacement contains escape backslash":
        var newSource = autocorrectSource("\"\".gsub(\'/\', \'\\\\\')")
        expect(newSource).to(eq("\"\".tr(\'/\', \'\\\\\')"))
      test "corrects when the pattern contains a new line character":
        var newSource = autocorrectSource("\'abc\'.gsub(\'\n\', \',\')")
        expect(newSource).to(eq("\'abc\'.tr(\'\n\', \',\')"))
      test "corrects when the pattern contains double backslash":
        var newSource = autocorrectSource("\'\'.gsub(\'\\\\\', \'\')")
        expect(newSource).to(eq("\'\'.delete(\'\\\\\')"))
      test "corrects when replacing to a single quote":
        var newSource = autocorrectSource("\"a`b\".gsub(\"`\", \"\'\")")
        expect(newSource).to(eq("\"a`b\".tr(\"`\", \"\'\")"))
      test "corrects when replacing to a double quote":
        var newSource = autocorrectSource("\"a`b\".gsub(\"`\", \"\\\"\")")
        expect(newSource).to(eq("\"a`b\".tr(\"`\", \"\\\"\")")))
    describe("corrects to delete", proc (): void =
      test "corrects when deleting a single character":
        var newSource = autocorrectSource("\'abc\'.gsub!(\'a\', \'\')")
        expect(newSource).to(eq("\'abc\'.delete!(\'a\')"))
      test "corrects when the pattern is a regex literal":
        var newSource = autocorrectSource("\'abc\'.gsub(/a/, \'\')")
        expect(newSource).to(eq("\'abc\'.delete(\'a\')"))
      test "corrects when deleting an escape character":
        var newSource = autocorrectSource("\'abc\'.gsub(\'\n\', \'\')")
        expect(newSource).to(eq("\'abc\'.delete(\'\n\')"))
      test "corrects when the pattern uses Regexp.new":
        var newSource = autocorrectSource("\'abc\'.gsub(Regexp.new(\'a\'), \'\')")
        expect(newSource).to(eq("\'abc\'.delete(\'a\')"))
      test "corrects when the pattern uses Regexp.compile":
        var newSource = autocorrectSource("\'ab\'.gsub(Regexp.compile(\'a\'), \'\')")
        expect(newSource).to(eq("\'ab\'.delete(\'a\')"))
      test "corrects when there are no brackets":
        var newSource = autocorrectSource("\'abc\'.gsub! \'a\', \'\'")
        expect(newSource).to(eq("\'abc\'.delete! \'a\'"))
      test "corrects when a regexp contains escapes":
        var newSource = autocorrectSource("\'abc\'.gsub(/\\n/, \'\')")
        expect(newSource).to(eq("\'abc\'.delete(\"\\n\")"))))
