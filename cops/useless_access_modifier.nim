
import
  tables, sequtils

cop :
  type
    UselessAccessModifier* = ref object of Cop
  const
    MSG = "Useless `%<current>s` access modifier."
  nodeMatcher isStaticMethodDefinition, "          {def (send nil? {:attr :attr_reader :attr_writer :attr_accessor} ...)}\n"
  nodeMatcher isDynamicMethodDefinition, "          {(send nil? :define_method ...) (block (send nil? :define_method ...) ...)}\n"
  nodeMatcher isClassOrInstanceEval,
             "          (block (send _ {:class_eval :instance_eval}) ...)\n"
  nodeMatcher isClassOrModuleOrStructNewCall, "          (block (send (const nil? {:Class :Module :Struct}) :new ...) ...)\n"
  method onClass*(self: UselessAccessModifier; node: Node): void =
    checkNode(node.children[2])

  method onModule*(self: UselessAccessModifier; node: Node): void =
    checkNode(node.children[1])

  method onBlock*(self: UselessAccessModifier; node: Node): void =
    if isEvalCall(node):
    checkNode(node.body)

  method onSclass*(self: UselessAccessModifier; node: Node): void =
    checkNode(node.children[1])

  method checkNode*(self: UselessAccessModifier; node: Node): void =
    if node.isNil():
      return
    if node.isBeginType():
      checkScope(node)
    elif node.isSendType() and node.isBareAccessModifier:
      addOffense(node, message = format(MSG, current = node.methodName))
  
  method isAccessModifier*(self: UselessAccessModifier; node: Node): void =
    node.isBareAccessModifier or node.methodName == "private_class_method"

  method checkScope*(self: UselessAccessModifier; node: Node): void =
    if unused:
      addOffense(unused, message = format(MSG, current = curVis))
  
  method checkChildNodes*(self: UselessAccessModifier; node: Node; unused: NilClass;
                         curVis: Symbol): void =
    for child in node.childNodes:
      if child.isSendType() and isAccessModifier(child):
      elif isMethodDefinition(child):
        var unused
      elif isStartOfNewScope(child):
        checkScope(child)
      elif child.isDefsType().!:
    @[curVis, unused]

  method checkSendNode*(self: UselessAccessModifier; node: Node; curVis: Symbol;
                       unused: Node): void =
    if node.isBareAccessModifier:
      checkNewVisibility(node, unused, node.methodName, curVis)
    elif node.methodName == "private_class_method" and node.isArguments.!:
      addOffense(node, message = format(MSG, current = node.methodName))
      @[curVis, unused]

  method checkNewVisibility*(self: UselessAccessModifier; node: Node; unused: Node;
                            newVis: Symbol; curVis: Symbol): void =
    if newVis == curVis:
      addOffense(node, message = format(MSG, current = curVis))
    else:
      if unused:
        addOffense(unused, message = format(MSG, current = curVis))
      unused = node
    @[newVis, unused]

  method isMethodDefinition*(self: UselessAccessModifier; child: Node): void =
    isStaticMethodDefinition child or isDynamicMethodDefinition child or
        isAnyMethodDefinition(child)

  method isAnyMethodDefinition*(self: UselessAccessModifier; child: Node): void =
    copConfig.fetch("MethodCreatingMethods", @[]).anyIt:
      var matcherName = """(lvar :m)_method?""".toSym()
      if isRespondTo(matcherName):
      else:
        self.class().defNodeMatcher(matcherName, """                {def (send nil? :(lvar :m) ...)}
""")
      send(matcherName, child)

  method isStartOfNewScope*(self: UselessAccessModifier; child: Node): void =
    child.isModuleType() or child.isClassType() or child.isSclassType() or
        isEvalCall(child)

  method isEvalCall*(self: UselessAccessModifier; child: Node): void =
    isClassOrInstanceEval child or isClassOrModuleOrStructNewCall child or
        isAnyContextCreatingMethods(child)

  method isAnyContextCreatingMethods*(self: UselessAccessModifier; child: Node): void =
    copConfig.fetch("ContextCreatingMethods", @[]).anyIt:
      var matcherName = """(lvar :m)_block?""".toSym()
      if isRespondTo(matcherName):
      else:
        self.class().defNodeMatcher(matcherName, """                (block (send {nil? const} {:(lvar :m)} ...) ...)
""")
      send(matcherName, child)

