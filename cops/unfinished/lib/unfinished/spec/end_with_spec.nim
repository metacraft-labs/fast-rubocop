
import
  tables

import
  end_with, test_tools

suite "EndWith":
  var cop = EndWith()
  sharedExamples("different match methods", proc (method: string): void =
    test """autocorrects (lvar :method) /abc\z/""":
      var newSource = autocorrectSource("""str(lvar :method) /abc\z/""")
      expect(newSource).to(eq("str.end_with?(\'abc\')"))
    test """autocorrects (lvar :method) /\n\z/""":
      var newSource = autocorrectSource("""str(lvar :method) /\n\z/""")
      expect(newSource).to(eq("str.end_with?(\"\\n\")"))
    test """autocorrects (lvar :method) /\t\z/""":
      var newSource = autocorrectSource("""str(lvar :method) /\t\z/""")
      expect(newSource).to(eq("str.end_with?(\"\\t\")"))
    for str in @[".", "$", "^", "|"]:
      test """autocorrects (lvar :method) /\(lvar :str)\z/""":
        var newSource = autocorrectSource("""str(lvar :method) /\(lvar :str)\z/""")
        expect(newSource).to(eq("""str.end_with?('(lvar :str)')"""))
      test """doesn't register an error for (lvar :method) /(lvar :str)\z/""":
        expectNoOffenses("""str(lvar :method) /(lvar :str)\z/""")
    for str in @["a", "e", "f", "r", "t", "v"]:
      test """autocorrects (lvar :method) /\(lvar :str)\z/""":
        var newSource = autocorrectSource("""str(lvar :method) /\(lvar :str)\z/""")
        expect(newSource).to(eq("""str.end_with?("\(lvar :str)")"""))
    for str in @["w", "W", "s", "S", "d", "D", "A", "Z", "z", "G", "b", "B", "h", "H", "R", "X",
              "S"]:
      test """doesn't register an error for (lvar :method) /\(lvar :str)\z/""":
        expectNoOffenses("""str(lvar :method) /\(lvar :str)\z/""")
    for str in @["i", "j", "l", "m", "o", "q", "y"]:
      test """autocorrects (lvar :method) /\(lvar :str)\z/""":
        var newSource = autocorrectSource("""str(lvar :method) /\(lvar :str)\z/""")
        expect(newSource).to(eq("""str.end_with?('(lvar :str)')"""))
    test """formats the error message correctly for (lvar :method) /abc\z/""":
      inspectSource("""str(lvar :method) /abc\z/""")
      expect(cop().messages).to(eq(@["""Use `String#end_with?` instead of a regex match anchored to the end of the string."""]))
    test """autocorrects (lvar :method) /\\\z/""":
      var newSource = autocorrectSource("""str(lvar :method) /\\\z/""")
      expect(newSource).to(eq("str.end_with?(\'\\\\\')")))
  includeExamples("different match methods", ".match?")
  includeExamples("different match methods", " =~")
  includeExamples("different match methods", ".match")
  test "allows match without a receiver":
    expectNoOffenses("expect(subject.spin).to match(/\\n\\z/)")
