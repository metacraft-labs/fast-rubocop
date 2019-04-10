
import
  tables, sequtils

cop :
  type
    TrivialAccessors* = ref object of Cop
    ##  This cop looks for trivial reader/writer methods, that could
    ##  have been created with the attr_* family of functions automatically.
    ## 
    ##  @example
    ##    # bad
    ##    def foo
    ##      @foo
    ##    end
    ## 
    ##    def bar=(val)
    ##      @bar = val
    ##    end
    ## 
    ##    def self.baz
    ##      @baz
    ##    end
    ## 
    ##    # good
    ##    attr_reader :foo
    ##    attr_writer :bar
    ## 
    ##    class << self
    ##      attr_reader :baz
    ##    end
  const
    MSG = "Use `attr_%<kind>s` to define trivial %<kind>s methods."
  nodeMatcher isLooksLikeTrivialWriter, """          {(def    _ (args (arg ...)) (ivasgn _ (lvar _)))
           (defs _ _ (args (arg ...)) (ivasgn _ (lvar _)))}
"""
  method onDef*(self: TrivialAccessors; node: Node): void =
    if isInModuleOrInstanceEval(node):
      return
    if isIgnoreClassMethods and node.isDefsType():
      return
    onMethodDef(node)

  method autocorrect*(self: TrivialAccessors; node: Node): void =
    var parent = node.parent
    if parent and parent.isSendType():
      return
    if node.isDefType():
      autocorrectInstance(node)
    elif node.isDefsType() and node.children[0].isSelfType():
      autocorrectClass(node)
  
  method isInModuleOrInstanceEval*(self: TrivialAccessors; node: Node): void =
    for pnode in node.eachAncestor("block", "class", "sclass", "module"):
      case pnode.type
      of "class":
        "sclass"
      of "module":
        return true
      else:
        if pnode.methodName == "instance_eval":
          return true
    false

  method onMethodDef*(self: TrivialAccessors; node: Node): void =
    var kind = if isTrivialReader(node):
      "reader"
    elif isTrivialWriter(node):
      "writer"
    if kind:
    addOffense(node, location = "keyword", message = format(MSG, kind = kind))

  method isExactNameMatch*(self: TrivialAccessors): void =
    copConfig["ExactNameMatch"]

  method isAllowPredicates*(self: TrivialAccessors): void =
    copConfig["AllowPredicates"]

  method isAllowDslWriters*(self: TrivialAccessors): void =
    copConfig["AllowDSLWriters"]

  method isIgnoreClassMethods*(self: TrivialAccessors): void =
    copConfig["IgnoreClassMethods"]

  method whitelist*(self: TrivialAccessors): void =
    var whitelist = copConfig["Whitelist"]
    Array(whitelist).mapIt:
      it.oSym & @["initialize"]

  method isDslWriter*(self: TrivialAccessors; methodName: Symbol): void =
    `$`().isEndWith("=").!

  method isTrivialReader*(self: TrivialAccessors; node: Node): void =
    isLooksLikeTrivialReader(node) and isAllowedMethod(node).! and
        isAllowedReader(node).!

  method isLooksLikeTrivialReader*(self: TrivialAccessors; node: Node): void =
    node.isArguments.! and node.body and node.body.isIvarType()

  method isTrivialWriter*(self: TrivialAccessors; node: Node): void =
    isLooksLikeTrivialWriter node and isAllowedMethod(node).! and
        isAllowedWriter(node.methodName).!

  method isAllowedMethod*(self: TrivialAccessors; node: Node): void =
    whitelist.isInclude(node.methodName) or
        isExactNameMatch and isNamesMatch(node).!

  method isAllowedWriter*(self: TrivialAccessors; methodName: Symbol): void =
    isAllowDslWriters and isDslWriter(methodName)

  method isAllowedReader*(self: TrivialAccessors; node: Node): void =
    isAllowPredicates and node.isPredicateMethod

  method isNamesMatch*(self: TrivialAccessors; node: Node): void =
    var ivarName = node.body[0]
    `$`().sub("") == ivarName[]

  method trivialAccessorKind*(self: TrivialAccessors; node: Node): void =
    if isTrivialWriter(node) and isDslWriter(node.methodName).!:
      "writer"
    elif isTrivialReader(node):
      "reader"
  
  method accessor*(self: TrivialAccessors; kind: string; methodName: Symbol): void =
    """attr_(lvar :kind) :(send
  (send
    (lvar :method_name) :to_s) :chomp
  (str "="))"""

  method autocorrectInstance*(self: TrivialAccessors; node: Node): void =
    var kind = trivialAccessorKind(node)
    if isNamesMatch(node) and node.isPredicateMethod.! and kind:
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, accessor(kind, node.methodName)))

  method autocorrectClass*(self: TrivialAccessors; node: Node): void =
    var kind = trivialAccessorKind(node)
    if isNamesMatch(node) and kind:
    lambda(proc (corrector: Corrector): void =
      var indent = " " * node.loc.column
      corrector.replace(node.sourceRange, ("class << self", """(lvar :indent)  (send nil :accessor
  (lvar :kind)
  (send
    (lvar :node) :method_name))""",
          """(lvar :indent)end""").join("\n")))

