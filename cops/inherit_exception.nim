
import
  configurableEnforcedStyle

cop :
  type
    InheritException* = ref object of Cop
  const
    MSG = "Inherit from `%<prefer>s` instead of `%<current>s`."
  const
    PREFERREDBASECLASS = {"runtime_error": "RuntimeError",
                        "standard_error": "StandardError"}.newTable()
  const
    ILLEGALCLASSES = @["Exception", "SystemStackError", "NoMemoryError",
                     "SecurityError", "NotImplementedError", "LoadError",
                     "SyntaxError", "ScriptError", "Interrupt", "SignalException",
                     "SystemExit"]
  method onClass*(self: InheritException; node: Node): void =
    if baseClass and isIllegalClassName(baseClass):
    addOffense(baseClass)

  method autocorrect*(self: InheritException; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.expression, preferredBaseClass))

  method message*(self: InheritException; node: Node): void =
    format(MSG, prefer = preferredBaseClass, current = node.constName)

  method isIllegalClassName*(self: InheritException; classNode: Node): void =
    ILLEGALCLASSES.isInclude(classNode.constName)

  method preferredBaseClass*(self: InheritException): void =
    PREFERREDBASECLASS[style]

