
import
  configurableMax

import
  integerNode

cop :
  type
    NumericLiterals* = ref object of Cop
    ##  This cop checks for big numeric literals without _ between groups
    ##  of digits in them.
    ## 
    ##  @example
    ## 
    ##    # bad
    ## 
    ##    1000000
    ##    1_00_000
    ##    1_0000
    ## 
    ##    # good
    ## 
    ##    1_000_000
    ##    1000
    ## 
    ##    # good unless Strict is set
    ## 
    ##    10_000_00 # typical representation of $10,000 in cents
    ## 
  const
    MSG = """Use underscores(_) as thousands separator and separate every 3 digits with them."""
  method onInt*(self: NumericLiterals; node: Node): void =
    check(node)

  method onFloat*(self: NumericLiterals; node: Node): void =
    check(node)

  method autocorrect*(self: NumericLiterals; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, formatNumber(node)))

  method maxParameterName*(self: NumericLiterals): void =
    "MinDigits"

  method check*(self: NumericLiterals; node: Node): void =
    var int = integerPart(node)
    if int.isStartWith("0"):
      return
    if int.size >= minDigits:
    case int
    of :
      addOffense(node, proc (): void =
        self.max=(int.size & 1))
    of :
      shortGroupRegex
    else:

  method shortGroupRegex*(self: NumericLiterals): void =
    if copConfig["Strict"]:
    else:

  method formatNumber*(self: NumericLiterals; node: Node): void =
    var
      intPart = Integer(intPart)
      formattedInt = intPart.abs.toS.reverse.gsub("\\&_").reverse
    if intPart < 0:
      formattedInt.insert(0, "-")
    if floatPart:
      format("%<int>s.%<float>s", int = formattedInt, float = floatPart)
  
  method minDigits*(self: NumericLiterals): void =
    copConfig["MinDigits"]

