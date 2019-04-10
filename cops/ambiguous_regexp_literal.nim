
import
  parserDiagnostic

cop :
  type
    AmbiguousRegexpLiteral* = ref object of Cop
  const
    MSG = """Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division."""
  method isRelevantDiagnostic*(self: AmbiguousRegexpLiteral; diagnostic: Diagnostic): void =
    diagnostic.reason == "ambiguous_literal"

  method alternativeMessage*(self: AmbiguousRegexpLiteral; _diagnostic: Diagnostic): void =
    MSG

