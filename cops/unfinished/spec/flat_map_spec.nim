
import
  flat_map, test_tools

RSpec.describe(FlatMap, "config", proc (): void =
  var cop = ()
  sharedExamples("map_and_collect", proc (method: string; flatten: string): void =
    test """registers an offense when calling (lvar :method)...(lvar :flatten)(1)""":
      inspectSource("""[1, 2, 3, 4].(lvar :method) { |e| [e, e] }.(lvar :flatten)(1)""")
      expect(cop().messages).to(eq(@["""Use `flat_map` instead of `(lvar :method)...(lvar :flatten)`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :method) { |e| [e, e] }.(lvar :flatten)(1)"""]))
    test """(str "does not register an offense when calling ")with a number greater than 1""":
      expectNoOffenses("""[1, 2, 3, 4].(lvar :method) { |e| [e, e] }.(lvar :flatten)(3)""")
    test """does not register an offense when calling (lvar :method)!...(lvar :flatten)""":
      expectNoOffenses("""[1, 2, 3, 4].(lvar :method)! { |e| [e, e] }.(lvar :flatten)""")
    test """corrects (lvar :method)..(lvar :flatten)(1) to flat_map""":
      var
        source = """[1, 2].(lvar :method) { |e| [e, e] }.(lvar :flatten)(1)"""
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("[1, 2].flat_map { |e| [e, e] }")))
  describe("configured to only warn when flattening one level", proc (): void =
    let("config", proc (): void =
      Config.new())
    sharedExamples("flatten_with_params_disabled", proc (method: string;
        flatten: string): void =
      test """does not register an offense when calling (lvar :method)...(lvar :flatten)""":
        expectNoOffenses("""[1, 2, 3, 4].map { |e| [e, e] }.(lvar :flatten)"""))
    itBehavesLike("map_and_collect", "map", "flatten")
    itBehavesLike("map_and_collect", "map", "flatten!")
    itBehavesLike("map_and_collect", "collect", "flatten")
    itBehavesLike("map_and_collect", "collect", "flatten!")
    itBehavesLike("flatten_with_params_disabled", "map", "flatten")
    itBehavesLike("flatten_with_params_disabled", "collect", "flatten")
    itBehavesLike("flatten_with_params_disabled", "map", "flatten!")
    itBehavesLike("flatten_with_params_disabled", "collect", "flatten!"))
  describe("configured to warn when flatten is not called with parameters", proc (): void =
    let("config", proc (): void =
      Config.new())
    sharedExamples("flatten_with_params_enabled", proc (method: string;
        flatten: string): void =
      test """registers an offense when calling (lvar :method)...(lvar :flatten)""":
        inspectSource("""[1, 2, 3, 4].map { |e| [e, e] }.(lvar :flatten)""")
        expect(cop().messages).to(eq(@["""(str "Use `flat_map` instead of `map...")Beware, `flat_map` only flattens 1 level and `flatten` can be used to flatten multiple levels."""]))
        expect(cop().highlights).to(eq(@[
            """map { |e| [e, e] }.(lvar :flatten)"""]))
      test """will not correct (lvar :method)..(lvar :flatten) to flat_map""":
        var
          source = """[1, 2].map { |e| [e, e] }.(lvar :flatten)"""
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""[1, 2].map { |e| [e, e] }.(lvar :flatten)""")))
    itBehavesLike("map_and_collect", "map", "flatten")
    itBehavesLike("map_and_collect", "map", "flatten!")
    itBehavesLike("map_and_collect", "collect", "flatten")
    itBehavesLike("map_and_collect", "collect", "flatten!")
    itBehavesLike("flatten_with_params_enabled", "map", "flatten")
    itBehavesLike("flatten_with_params_enabled", "collect", "flatten")
    itBehavesLike("flatten_with_params_enabled", "map", "flatten!")
    itBehavesLike("flatten_with_params_enabled", "collect", "flatten!")))
