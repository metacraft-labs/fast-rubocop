
import
  configurableEnforcedStyle

import
  rangeHelp

cop :
  type
    ClassAndModuleChildren* = ref object of Cop
    ##  This cop checks the style of children definitions at classes and
    ##  modules. Basically there are two different styles:
    ## 
    ##  @example EnforcedStyle: nested (default)
    ##    # good
    ##    # have each child on its own line
    ##    class Foo
    ##      class Bar
    ##      end
    ##    end
    ## 
    ##  @example EnforcedStyle: compact
    ##    # good
    ##    # combine definitions as much as possible
    ##    class Foo::Bar
    ##    end
    ## 
    ##  The compact style is only forced for classes/modules with one child.
  const
    NESTEDMSG = """Use nested module/class definitions instead of compact style."""
  const
    COMPACTMSG = """Use compact module/class definition instead of nested style."""
  method onClass*(self: ClassAndModuleChildren; node: Node): void =
    if superclass and style != "nested":
      return
    checkStyle(node, body)

  method onModule*(self: ClassAndModuleChildren; node: Node): void =
    checkStyle(node, body)

  method autocorrect*(self: ClassAndModuleChildren; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if node.isClassType():
        if superclass and style != "nested":
          return
      nestOrCompact(corrector, node, name, body))

  method nestOrCompact*(self: ClassAndModuleChildren; corrector: Corrector;
                       node: Node; name: Node; body: NilClass): void =
    if style == "nested":
      nestDefinition(corrector, node)
    else:
      compactDefinition(corrector, node, name, body)
  
  method nestDefinition*(self: ClassAndModuleChildren; corrector: Corrector;
                        node: Node): void =
    var
      padding = `$`()
      paddingForTrailingEnd = padding.sub(" " * node.loc.end.column, "")
    replaceKeywordWithModule(corrector, node)
    splitOnDoubleColon(corrector, node, padding)
    addTrailingEnd(corrector, node, paddingForTrailingEnd)

  method replaceKeywordWithModule*(self: ClassAndModuleChildren;
                                  corrector: Corrector; node: Node): void =
    corrector.replace(node.loc.keyword, "module".freeze)

  method splitOnDoubleColon*(self: ClassAndModuleChildren; corrector: Corrector;
                            node: Node; padding: string): void =
    var
      childrenDefinition = node.children[0]
      range = rangeBetween(childrenDefinition.loc.doubleColon.beginPos,
                         childrenDefinition.loc.doubleColon.endPos)
      replacement = """
(lvar :padding)(send
  (send
    (send
      (lvar :node) :loc) :keyword) :source) """.freeze()
    corrector.replace(range, replacement)

  method addTrailingEnd*(self: ClassAndModuleChildren; corrector: Corrector;
                        node: Node; padding: string): void =
    var replacement = """(lvar :padding)end
(send nil :leading_spaces
  (lvar :node))end""".freeze()
    corrector.replace(node.loc.end, replacement)

  method compactDefinition*(self: ClassAndModuleChildren; corrector: Corrector;
                           node: Node; name: Node; body: Node): void =
    compactNode(corrector, node, name, body)
    removeEnd(corrector, body)

  method compactNode*(self: ClassAndModuleChildren; corrector: Corrector; node: Node;
                     name: Node; body: Node): void =
    var
      constName = """(send
  (lvar :name) :const_name)::(send
  (send
    (send
      (lvar :body) :children) :first) :const_name)"""
      replacement = """(send
  (lvar :body) :type) (lvar :const_name)"""
      range = rangeBetween(node.loc.keyword.beginPos, body.loc.name.endPos)
    corrector.replace(range, replacement)

  method removeEnd*(self: ClassAndModuleChildren; corrector: Corrector; body: Node): void =
    var range = rangeBetween(body.loc.end.beginPos - leadingSpaces(body).size,
                          body.loc.end.endPos & 1)
    corrector.remove(range)

  method leadingSpaces*(self: ClassAndModuleChildren; node: Node): void =
    node.sourceRange.sourceLine[]

  method indentWidth*(self: ClassAndModuleChildren): void =
    self.config.forCop("IndentationWidth")["Width"] or 2

  method checkStyle*(self: ClassAndModuleChildren; node: Node; body: NilClass): void =
    if style == "nested":
      checkNestedStyle(node)
    else:
      checkCompactStyle(node, body)
  
  method checkNestedStyle*(self: ClassAndModuleChildren; node: Node): void =
    if isCompactNodeName(node):
    addOffense(node, location = "name", message = NESTEDMSG)

  method checkCompactStyle*(self: ClassAndModuleChildren; node: Node; body: NilClass): void =
    if isOneChild(body) and isCompactNodeName(node).!:
    addOffense(node, location = "name", message = COMPACTMSG)

  method isOneChild*(self: ClassAndModuleChildren; body: NilClass): void =
    body and @["module", "class"].isInclude(body.type)

  method isCompactNodeName*(self: ClassAndModuleChildren; node: Node): void =
    node.loc.name.source.=~()

