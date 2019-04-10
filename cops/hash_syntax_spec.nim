
import
  hash_syntax, test_tools

RSpec.describe(HashSyntax, "config", proc (): void =
  var cop = ()
  context("configured to enforce ruby19 style", proc (): void =
    context("with SpaceAroundOperators enabled", proc (): void =
      let("config", proc (): void =
        Config.new())
      let("cop_config", proc (): void =
        {"EnforcedStyle": "ruby19",
         "SupportedStyles": @["ruby19", "hash_rockets"],
         "UseHashRocketsWithSymbolValues": false,
         "PreferHashRocketsForNonAlnumEndingSymbols": false}.newTable().merge(
            copConfigOverrides()))
      let("cop_config_overrides", proc (): void =
        {:}.newTable())
      test "registers offense for hash rocket syntax when new is possible":
        expectOffense("""          x = { :a => 0 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "registers an offense for mixed syntax when new is possible":
        expectOffense("""          x = { :a => 0, b: 1 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "registers an offense for hash rockets in method calls":
        expectOffense("""          func(3, :a => 0)
                  ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "accepts hash rockets when keys have different types":
        expectNoOffenses("x = { :a => 0, \"b\" => 1 }")
      test "accepts an empty hash":
        expectNoOffenses("{}")
      test "registers an offense when symbol keys have strings in them":
        expectOffense("""          x = { :"string" => 0 }
                ^^^^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "preserves quotes during autocorrection":
        var newSource = autocorrectSource("{ :\'&&\' => foo }")
        expect(newSource).to(eq("{ \'&&\': foo }"))
      context("if PreferHashRocketsForNonAlnumEndingSymbols is false", proc (): void =
        test "registers an offense for hash rockets when symbols end with ?":
          expectOffense("""            x = { :a? => 0 }
                  ^^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
        test "registers an offense for hash rockets when symbols end with !":
          expectOffense("""            x = { :a! => 0 }
                  ^^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent))
      context("if PreferHashRocketsForNonAlnumEndingSymbols is true", proc (): void =
        let("cop_config_overrides", proc (): void =
          {"PreferHashRocketsForNonAlnumEndingSymbols": true}.newTable())
        test "accepts hash rockets when symbols end with ?":
          expectNoOffenses("x = { :a? => 0 }")
        test "accepts hash rockets when symbols end with !":
          expectNoOffenses("x = { :a! => 0 }"))
      test "accepts hash rockets when symbol keys end with =":
        expectNoOffenses("x = { :a= => 0 }")
      test "accepts hash rockets when symbol characters are not supported":
        expectNoOffenses("x = { :[] => 0 }")
      test "registers offense when keys start with an uppercase letter":
        expectOffense("""          x = { :A => 0 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "accepts new syntax in a hash literal":
        expectNoOffenses("x = { a: 0, b: 1 }")
      test "accepts new syntax in method calls":
        expectNoOffenses("func(3, a: 0)")
      test "auto-corrects old to new style":
        var newSource = autocorrectSource("{ :a => 1, :b   =>  2}")
        expect(newSource).to(eq("{ a: 1, b: 2}"))
      test "auto-corrects even if it interferes with SpaceAroundOperators":
        var newSource = autocorrectSource("{ :a=>1, :b=>2 }")
        expect(newSource).to(eq("{ a: 1, b: 2 }"))
      test "auto-corrects a missing space when hash is used as argument":
        var newSource = autocorrectSource("foo:bar => 1")
        expect(newSource).to(eq("foo bar: 1")))
    context("with SpaceAroundOperators disabled", proc (): void =
      let("config", proc (): void =
        Config.new())
      test "auto-corrects even if there is no space around =>":
        var newSource = autocorrectSource("{ :a=>1, :b=>2 }")
        expect(newSource).to(eq("{ a: 1, b: 2 }")))
    context("configured to use hash rockets when symbol values are found", proc (): void =
      let("config", proc (): void =
        Config.new())
      test "accepts ruby19 syntax when no elements have symbol values":
        expectNoOffenses("x = { a: 1, b: 2 }")
      test """accepts ruby19 syntax when no elements have symbol values in method calls""":
        expectNoOffenses("func(3, a: 0)")
      test "accepts an empty hash":
        expectNoOffenses("{}")
      test "registers an offense when any element uses a symbol for the value":
        expectOffense("""          x = { a: 1, b: :c }
                ^^ Use hash rockets syntax.
                      ^^ Use hash rockets syntax.
""".stripIndent)
      test """registers an offense when any element has a symbol value in method calls""":
        expectOffense("""          func(3, b: :c)
                  ^^ Use hash rockets syntax.
""".stripIndent)
      test """registers an offense when using hash rockets and no elements have a symbol value""":
        expectOffense("""          x = { :a => 1, :b => 2 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
                         ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "registers an offense for hashes with elements on multiple lines":
        expectOffense("""          x = { a: :b,
                ^^ Use hash rockets syntax.
           c: :d }
           ^^ Use hash rockets syntax.
""".stripIndent)
      test "accepts both hash rockets and ruby19 syntax in the same code":
        expectNoOffenses("""          rocket_required = { :a => :b }
          ruby19_required = { c: 3 }
""".stripIndent)
      test "auto-corrects to ruby19 style when there are no symbol values":
        var newSource = autocorrectSource("{ :a => 1, :b => 2 }")
        expect(newSource).to(eq("{ a: 1, b: 2 }"))
      test """auto-corrects to hash rockets when there is an element with a symbol value""":
        var newSource = autocorrectSource("{ a: 1, :b => :c }")
        expect(newSource).to(eq("{ :a => 1, :b => :c }"))
      test """auto-corrects to hash rockets when all elements have symbol value""":
        var newSource = autocorrectSource("{ a: :b, c: :d }")
        expect(newSource).to(eq("{ :a => :b, :c => :d }"))
      test """auto-correct does not change anything when the hash is already ruby19 style and there are no symbol values""":
        var newSource = autocorrectSource("{ a: 1, b: 2 }")
        expect(newSource).to(eq("{ a: 1, b: 2 }"))))
  context("configured to enforce hash rockets style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "hash_rockets",
       "SupportedStyles": @["ruby19", "hash_rockets"],
       "UseHashRocketsWithSymbolValues": false}.newTable())
    test "registers offense for Ruby 1.9 style":
      expectOffense("""        x = { a: 0 }
              ^^ Use hash rockets syntax.
""".stripIndent)
    test "registers an offense for mixed syntax":
      expectOffense("""        x = { a => 0, b: 1 }
                      ^^ Use hash rockets syntax.
""".stripIndent)
    test "registers an offense for 1.9 style in method calls":
      expectOffense("""        func(3, a: 0)
                ^^ Use hash rockets syntax.
""".stripIndent)
    test "accepts hash rockets in a hash literal":
      expectNoOffenses("x = { :a => 0, :b => 1 }")
    test "accepts hash rockets in method calls":
      expectNoOffenses("func(3, :a => 0)")
    test "accepts an empty hash":
      expectNoOffenses("{}")
    test "auto-corrects new style to hash rockets":
      var newSource = autocorrectSource("{ a: 1, b: 2}")
      expect(newSource).to(eq("{ :a => 1, :b => 2}"))
    context("UseHashRocketsWithSymbolValues has no impact", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyle": "hash_rockets",
         "SupportedStyles": @["ruby19", "hash_rockets"],
         "UseHashRocketsWithSymbolValues": true}.newTable())
      test "does not register an offense when there is a symbol value":
        expectNoOffenses("{ :a => :b, :c => :d }")))
  context("configured to enforce ruby 1.9 style with no mixed keys", proc (): void =
    context("UseHashRocketsWithSymbolValues disabled", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyle": "ruby19_no_mixed_keys",
         "UseHashRocketsWithSymbolValues": false}.newTable())
      test "accepts new syntax in a hash literal":
        expectNoOffenses("x = { a: 0, b: 1 }")
      test "registers offense for hash rocket syntax when new is possible":
        expectOffense("""          x = { :a => 0 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "registers an offense for mixed syntax when new is possible":
        expectOffense("""          x = { :a => 0, b: 1 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "accepts new syntax in method calls":
        expectNoOffenses("func(3, a: 0)")
      test "registers an offense for hash rockets in method calls":
        expectOffense("""          func(3, :a => 0)
                  ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "accepts hash rockets when keys have different types":
        expectNoOffenses("x = { :a => 0, \"b\" => 1 }")
      test "accepts an empty hash":
        expectNoOffenses("{}")
      test "registers an offense when keys have different types and styles":
        expectOffense("""          x = { a: 0, "b" => 1 }
                ^^ Don't mix styles in the same hash.
""".stripIndent)
        expect(cop().configToAllowOffenses).to(eq())
      test "registers an offense when keys have whitespaces in them":
        expectOffense("""          x = { :"t o" => 0 }
                ^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "registers an offense when keys have special symbols in them":
        expectOffense("""          x = { :"\tab" => 1 }
                ^^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "registers an offense when keys start with a digit":
        expectOffense("""          x = { :"1" => 1 }
                ^^^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "auto-corrects old to new style":
        var newSource = autocorrectSource("{ :a => 1, :b => 2 }")
        expect(newSource).to(eq("{ a: 1, b: 2 }"))
      test """auto-corrects to hash rockets when new style cannot be used for all""":
        var newSource = autocorrectSource("{ a: 1, \"b\" => 2 }")
        expect(newSource).to(eq("{ :a => 1, \"b\" => 2 }")))
    context("UseHashRocketsWithSymbolValues enabled", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyle": "ruby19_no_mixed_keys",
         "UseHashRocketsWithSymbolValues": true}.newTable())
      test "registers an offense when any element uses a symbol for the value":
        expectOffense("""          x = { a: 1, b: :c }
                ^^ Use hash rockets syntax.
                      ^^ Use hash rockets syntax.
""".stripIndent)
      test """registers an offense when any element has a symbol value in method calls""":
        expectOffense("""          func(3, b: :c)
                  ^^ Use hash rockets syntax.
""".stripIndent)
      test """auto-corrects to hash rockets when there is an element with a symbol value""":
        var newSource = autocorrectSource("{ a: 1, :b => :c }")
        expect(newSource).to(eq("{ :a => 1, :b => :c }"))
      test """auto-corrects to hash rockets when all elements have symbol value""":
        var newSource = autocorrectSource("{ a: :b, c: :d }")
        expect(newSource).to(eq("{ :a => :b, :c => :d }"))
      test "accepts new syntax in a hash literal":
        expectNoOffenses("x = { a: 0, b: 1 }")
      test "registers offense for hash rocket syntax when new is possible":
        expectOffense("""          x = { :a => 0 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
        expect(cop().configToAllowOffenses).to(eq())
      test "registers an offense for mixed syntax when new is possible":
        expectOffense("""          x = { :a => 0, b: 1 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
        expect(cop().configToAllowOffenses).to(eq())
      test "accepts new syntax in method calls":
        expectNoOffenses("func(3, a: 0)")
      test "registers an offense for hash rockets in method calls":
        expectOffense("""          func(3, :a => 0)
                  ^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "accepts hash rockets when keys have different types":
        expectNoOffenses("x = { :a => 0, \"b\" => 1 }")
      test "accepts an empty hash":
        expectNoOffenses("{}")
      test "registers an offense when keys have different types and styles":
        expectOffense("""          x = { a: 0, "b" => 1 }
                ^^ Don't mix styles in the same hash.
""".stripIndent)
        expect(cop().configToAllowOffenses).to(eq())
      test "registers an offense when keys have whitespaces in them":
        expectOffense("""          x = { :"t o" => 0 }
                ^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "registers an offense when keys have special symbols in them":
        expectOffense("""          x = { :"\tab" => 1 }
                ^^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "registers an offense when keys start with a digit":
        expectOffense("""          x = { :"1" => 1 }
                ^^^^^^^ Use the new Ruby 1.9 hash syntax.
""".stripIndent)
      test "auto-corrects old to new style":
        var newSource = autocorrectSource("{ :a => 1, :b => 2 }")
        expect(newSource).to(eq("{ a: 1, b: 2 }"))
      test """auto-corrects to hash rockets when new style cannot be used for all""":
        var newSource = autocorrectSource("{ a: 1, \"b\" => 2 }")
        expect(newSource).to(eq("{ :a => 1, \"b\" => 2 }"))))
  context("configured to enforce no mixed keys", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "no_mixed_keys"}.newTable())
    test "accepts new syntax in a hash literal":
      expectNoOffenses("x = { a: 0, b: 1 }")
    test "accepts the hash rocket syntax when new is possible":
      expectNoOffenses("x = { :a => 0 }")
    test "registers an offense for mixed syntax when new is possible":
      expectOffense("""        x = { :a => 0, b: 1 }
                       ^^ Don't mix styles in the same hash.
""".stripIndent)
      expect(cop().configToAllowOffenses).to(eq())
    test "accepts new syntax in method calls":
      expectNoOffenses("func(3, a: 0)")
    test "accepts hash rockets in method calls":
      expectNoOffenses("func(3, :a => 0)")
    test "accepts hash rockets when keys have different types":
      expectNoOffenses("x = { :a => 0, \"b\" => 1 }")
    test "accepts an empty hash":
      expectNoOffenses("{}")
    test "registers an offense when keys have different types and styles":
      expectOffense("""        x = { a: 0, "b" => 1 }
              ^^ Don't mix styles in the same hash.
""".stripIndent)
      expect(cop().configToAllowOffenses).to(eq())
    test "accepts hash rockets when keys have whitespaces in them":
      expectNoOffenses("x = { :\"t o\" => 0, :b => 1 }")
    test "registers an offense when keys have whitespaces and mix styles":
      expectOffense("""        x = { :"t o" => 0, b: 1 }
                           ^^ Don't mix styles in the same hash.
""".stripIndent)
      expect(cop().configToAllowOffenses).to(eq())
    test "accepts hash rockets when keys have special symbols in them":
      expectNoOffenses("x = { :\"\\tab\" => 1, :b => 1 }")
    test """registers an offense when keys have special symbols and mix styles""":
      inspectSource("x = { :\"\\tab\" => 1, b: 1 }")
      expect(cop().messages).to(eq(@["Don\'t mix styles in the same hash."]))
      expect(cop().configToAllowOffenses).to(eq())
    test "accepts hash rockets when keys start with a digit":
      expectNoOffenses("x = { :\"1\" => 1, :b => 1 }")
    test "registers an offense when keys start with a digit and mix styles":
      expectOffense("""        x = { :"1" => 1, b: 1 }
                         ^^ Don't mix styles in the same hash.
""".stripIndent)
      expect(cop().configToAllowOffenses).to(eq())
    test "does not auto-correct old to new style":
      var newSource = autocorrectSource("{ :a => 1, :b => 2 }")
      expect(newSource).to(eq("{ :a => 1, :b => 2 }"))
    test "does not auto-correct new to hash rockets style":
      var newSource = autocorrectSource("{ a: 1, b: 2 }")
      expect(newSource).to(eq("{ a: 1, b: 2 }"))
    test "auto-corrects mixed key hashes":
      var newSource = autocorrectSource("{ a: 1, :b => 2 }")
      expect(newSource).to(eq("{ a: 1, b: 2 }"))
    test """auto-corrects to hash rockets when new style cannot be used for all""":
      var newSource = autocorrectSource("{ a: 1, \"b\" => 2 }")
      expect(newSource).to(eq("{ :a => 1, \"b\" => 2 }"))))
