
import
  duplicated_key, test_tools

suite "DuplicatedKey":
  var cop = DuplicatedKey()
  context("when there is a duplicated key in the hash literal", proc (): void =
    test "registers an offense":
      expectOffense("""        hash = { 'otherkey' => 'value', 'key' => 'value', 'key' => 'hi' }
                                                          ^^^^^ Duplicated key in hash literal.
""".stripIndent))
  context("when there are two duplicated keys in a hash", proc (): void =
    test "registers two offenses":
      expectOffense("""        hash = { fruit: 'apple', veg: 'kale', veg: 'cuke', fruit: 'orange' }
                                              ^^^ Duplicated key in hash literal.
                                                           ^^^^^ Duplicated key in hash literal.
""".stripIndent))
  context("When a key is duplicated three times in a hash literal", proc (): void =
    test "registers two offenses":
      expectOffense("""        hash = { 1 => 2, 1 => 3, 1 => 4 }
                         ^ Duplicated key in hash literal.
                                 ^ Duplicated key in hash literal.
""".stripIndent))
  context("When there is no duplicated key in the hash", proc (): void =
    test "does not register an offense":
      expectNoOffenses("        hash = { [\'one\', \'two\'] => [\'hello, bye\'], [\'two\'] => [\'yes, no\'] }\n".stripIndent))
  sharedExamples("duplicated literal key", proc (key: string): void =
    test """registers an offense for duplicated `(lvar :key)` hash keys""":
      inspectSource("""hash = { (lvar :key) => 1, (lvar :key) => 4}""")
      expect(cop().offenses.size).to(eq(1))
      expect(cop().offenses[0].message).to(eq("Duplicated key in hash literal."))
      expect(cop().highlights).to(eq(@[key])))
  itBehavesLike("duplicated literal key", "!true")
  itBehavesLike("duplicated literal key", "\"#{2}\"")
  itBehavesLike("duplicated literal key", "(1)")
  itBehavesLike("duplicated literal key", "(false && true)")
  itBehavesLike("duplicated literal key", "(false <=> true)")
  itBehavesLike("duplicated literal key", "(false or true)")
  itBehavesLike("duplicated literal key", "[1, 2, 3]")
  itBehavesLike("duplicated literal key", "{ :a => 1, :b => 2 }")
  itBehavesLike("duplicated literal key", "{ a: 1, b: 2 }")
  itBehavesLike("duplicated literal key", "/./")
  itBehavesLike("duplicated literal key", "%r{abx}ixo")
  itBehavesLike("duplicated literal key", "1.0")
  itBehavesLike("duplicated literal key", "1")
  itBehavesLike("duplicated literal key", "false")
  itBehavesLike("duplicated literal key", "nil")
  itBehavesLike("duplicated literal key", "\'str\'")
  sharedExamples("duplicated non literal key", proc (key: string): void =
    test """does not register an offense for duplicated `(lvar :key)` hash keys""":
      expectNoOffenses("""        hash = { (lvar :key) => 1, (lvar :key) => 4}
""".stripIndent))
  itBehavesLike("duplicated non literal key", "\"#{some_method_call}\"")
  itBehavesLike("duplicated non literal key", "(x && false)")
  itBehavesLike("duplicated non literal key", "(x == false)")
  itBehavesLike("duplicated non literal key", "(x or false)")
  itBehavesLike("duplicated non literal key", "[some_method_call]")
  itBehavesLike("duplicated non literal key", "{ :sym => some_method_call }")
  itBehavesLike("duplicated non literal key", "{ some_method_call => :sym }")
  itBehavesLike("duplicated non literal key", "/.#{some_method_call}/")
  itBehavesLike("duplicated non literal key", "%r{abx#{foo}}ixo")
  itBehavesLike("duplicated non literal key", "some_method_call")
  itBehavesLike("duplicated non literal key", "some_method_call(x, y)")
