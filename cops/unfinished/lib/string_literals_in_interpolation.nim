
import
  configurableEnforcedStyle

import
  stringLiteralsHelp

cop :
  type
    StringLiteralsInInterpolation* = ref object of Cop
    ##  This cop checks that quotes inside the string interpolation
    ##  match the configured preference.
    ## 
    ##  @example EnforcedStyle: single_quotes (default)
    ##    # bad
    ##    result = "Tests #{success ? "PASS" : "FAIL"}"
    ## 
    ##    # good
    ##    result = "Tests #{success ? 'PASS' : 'FAIL'}"
    ## 
    ##  @example EnforcedStyle: double_quotes
    ##    # bad
    ##    result = "Tests #{success ? 'PASS' : 'FAIL'}"
    ## 
    ##    # good
    ##    result = "Tests #{success ? "PASS" : "FAIL"}"
  method autocorrect*(self: StringLiteralsInInterpolation; node: Node): void =
    StringLiteralCorrector.correct(node, style)

  method message*(self: StringLiteralsInInterpolation; _node: Node): void =
    var kind = `$`().sub("-\\1d")
    """Prefer (lvar :kind) strings inside interpolations."""

  method isOffense*(self: StringLiteralsInInterpolation; node: Node): void =
    if isInsideInterpolation(node):
    else:
      return false
    isWrongQuotes(node)

