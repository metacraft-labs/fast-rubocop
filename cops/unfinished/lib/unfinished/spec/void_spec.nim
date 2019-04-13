
import
  tables

import
  void, test_tools

suite "Void":
  var cop = Void()
  let("config", proc (): void =
    Config.new)
  for op in BINARYOPERATORS:
    test """registers an offense for void op (lvar :op) if not on last line""":
      inspectSource("""        a (lvar :op) b
        a (lvar :op) b
        a (lvar :op) b
""".stripIndent)
      expect(cop().offenses.size).to(eq(2))
  for op in BINARYOPERATORS:
    test """accepts void op (lvar :op) if on last line""":
      expectNoOffenses("""        something
        a (lvar :op) b
""".stripIndent)
  for op in BINARYOPERATORS:
    test """accepts void op (lvar :op) by itself without a begin block""":
      expectNoOffenses("""a (lvar :op) b""")
  var unaryOperators = @["+", "-", "~", "!"]
  for op in unaryOperators:
    test """registers an offense for void op (lvar :op) if not on last line""":
      inspectSource("""        (lvar :op)b
        (lvar :op)b
        (lvar :op)b
""".stripIndent)
      expect(cop().offenses.size).to(eq(2))
  for op in unaryOperators:
    test """accepts void op (lvar :op) if on last line""":
      expectNoOffenses("""        something
        (lvar :op)b
""".stripIndent)
  for op in unaryOperators:
    test """accepts void op (lvar :op) by itself without a begin block""":
      expectNoOffenses("""(lvar :op)b""")
  for var in @["var", "@var", "@@var", "VAR", "$var"]:
    test """registers an offense for void var (lvar :var) if not on last line""":
      inspectSource("""                       (lvar :var) = 5
                       (lvar :var)
                       top
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
  for lit in @["1", "2.0", ":test", "/test/", "[1]", "{}"]:
    test """registers an offense for void lit (lvar :lit) if not on last line""":
      inspectSource("""                        (lvar :lit)
                        top
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
  test "registers an offense for void `self` if not on last line":
    expectOffense("""      self; top
      ^^^^ `self` used in void context.
""".stripIndent)
  test "registers an offense for void `defined?` if not on last line":
    expectOffense("""      defined?(x)
      ^^^^^^^^^^^ `defined?(x)` used in void context.
      top
""".stripIndent)
  context("when checking for methods with no side effects", proc (): void =
    let("config", proc (): void =
      Config.new())
    test "registers an offense if not on last line":
      expectOffense("""        x.sort
        ^^^^^^ Method `#sort` used in void context. Did you mean `#sort!`?
        top(x)
""".stripIndent)
    test "registers an offense for chained methods":
      expectOffense("""        x.sort.flatten
        ^^^^^^^^^^^^^^ Method `#flatten` used in void context. Did you mean `#flatten!`?
        top(x)
""".stripIndent))
  context("when not checking for methods with no side effects", proc (): void =
    let("config", proc (): void =
      Config.new())
    test "does not register an offense for void nonmutating methods":
      expectNoOffenses("""        x.sort
        top(x)
""".stripIndent))
  test "registers an offense for void literal in a method definition":
    expectOffense("""      def something
        42
        ^^ Literal `42` used in void context.
        42
      end
""".stripIndent)
  test "registers two offenses for void literals in an initialize method":
    expectOffense("""      def initialize
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
""".stripIndent)
  test "registers two offenses for void literals in a setter method":
    expectOffense("""      def foo=(rhs)
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
""".stripIndent)
  test "registers two offenses for void literals in a `#each` method":
    expectOffense("""      array.each do |_item|
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
""".stripIndent)
  test "handles `#each` block with single expression":
    expectOffense("""      array.each do |_item|
        42
        ^^ Literal `42` used in void context.
      end
""".stripIndent)
  test "handles empty block":
    expectNoOffenses("      array.each { |_item| }\n".stripIndent)
  test "registers two offenses for void literals in `#tap` method":
    expectOffense("""      foo.tap do |x|
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
""".stripIndent)
  test "registers two offenses for void literals in a `for`":
    expectOffense("""      for _item in array do
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
""".stripIndent)
  test "handles explicit begin blocks":
    expectOffense("""      begin
       1
       ^ Literal `1` used in void context.
       2
      end
""".stripIndent)
  test "accepts short call syntax":
    expectNoOffenses("""      lambda.(a)
      top
""".stripIndent)
  test "accepts backtick commands":
    expectNoOffenses("""      `touch x`
      nil
""".stripIndent)
  test "accepts percent-x commands":
    expectNoOffenses("""      %x(touch x)
      nil
""".stripIndent)
