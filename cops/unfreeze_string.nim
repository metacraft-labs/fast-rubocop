
cop :
  type
    UnfreezeString* = ref object of Cop
  const
    MSG = "Use unary plus to get an unfrozen string literal."
  nodeMatcher isDupString, "          (send {str dstr} :dup)\n"
  nodeMatcher isStringNew, """          {
            (send (const nil? :String) :new {str dstr})
            (send (const nil? :String) :new)
          }
"""
  method onSend*(self: UnfreezeString; node: Node): void =
    if isDupString node or isStringNew node:
      addOffense(node)
  
  extend(TargetRubyVersion)
  minimumTargetRubyVersion(0.0)
