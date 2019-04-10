
cop :
  type
    InefficientHashSearch* = ref object of Cop
  nodeMatcher isInefficientInclude,
             "          (send (send $_ {:keys :values}) :include? _)\n"
  method onSend*(self: InefficientHashSearch; node: Node): void =
    isInefficientInclude node:
      if receiver.isNil():
        return
      addOffense(node)

  method autocorrect*(self: InefficientHashSearch; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.expression, """(begin
  (send nil :autocorrect_hash_expression
    (lvar :node)))(begin
  (send nil :autocorrect_method
    (lvar :node)))"""))

  method message*(self: InefficientHashSearch; node: Node): void =
    """(str "Use `#")(str "`#")"""

  method autocorrectMethod*(self: InefficientHashSearch; node: Node): void =
    case currentMethod(node)
    of "keys":
      if useLongMethod:
        "has_key?"
    of "values":
      if useLongMethod:
        "has_value?"
    else:

  method currentMethod*(self: InefficientHashSearch; node: Node): void =
    node.receiver.methodName

  method useLongMethod*(self: InefficientHashSearch): void =
    var preferredConfig = config.forAllCops["Style/PreferredHashMethods"]
    preferredConfig and preferredConfig["EnforcedStyle"] == "long" and
        preferredConfig["Enabled"]

  method autocorrectArgument*(self: InefficientHashSearch; node: Node): void =
    node.arguments[0].source

  method autocorrectHashExpression*(self: InefficientHashSearch; node: Node): void =
    node.receiver.receiver.source

