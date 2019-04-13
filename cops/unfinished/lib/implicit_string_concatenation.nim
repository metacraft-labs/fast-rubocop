
import
  sequtils

cop :
  type
    ImplicitStringConcatenation* = ref object of Cop
  const
    MSG = """Combine %<string1>s and %<string2>s into a single string literal, rather than using implicit string concatenation."""
  const
    FORARRAY = """ Or, if they were intended to be separate array elements, separate them with a comma."""
  const
    FORMETHOD = """ Or, if they were intended to be separate method arguments, separate them with a comma."""
  method onDstr*(self: ImplicitStringConcatenation; node: Node): void =
    eachBadCons(node, proc (childNode1: Node; childNode2: Node): void =
      var
        range = childNode1.sourceRange.join(childNode2.sourceRange)
        message = format(MSG, string1 = displayStr(childNode1),
                       string2 = displayStr(childNode2))
      if node.parent and node.parent.isArrayType():
        message.<<(FORARRAY)
      elif node.parent and node.parent.isSendType():
        message.<<(FORMETHOD)
      addOffense(node, location = range, message = message))

  method eachBadCons*(self: ImplicitStringConcatenation; node: Node): void =
    node.children.eachCons(2, proc (childNode1: Node; childNode2: Node): void =
      if isStringLiterals(childNode1, childNode2):
      if childNode1.lastLine == childNode2.firstLine:
      if childNode1.source[-1] == endingDelimiter(childNode1):
      yield childNode1)

  method endingDelimiter*(self: ImplicitStringConcatenation; str: Node): void =
    if str.source[0] == "\'":
      "\'"
    elif str.source[0] == "\"":
      "\""
  
  method isStringLiteral*(self: ImplicitStringConcatenation; node: Node): void =
    node.isStrType() or
      node.isDstrType() and
          node.children.allIt:
        isStringLiteral(it)

  method isStringLiterals*(self: ImplicitStringConcatenation; node1: Node;
                          node2: Node): void =
    isStringLiteral(node1) and isStringLiteral(node2)

  method displayStr*(self: ImplicitStringConcatenation; node: Node): void =
    if node.source.=~():
      strContent(node).inspect()
    else:
      node.source
  
  method strContent*(self: ImplicitStringConcatenation; node: Node): void =
    if node.isStrType():
      node.children[0]
    else:
      node.children.mapIt:
        strContent(it).join()
  
