
import
  sequtils

import
  configurableEnforcedStyle

cop :
  type
    Lambda* = ref object of Cop
    ##  This cop (by default) checks for uses of the lambda literal syntax for
    ##  single line lambdas, and the method call syntax for multiline lambdas.
    ##  It is configurable to enforce one of the styles for both single line
    ##  and multiline lambdas as well.
    ## 
    ##  @example EnforcedStyle: line_count_dependent (default)
    ##    # bad
    ##    f = lambda { |x| x }
    ##    f = ->(x) do
    ##          x
    ##        end
    ## 
    ##    # good
    ##    f = ->(x) { x }
    ##    f = lambda do |x|
    ##          x
    ##        end
    ## 
    ##  @example EnforcedStyle: lambda
    ##    # bad
    ##    f = ->(x) { x }
    ##    f = ->(x) do
    ##          x
    ##        end
    ## 
    ##    # good
    ##    f = lambda { |x| x }
    ##    f = lambda do |x|
    ##          x
    ##        end
    ## 
    ##  @example EnforcedStyle: literal
    ##    # bad
    ##    f = lambda { |x| x }
    ##    f = lambda do |x|
    ##          x
    ##        end
    ## 
    ##    # good
    ##    f = ->(x) { x }
    ##    f = ->(x) do
    ##          x
    ##        end
  const
    LITERALMESSAGE = """Use the `-> { ... }` lambda literal syntax for %<modifier>s lambdas."""
  const
    METHODMESSAGE = """Use the `lambda` method for %<modifier>s lambdas."""
  const
    OFFENDINGSELECTORS = {"style": {"lambda": {"single_line": "->", "multiline": "->"}.newTable(), "literal": {
        "single_line": "lambda", "multiline": "lambda"}.newTable(), "line_count_dependent": {
        "single_line": "lambda", "multiline": "->"}.newTable()}.newTable()}.newTable()
  nodeMatcher isLambdaNode, "(block $(send nil? :lambda) ...)"
  method onBlock*(self: Lambda; node: Node): void =
    if node.isLambda:
    var selector = node.sendNode.source
    if isOffendingSelector(node, selector):
    addOffense(node, location = node.sendNode.sourceRange,
               message = message(node, selector))

  method autocorrect*(self: Lambda; node: Node): void =
    if node.sendNode.source == "lambda":
      lambda(proc (corrector: Corrector): void =
        autocorrectMethodToLiteral(corrector, node))
    else:
      LambdaLiteralToMethodCorrector.new(node)
  
  method isOffendingSelector*(self: Lambda; node: Node; selector: string): void =
    var lines = if node.isMultiline:
      "multiline"
    selector == OFFENDINGSELECTORS["style"][style][lines]

  method message*(self: Lambda; node: Node; selector: string): void =
    var message = if selector == "->":
      METHODMESSAGE
    format(message, modifier = messageLineModifier(node))

  method messageLineModifier*(self: Lambda; node: Node): void =
    case style
    of "line_count_dependent":
      if node.isMultiline:
        "multiline"
    else:
      "all"
  
  method autocorrectMethodToLiteral*(self: Lambda; corrector: Corrector; node: Node): void =
    corrector.replace(blockMethod.sourceRange, "->")
    if args.children.isEmpty:
      return
    var
      argStr = """((send nil :lambda_arg_string
  (lvar :args)))"""
      whitespaceAndOldArgs = node.loc.begin.end.join(args.loc.end)
    corrector.insertAfter(blockMethod.sourceRange, argStr)
    corrector.remove(whitespaceAndOldArgs)

  method lambdaArgString*(self: Lambda; args: Node): void =
    args.children.mapIt:
      it.ource.join(", ")

