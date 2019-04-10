
import
  parserDiagnostic

cop :
  type
    UselessElseWithoutRescue* = ref object of Cop
  const
    MSG = "`else` without `rescue` is useless."
  method isRelevantDiagnostic*(self: UselessElseWithoutRescue;
                              diagnostic: Diagnostic): void =
    diagnostic.reason == "useless_else"

  method alternativeMessage*(self: UselessElseWithoutRescue;
                            _diagnostic: Diagnostic): void =
    MSG

