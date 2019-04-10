
import
  non_nil_check, test_tools

RSpec.describe(NonNilCheck, "config", proc (): void =
  var cop = ()
  context("when not allowing semantic changes", proc (): void =
    let("cop_config", proc (): void =
      {"IncludeSemanticChanges": false}.newTable())
    test "registers an offense for != nil":
      expectOffense("""        x != nil
          ^^ Prefer `!expression.nil?` over `expression != nil`.
""".stripIndent)
    test "does not register an offense for != 0":
      expectNoOffenses("x != 0")
    test "does not register an offense for !x.nil?":
      expectNoOffenses("!x.nil?")
    test "does not register an offense for not x.nil?":
      expectNoOffenses("not x.nil?")
    test "does not register an offense if only expression in predicate":
      expectNoOffenses("""        def signed_in?
          !current_user.nil?
        end
""".stripIndent)
    test "does not register an offense if only expression in class predicate":
      expectNoOffenses("""        def Test.signed_in?
          current_user != nil
        end
""".stripIndent)
    test "does not register an offense if last expression in predicate":
      expectNoOffenses("""        def signed_in?
          something
          current_user != nil
        end
""".stripIndent)
    test "does not register an offense if last expression in class predicate":
      expectNoOffenses("""        def Test.signed_in?
          something
          current_user != nil
        end
""".stripIndent)
    test "autocorrects by changing `!= nil` to `!x.nil?`":
      var corrected = autocorrectSource("x != nil")
      expect(corrected).to(eq("!x.nil?"))
    test "does not autocorrect by removing non-nil (!x.nil?) check":
      var corrected = autocorrectSource("!x.nil?")
      expect(corrected).to(eq("!x.nil?"))
    test "does not blow up when autocorrecting implicit receiver":
      var corrected = autocorrectSource("!nil?")
      expect(corrected).to(eq("!nil?"))
    test "does not report corrected when the code was not modified":
      var
        source = "return nil unless (line =~ //) != nil"
        corrected = autocorrectSource(source)
      expect(corrected).to(eq(source))
      expect(cop().corrections.isEmpty).to(be(true)))
  context("when allowing semantic changes", proc (): void =
    var cop = ()
    let("cop_config", proc (): void =
      {"IncludeSemanticChanges": true}.newTable())
    test "registers an offense for `!x.nil?`":
      expectOffense("""        !x.nil?
        ^^^^^^^ Explicit non-nil checks are usually redundant.
""".stripIndent)
    test "registers an offense for unless x.nil?":
      expectOffense("""        puts b unless x.nil?
                      ^^^^^^ Explicit non-nil checks are usually redundant.
""".stripIndent)
    test "does not register an offense for `x.nil?`":
      expectNoOffenses("x.nil?")
    test "does not register an offense for `!x`":
      expectNoOffenses("!x")
    test "registers an offense for `not x.nil?`":
      expectOffense("""        not x.nil?
        ^^^^^^^^^^ Explicit non-nil checks are usually redundant.
""".stripIndent)
    test "does not blow up with ternary operators":
      expectNoOffenses("my_var.nil? ? 1 : 0")
    test "autocorrects by changing unless x.nil? to if x":
      var corrected = autocorrectSource("puts a unless x.nil?")
      expect(corrected).to(eq("puts a if x"))
    test "autocorrects by changing `x != nil` to `x`":
      var corrected = autocorrectSource("x != nil")
      expect(corrected).to(eq("x"))
    test "autocorrects by changing `!x.nil?` to `x`":
      var corrected = autocorrectSource("!x.nil?")
      expect(corrected).to(eq("x"))
    test "does not blow up when autocorrecting implicit receiver":
      var corrected = autocorrectSource("!nil?")
      expect(corrected).to(eq("self"))
    test """corrects code that would not be modified if IncludeSemanticChanges were false""":
      var corrected = autocorrectSource("return nil unless (line =~ //) != nil")
      expect(corrected).to(eq("return nil unless (line =~ //)"))))
