
import
  zero_length_predicate, test_tools

suite "ZeroLengthPredicate":
  var cop = ZeroLengthPredicate()
  let("source", proc (): void =
    "")
  before(proc (): void =
    inspectSource(source()))
  sharedExamples("code with offense", proc (code: string; message: string;
      expected: string): void =
    context("""when checking (lvar :code)""", proc (): void =
      let("source", proc (): void =
        code)
      test "registers an offense":
        expect(cop().offenses.size).to(eq(1))
        expect(cop().offenses[0].message).to(eq(message))
        expect(cop().highlights).to(eq(@[code]))
      test "auto-corrects":
        expect(autocorrectSource(code)).to(eq(expected))))
  sharedExamples("code without offense", proc (code: string): void =
    let("source", proc (): void =
      code)
    test "does not register any offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with arrays", proc (): void =
    itBehavesLike("code with offense", "[1, 2, 3].length == 0",
                  "Use `empty?` instead of `length == 0`.", "[1, 2, 3].empty?")
    itBehavesLike("code with offense", "[1, 2, 3].size == 0",
                  "Use `empty?` instead of `size == 0`.", "[1, 2, 3].empty?")
    itBehavesLike("code with offense", "0 == [1, 2, 3].length",
                  "Use `empty?` instead of `0 == length`.", "[1, 2, 3].empty?")
    itBehavesLike("code with offense", "0 == [1, 2, 3].size",
                  "Use `empty?` instead of `0 == size`.", "[1, 2, 3].empty?")
    itBehavesLike("code with offense", "[1, 2, 3].length < 1",
                  "Use `empty?` instead of `length < 1`.", "[1, 2, 3].empty?")
    itBehavesLike("code with offense", "[1, 2, 3].size < 1",
                  "Use `empty?` instead of `size < 1`.", "[1, 2, 3].empty?")
    itBehavesLike("code with offense", "1 > [1, 2, 3].length",
                  "Use `empty?` instead of `1 > length`.", "[1, 2, 3].empty?")
    itBehavesLike("code with offense", "1 > [1, 2, 3].size",
                  "Use `empty?` instead of `1 > size`.", "[1, 2, 3].empty?")
    itBehavesLike("code with offense", "[1, 2, 3].length > 0",
                  "Use `!empty?` instead of `length > 0`.", "![1, 2, 3].empty?")
    itBehavesLike("code with offense", "[1, 2, 3].size > 0",
                  "Use `!empty?` instead of `size > 0`.", "![1, 2, 3].empty?")
    itBehavesLike("code with offense", "[1, 2, 3].length != 0",
                  "Use `!empty?` instead of `length != 0`.", "![1, 2, 3].empty?")
    itBehavesLike("code with offense", "[1, 2, 3].size != 0",
                  "Use `!empty?` instead of `size != 0`.", "![1, 2, 3].empty?")
    itBehavesLike("code with offense", "0 < [1, 2, 3].length",
                  "Use `!empty?` instead of `0 < length`.", "![1, 2, 3].empty?")
    itBehavesLike("code with offense", "0 < [1, 2, 3].size",
                  "Use `!empty?` instead of `0 < size`.", "![1, 2, 3].empty?")
    itBehavesLike("code with offense", "0 != [1, 2, 3].length",
                  "Use `!empty?` instead of `0 != length`.", "![1, 2, 3].empty?")
    itBehavesLike("code with offense", "0 != [1, 2, 3].size",
                  "Use `!empty?` instead of `0 != size`.", "![1, 2, 3].empty?"))
  context("with hashes", proc (): void =
    itBehavesLike("code with offense", "{ a: 1, b: 2 }.size == 0",
                  "Use `empty?` instead of `size == 0`.", "{ a: 1, b: 2 }.empty?")
    itBehavesLike("code with offense", "0 == { a: 1, b: 2 }.size",
                  "Use `empty?` instead of `0 == size`.", "{ a: 1, b: 2 }.empty?")
    itBehavesLike("code with offense", "{ a: 1, b: 2 }.size != 0",
                  "Use `!empty?` instead of `size != 0`.",
                  "!{ a: 1, b: 2 }.empty?")
    itBehavesLike("code with offense", "0 != { a: 1, b: 2 }.size",
                  "Use `!empty?` instead of `0 != size`.",
                  "!{ a: 1, b: 2 }.empty?"))
  context("with strings", proc (): void =
    itBehavesLike("code with offense", "\"string\".size == 0",
                  "Use `empty?` instead of `size == 0`.", "\"string\".empty?")
    itBehavesLike("code with offense", "0 == \"string\".size",
                  "Use `empty?` instead of `0 == size`.", "\"string\".empty?")
    itBehavesLike("code with offense", "\"string\".size != 0",
                  "Use `!empty?` instead of `size != 0`.", "!\"string\".empty?")
    itBehavesLike("code with offense", "0 != \"string\".size",
                  "Use `!empty?` instead of `0 != size`.", "!\"string\".empty?"))
  context("with collection variables", proc (): void =
    itBehavesLike("code with offense", "collection.size == 0",
                  "Use `empty?` instead of `size == 0`.", "collection.empty?")
    itBehavesLike("code with offense", "0 == collection.size",
                  "Use `empty?` instead of `0 == size`.", "collection.empty?")
    itBehavesLike("code with offense", "collection.size != 0",
                  "Use `!empty?` instead of `size != 0`.", "!collection.empty?")
    itBehavesLike("code with offense", "0 != collection.size",
                  "Use `!empty?` instead of `0 != size`.", "!collection.empty?"))
  context("when name of the variable is `size` or `length`", proc (): void =
    itBehavesLike("code without offense", "size == 0")
    itBehavesLike("code without offense", "length == 0")
    itBehavesLike("code without offense", "0 == size")
    itBehavesLike("code without offense", "0 == length")
    itBehavesLike("code without offense", "size <= 0")
    itBehavesLike("code without offense", "length > 0")
    itBehavesLike("code without offense", "0 <= size")
    itBehavesLike("code without offense", "0 > length")
    itBehavesLike("code without offense", "size != 0")
    itBehavesLike("code without offense", "length != 0")
    itBehavesLike("code without offense", "0 != size")
    itBehavesLike("code without offense", "0 != length"))
  context("when inspecting a File::Stat object", proc (): void =
    test "does not register an offense":
      expectNoOffenses("        File.stat(foo).size == 0\n".stripIndent))
  context("when inspecting a StringIO object", proc (): void =
    context("when initialized with a string", proc (): void =
      test "does not register an offense":
        expectNoOffenses("          StringIO.new(\'foo\').size == 0\n".stripIndent))
    context("when initialized without arguments", proc (): void =
      test "does not register an offense":
        expectNoOffenses("          StringIO.new.size == 0\n".stripIndent)))
  context("when inspecting a Tempfile object", proc (): void =
    test "does not register an offense":
      expectNoOffenses("        Tempfile.new(\'foo\').size == 0\n".stripIndent))
