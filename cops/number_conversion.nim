
cop :
  type
    NumberConversion* = ref object of Cop
  const
    CONVERSIONMETHODCLASSMAPPING = {"to_i": """(send
  (const nil :Integer) :name)(%<number_object>s, 10)""", "to_f": """(send
  (const nil :Float) :name)(%<number_object>s)""", "to_c": """(send
  (const nil :Complex) :name)(%<number_object>s)"""}.newTable()
  const
    MSG = """Replace unsafe number conversion with number class parsing, instead of using %<number_object>s.%<to_method>s, use stricter %<corrected_method>s."""
  nodeMatcher toMethod, "          (send $_ ${:to_i :to_f :to_c})\n"
  method onSend*(self: NumberConversion; node: Node): void =
    toMethod node:
      var message = format(MSG, numberObject = receiver.source, toMethod = toMethod,
                        correctedMethod = correctMethod(node, receiver))
      addOffense(node, message = message)

  method correctMethod*(self: NumberConversion; node: Node; receiver: Node): void =
    format(CONVERSIONMETHODCLASSMAPPING[node.methodName],
           numberObject = receiver.source)

