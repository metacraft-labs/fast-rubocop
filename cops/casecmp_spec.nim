
import
  casecmp, test_tools

suite "Casecmp":
  var cop = Casecmp()
  sharedExamples("selectors", proc (selector: string): void =
    test """autocorrects str.(lvar :selector) ==""":
      var newSource = autocorrectSource("""str.(lvar :selector) == 'string'""")
      expect(newSource).to(eq("str.casecmp(\'string\').zero?"))
    test """autocorrects str.(lvar :selector) == with parens around arg""":
      var newSource = autocorrectSource("""str.(lvar :selector) == ('string')""")
      expect(newSource).to(eq("str.casecmp(\'string\').zero?"))
    test """autocorrects str.(lvar :selector) !=""":
      var newSource = autocorrectSource("""str.(lvar :selector) != 'string'""")
      expect(newSource).to(eq("!str.casecmp(\'string\').zero?"))
    test """autocorrects str.(lvar :selector) != with parens around arg""":
      var newSource = autocorrectSource("""str.(lvar :selector) != ('string')""")
      expect(newSource).to(eq("!str.casecmp(\'string\').zero?"))
    test """autocorrects str.(lvar :selector).eql? without parens""":
      var newSource = autocorrectSource("""str.(lvar :selector).eql? 'string'""")
      expect(newSource).to(eq("str.casecmp(\'string\').zero?"))
    test """autocorrects str.(lvar :selector).eql? with parens""":
      var newSource = autocorrectSource("""str.(lvar :selector).eql?('string')""")
      expect(newSource).to(eq("str.casecmp(\'string\').zero?"))
    test """autocorrects str.(lvar :selector).eql? with parens and funny spacing""":
      var newSource = autocorrectSource("""str.(lvar :selector).eql? ( 'string' )""")
      expect(newSource).to(eq("str.casecmp( \'string\' ).zero?"))
    test """autocorrects == str.(lvar :selector)""":
      var newSource = autocorrectSource("""'string' == str.(lvar :selector)""")
      expect(newSource).to(eq("str.casecmp(\'string\').zero?"))
    test """autocorrects string with parens == str.(lvar :selector)""":
      var newSource = autocorrectSource("""('string') == str.(lvar :selector)""")
      expect(newSource).to(eq("str.casecmp(\'string\').zero?"))
    test """autocorrects string != str.(lvar :selector)""":
      var newSource = autocorrectSource("""'string' != str.(lvar :selector)""")
      expect(newSource).to(eq("!str.casecmp(\'string\').zero?"))
    test """autocorrects string with parens and funny spacing (str "eql? str.")""":
      var newSource = autocorrectSource("""( 'string' ).eql? str.(lvar :selector)""")
      expect(newSource).to(eq("str.casecmp( \'string\' ).zero?"))
    test """autocorrects string.eql? str.(lvar :selector) without parens """:
      var newSource = autocorrectSource("""'string'.eql? str.(lvar :selector)""")
      expect(newSource).to(eq("str.casecmp(\'string\').zero?"))
    test """autocorrects string.eql? str.(lvar :selector) with parens """:
      var newSource = autocorrectSource("""'string'.eql?(str.(lvar :selector))""")
      expect(newSource).to(eq("str.casecmp(\'string\').zero?"))
    test """autocorrects obj.(lvar :selector) == str.(lvar :selector)""":
      var newSource = autocorrectSource("""obj.(lvar :selector) == str.(lvar :selector)""")
      expect(newSource).to(eq("obj.casecmp(str).zero?"))
    test """autocorrects obj.(lvar :selector) eql? str.(lvar :selector)""":
      var newSource = autocorrectSource("""obj.(lvar :selector).eql? str.(lvar :selector)""")
      expect(newSource).to(eq("obj.casecmp(str).zero?"))
    test """formats the error message correctly for str.(lvar :selector) ==""":
      inspectSource("""str.(lvar :selector) == 'string'""")
      expect(cop().highlights).to(eq(@["""str.(lvar :selector) == 'string'"""]))
      expect(cop().messages).to(eq(@["""Use `str.casecmp('string').zero?` instead of (str "`str.")"""]))
    test """formats the error message correctly for == str.(lvar :selector)""":
      inspectSource("""'string' == str.(lvar :selector)""")
      expect(cop().highlights).to(eq(@["""'string' == str.(lvar :selector)"""]))
      expect(cop().messages).to(eq(@["""Use `str.casecmp('string').zero?` instead of (str "`'string' == str.")"""]))
    test """formats the error message correctly for (str "obj.")""":
      inspectSource("""obj.(lvar :selector) == str.(lvar :selector)""")
      expect(cop().highlights).to(eq(@["""obj.(lvar :selector) == str.(lvar :selector)"""]))
      expect(cop().messages).to(eq(@["""Use `obj.casecmp(str).zero?` instead of (str "`obj.")"""]))
    test """doesn't report an offense for variable == str.(lvar :selector)""":
      expectNoOffenses("""        var = "a"
        var == str.(lvar :selector)
""".stripIndent)
    test """doesn't report an offense for str.(lvar :selector) == variable""":
      expectNoOffenses("""        var = "a"
        str.(lvar :selector) == var
""".stripIndent)
    test """doesn't report an offense for obj.method == str.(lvar :selector)""":
      expectNoOffenses("""obj.method == str.(lvar :selector)""")
    test """doesn't report an offense for str.(lvar :selector) == obj.method""":
      expectNoOffenses("""str.(lvar :selector) == obj.method"""))
  itBehavesLike("selectors", "upcase")
  itBehavesLike("selectors", "downcase")
