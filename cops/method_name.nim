
import
  configurableNaming

cop :
  type
    MethodName* = ref object of Cop
  const
    MSG = "Use %<style>s for method names."
  method onDef*(self: MethodName; node: Node): void =
    if node.isOperatorMethod:
      return
    checkName(node, node.methodName, node.loc.name)

  method message*(self: MethodName; style: Symbol): void =
    format(MSG, style = style)

