
import
  tables

import
  start_with, test_tools

suite "StartWith":
  var cop = StartWith()
  sharedExamples("different match methods", proc (method: string): void =
    test """autocorrects (lvar :method) /\Aabc/""":
      var newSource = autocorrectSource("""str(lvar :method) /\Aabc/""")
      expect(newSource).to(eq("str.start_with?(\'abc\')"))
    for str in @["a", "e", "f", "r", "t", "v"]:
      test """autocorrects (lvar :method) /\A\(lvar :str)/""":
        var newSource = autocorrectSource("""str(lvar :method) /\A\(lvar :str)/""")
        expect(newSource).to(eq("""str.start_with?("\(lvar :str)")"""))
    for str in @[".", "*", "?", "$", "^", "|"]:
      test """autocorrects (lvar :method) /\A\(lvar :str)/""":
        var newSource = autocorrectSource("""str(lvar :method) /\A\(lvar :str)/""")
        expect(newSource).to(eq("""str.start_with?('(lvar :str)')"""))
      test """doesn't register an error for (lvar :method) /\A(lvar :str)/""":
        expectNoOffenses("""str(lvar :method) /\A(lvar :str)/""")
    for str in @["w", "W", "s", "S", "d", "D", "A", "Z", "z", "G", "b", "B", "h", "H", "R", "X",
              "S"]:
      test """doesn't register an error for (lvar :method) /\A\(lvar :str)/""":
        expectNoOffenses("""str(lvar :method) /\A\(lvar :str)/""")
    for str in @["i", "j", "l", "m", "o", "q", "y"]:
      test """autocorrects (lvar :method) /\A\(lvar :str)/""":
        var newSource = autocorrectSource("""str(lvar :method) /\A\(lvar :str)/""")
        expect(newSource).to(eq("""str.start_with?('(lvar :str)')"""))
    test """formats the error message correctly for (lvar :method) /\Aabc/""":
      inspectSource("""str(lvar :method) /\Aabc/""")
      expect(cop().messages).to(eq(@["""Use `String#start_with?` instead of a regex match anchored to the beginning of the string."""]))
    test """autocorrects (lvar :method) /\A\\/""":
      var newSource = autocorrectSource("""str(lvar :method) /\A\\/""")
      expect(newSource).to(eq("str.start_with?(\'\\\\\')")))
  includeExamples("different match methods", ".match?")
  includeExamples("different match methods", " =~")
  includeExamples("different match methods", ".match")
  test "allows match without a receiver":
    expectNoOffenses("expect(subject.spin).to match(/\\A\\n/)")
