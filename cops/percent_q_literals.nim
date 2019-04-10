
import
  percentLiteral

import
  configurableEnforcedStyle

cop :
  type
    PercentQLiterals* = ref object of Cop
    ##  This cop checks for usage of the %Q() syntax when %q() would do.
    ## 
    ##  @example EnforcedStyle: lower_case_q (default)
    ##    # The `lower_case_q` style prefers `%q` unless
    ##    # interpolation is needed.
    ##    # bad
    ##    %Q[Mix the foo into the baz.]
    ##    %Q(They all said: 'Hooray!')
    ## 
    ##    # good
    ##    %q[Mix the foo into the baz]
    ##    %q(They all said: 'Hooray!')
    ## 
    ##  @example EnforcedStyle: upper_case_q
    ##    # The `upper_case_q` style requires the sole use of `%Q`.
    ##    # bad
    ##    %q/Mix the foo into the baz./
    ##    %q{They all said: 'Hooray!'}
    ## 
    ##    # good
    ##    %Q/Mix the foo into the baz./
    ##    %Q{They all said: 'Hooray!'}
  const
    LOWERCASEQMSG = """Do not use `%Q` unless interpolation is needed. Use `%q`."""
  const
    UPPERCASEQMSG = "Use `%Q` instead of `%q`."
  method onStr*(self: PercentQLiterals; node: Node): void =
    process(node, "%Q", "%q")

  method autocorrect*(self: PercentQLiterals; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, corrected(node.source)))

  method onPercentLiteral*(self: PercentQLiterals; node: Node): void =
    if isCorrectLiteralStyle(node):
      return
    if node.children != parse(corrected(node.source)).ast.children:
      return
    addOffense(node, location = "begin")

  method isCorrectLiteralStyle*(self: PercentQLiterals; node: Node): void =
    style == "lower_case_q" and type(node) == "%q" or
        style == "upper_case_q" and type(node) == "%Q"

  method message*(self: PercentQLiterals; _node: Node): void =
    if style == "lower_case_q":
      LOWERCASEQMSG
  
  method corrected*(self: PercentQLiterals; src: string): void =
    src.sub(src[1], src[1].swapcase())

