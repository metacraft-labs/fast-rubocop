
import
  chain_array_allocation, test_tools

RSpec.describe(ChainArrayAllocation, "config", proc (): void =
  var cop = ()
  sharedExamples("map_and_flat", proc (method: string; methodTwo: string): void =
    test """registers an offense when calling (lvar :method)...(lvar :method_two)""":
      inspectSource("""[1, 2, 3, 4].(lvar :method) { |e| [e, e] }.(lvar :method_two)""")
      expect(cop().messages).to(eq(@[generateMessage(method, methodTwo)]))
      expect(cop().highlights).to(eq(@[""".(lvar :method_two)"""])))
  describe("configured to only warn when flattening one level", proc (): void =
    itBehavesLike("map_and_flat", "map", "flatten"))
  describe("Methods that require an argument", proc (): void =
    test "first":
      inspectSource("[1, 2, 3, 4].first.uniq")
      expect(cop().messages.isEmpty).to(be(true))
      inspectSource("[1, 2, 3, 4].first(10).uniq")
      expect(cop().messages.isEmpty).to(be(false))
      expect(cop().messages).to(eq(@[generateMessage("first", "uniq")]))
      expect(cop().highlights).to(eq(@[".uniq"]))
      inspectSource("[1, 2, 3, 4].first(variable).uniq")
      expect(cop().messages.isEmpty).to(be(false))
      expect(cop().messages).to(eq(@[generateMessage("first", "uniq")]))
      expect(cop().highlights).to(eq(@[".uniq"])))
  describe("methods that only return an array with no block", proc (): void =
    test "zip":
      inspectSource("[1, 2, 3, 4].zip {|f| }.uniq")
      expect(cop().messages.isEmpty).to(be(true))
      inspectSource("[1, 2, 3, 4].zip.uniq")
      expect(cop().messages.isEmpty).to(be(false))))
