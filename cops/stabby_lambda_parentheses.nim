
import
  configurableEnforcedStyle

cop :
  type
    StabbyLambdaParentheses* = ref object of Cop
    ##  Check for parentheses around stabby lambda arguments.
    ##  There are two different styles. Defaults to `require_parentheses`.
    ## 
    ##  @example EnforcedStyle: require_parentheses (default)
    ##    # bad
    ##    ->a,b,c { a + b + c }
    ## 
    ##    # good
    ##    ->(a,b,c) { a + b + c}
    ## 
    ##  @example EnforcedStyle: require_no_parentheses
    ##    # bad
    ##    ->(a,b,c) { a + b + c }
    ## 
    ##    # good
    ##    ->a,b,c { a + b + c}
  const
    MSGREQUIRE = "Wrap stabby lambda arguments with parentheses."
  const
    MSGNOREQUIRE = """Do not wrap stabby lambda arguments with parentheses."""
  method onSend*(self: StabbyLambdaParentheses; node: Node): void =
    if isStabbyLambdaWithArgs(node):
    if isRedundantParentheses(node) or isMissingParentheses(node):
    addOffense(node.blockNode.arguments)

  method autocorrect*(self: StabbyLambdaParentheses; node: Node): void =
    if style == "require_parentheses":
      missingParenthesesCorrector(node)
    elif style == "require_no_parentheses":
      unwantedParenthesesCorrector(node)
  
  method isMissingParentheses*(self: StabbyLambdaParentheses; node: Node): void =
    style == "require_parentheses" and isParentheses(node).!

  method isRedundantParentheses*(self: StabbyLambdaParentheses; node: Node): void =
    style == "require_no_parentheses" and isParentheses(node)

  method message*(self: StabbyLambdaParentheses; _node: Node): void =
    if style == "require_parentheses":
      MSGREQUIRE
  
  method missingParenthesesCorrector*(self: StabbyLambdaParentheses; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var argsLoc = node.loc.expression
      corrector.insertBefore(argsLoc, "(")
      corrector.insertAfter(argsLoc, ")"))

  method unwantedParenthesesCorrector*(self: StabbyLambdaParentheses; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var argsLoc = node.loc
      corrector.replace(argsLoc.begin, "")
      corrector.remove(argsLoc.end))

  method isStabbyLambdaWithArgs*(self: StabbyLambdaParentheses; node: Node): void =
    node.isLambdaLiteral and node.blockNode.isArguments

  method isParentheses*(self: StabbyLambdaParentheses; node: Node): void =
    node.blockNode.arguments.loc.begin

