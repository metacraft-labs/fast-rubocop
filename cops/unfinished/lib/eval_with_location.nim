
cop :
  type
    EvalWithLocation* = ref object of Cop
    ##  This cop checks `eval` method usage. `eval` can receive source location
    ##  metadata, that are filename and line number. The metadata is used by
    ##  backtraces. This cop recommends to pass the metadata to `eval` method.
    ## 
    ##  @example
    ##    # bad
    ##    eval <<-RUBY
    ##      def do_something
    ##      end
    ##    RUBY
    ## 
    ##    # bad
    ##    C.class_eval <<-RUBY
    ##      def do_something
    ##      end
    ##    RUBY
    ## 
    ##    # good
    ##    eval <<-RUBY, binding, __FILE__, __LINE__ + 1
    ##      def do_something
    ##      end
    ##    RUBY
    ## 
    ##    # good
    ##    C.class_eval <<-RUBY, __FILE__, __LINE__ + 1
    ##      def do_something
    ##      end
    ##    RUBY
  const
    MSG = """Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces."""
  const
    MSGINCORRECTLINE = """Use `%<expected>s` instead of `%<actual>s`, as they are used by backtraces."""
  nodeMatcher isEvalWithoutLocation, """          {
            (send nil? :eval ${str dstr})
            (send nil? :eval ${str dstr} _)
            (send nil? :eval ${str dstr} _ #special_file_keyword?)
            (send nil? :eval ${str dstr} _ #special_file_keyword? _)

            (send _ {:class_eval :module_eval :instance_eval}
              ${str dstr})
            (send _ {:class_eval :module_eval :instance_eval}
              ${str dstr} #special_file_keyword?)
            (send _ {:class_eval :module_eval :instance_eval}
              ${str dstr} #special_file_keyword? _)
          }
"""
  nodeMatcher isLineWithOffset, """          {
            (send #special_line_keyword? %1 (int %2))
            (send (int %2) %1 #special_line_keyword?)
          }
"""
  method onSend*(self: EvalWithLocation; node: Node): void =
    isEvalWithoutLocation node:
      if isWithLineno(node):
        onWithLineno(node, code)
      else:
        addOffense(node)
  
  method isSpecialFileKeyword*(self: EvalWithLocation; node: Node): void =
    node.isStrType() and node.source == "__FILE__"

  method isSpecialLineKeyword*(self: EvalWithLocation; node: Node): void =
    node.isIntType() and node.source == "__LINE__"

  method isWithLineno*(self: EvalWithLocation; node: Node): void =
    ##  FIXME: It's a Style/ConditionalAssignment's false positive.
    ##  rubocop:disable Style/ConditionalAssignment
    if node.methodName == "eval":
      node.arguments.size == 4
    else:
      node.arguments.size == 3
  
  method messageIncorrectLine*(self: EvalWithLocation; actual: Node; sign: Symbol;
                              lineDiff: Integer): void =
    var expected = if lineDiff.isZero():
      "__LINE__"
    format(MSGINCORRECTLINE, actual = actual.source, expected = expected)

  method onWithLineno*(self: EvalWithLocation; node: Node; code: Node): void =
    var
      lineNode = node.arguments.last()
      linenoRange = lineNode.loc.expression
      lineDiff = stringFirstLine(code) - linenoRange.firstLine
    if lineDiff.isZero():
      addOffenseForSameLine(node, lineNode)
    else:
      addOffenseForDifferentLine(node, lineNode, lineDiff)
  
  method stringFirstLine*(self: EvalWithLocation; strNode: Node): void =
    if strNode.isHeredoc:
      strNode.loc.heredocBody.firstLine
    else:
      strNode.loc.expression.firstLine
  
  method addOffenseForSameLine*(self: EvalWithLocation; node: Node; lineNode: Node): void =
    if isSpecialLineKeyword(lineNode):
      return
    addOffense(node, location = lineNode.loc.expression,
               message = messageIncorrectLine(lineNode, 0))

  method addOffenseForDifferentLine*(self: EvalWithLocation; node: Node;
                                    lineNode: Node; lineDiff: Integer): void =
    var sign = if lineDiff > 0:
      "+"
    if isLineWithOffset lineNode, sign, lineDiff.abs():
      return
    addOffense(node, location = lineNode.loc.expression,
               message = messageIncorrectLine(lineNode, sign, lineDiff.abs()))

