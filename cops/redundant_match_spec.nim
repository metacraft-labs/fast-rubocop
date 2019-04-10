
import
  redundant_match, test_tools

suite "RedundantMatch":
  var cop = RedundantMatch()
  test "autocorrects .match in if condition":
    var newSource = autocorrectSource("something if str.match(/regex/)")
    expect(newSource).to(eq("something if str =~ /regex/"))
  test "autocorrects .match in unless condition":
    var newSource = autocorrectSource("something unless str.match(/regex/)")
    expect(newSource).to(eq("something unless str =~ /regex/"))
  test "autocorrects .match in while condition":
    var newSource = autocorrectSource("""      while str.match(/regex/)
        do_something
      end
""".stripIndent)
    expect(newSource).to(eq("""      while str =~ /regex/
        do_something
      end
""".stripIndent))
  test "autocorrects .match in until condition":
    var newSource = autocorrectSource("""      until str.match(/regex/)
        do_something
      end
""".stripIndent)
    expect(newSource).to(eq("""      until str =~ /regex/
        do_something
      end
""".stripIndent))
  test "autocorrects .match in method body (but not tail position)":
    var newSource = autocorrectSource("""      def method(str)
        str.match(/regex/)
        true
      end
""".stripIndent)
    expect(newSource).to(eq("""      def method(str)
        str =~ /regex/
        true
      end
""".stripIndent))
  test "does not autocorrect if .match has a string agrgument":
    var newSource = autocorrectSource("something if str.match(\"string\")")
    expect(newSource).to(eq("something if str.match(\"string\")"))
  test """does not register an error when return value of .match is passed to another method""":
    expectNoOffenses("""      def method(str)
       something(str.match(/regex/))
      end
""".stripIndent)
  test """does not register an error when return value of .match is stored in an instance variable""":
    expectNoOffenses("""      def method(str)
       @var = str.match(/regex/)
       true
      end
""".stripIndent)
  test """does not register an error when return value of .match is returned from surrounding method""":
    expectNoOffenses("""      def method(str)
       str.match(/regex/)
      end
""".stripIndent)
  test "does not register an offense when match has a block":
    expectNoOffenses("""      /regex/.match(str) do |m|
        something(m)
      end
""".stripIndent)
  test "does not register an error when there is no receiver to the match call":
    expectNoOffenses("match(\"bar\")")
  test "formats error message correctly for something if str.match(/regex/)":
    expectOffense("""      something if str.match(/regex/)
                   ^^^^^^^^^^^^^^^^^^ Use `=~` in places where the `MatchData` returned by `#match` will not be used.
""".stripIndent)
