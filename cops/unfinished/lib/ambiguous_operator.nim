
import
  tables

import
  parserDiagnostic

cop :
  type
    AmbiguousOperator* = ref object of Cop
  const
    AMBIGUITIES = for key, hash in {"+": {"actual": "positive number",
                                   "possible": "addition"}.newTable(), "-": {
        "actual": "negative number", "possible": "subtraction"}.newTable(), "*": {
        "actual": "splat", "possible": "multiplication"}.newTable(), "&": {
        "actual": "block", "possible": "binary AND"}.newTable(), "**": {
        "actual": "keyword splat", "possible": "exponent"}.newTable()}.newTable():
      hash.[]=("operator", key)
  const
    MSGFORMAT = """Ambiguous %<actual>s operator. Parenthesize the method arguments if it's surely a %<actual>s operator, or add a whitespace to the right of the `%<operator>s` if it should be a %<possible>s."""
  method isRelevantDiagnostic*(self: AmbiguousOperator; diagnostic: Diagnostic): void =
    diagnostic.reason == "ambiguous_prefix"

  method alternativeMessage*(self: AmbiguousOperator; diagnostic: Diagnostic): void =
    var
      operator = diagnostic.location.source
      hash = AMBIGUITIES[operator]
    format(MSGFORMAT, hash)

