
cop :
  type
    EndWith* = ref object of Cop
  const
    MSG = """Use `String#end_with?` instead of a regex match anchored to the end of the string."""
  const
    SINGLEQUOTE = "\'"
  nodeMatcher isRedundantRegex, """          {(send $!nil? {:match :=~ :match?} (regexp (str $#literal_at_end?) (regopt)))
           (send (regexp (str $#literal_at_end?) (regopt)) {:match :=~} $_)}
"""
  method isLiteralAtEnd*(self: EndWith; regexStr: string): void =
    regexStr.=~()

  method onSend*(self: EndWith; node: Node): void =
    if isRedundantRegex node:
    addOffense(node)

  method autocorrect*(self: EndWith; node: Node): void =
    isRedundantRegex node:
      if receiver.isIsA(String):
      regexStr = regexStr[]
      regexStr = interpretStringEscapes(regexStr)
      lambda(proc (corrector: Corrector): void =
        var newSource = receiver.source & ".end_with?(" & toStringLiteral(regexStr) &
            ")"
        corrector.replace(node.sourceRange, newSource))

