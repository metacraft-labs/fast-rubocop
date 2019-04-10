
cop :
  type
    StartWith* = ref object of Cop
  const
    MSG = """Use `String#start_with?` instead of a regex match anchored to the beginning of the string."""
  const
    SINGLEQUOTE = "\'"
  nodeMatcher isRedundantRegex, """          {(send $!nil? {:match :=~ :match?} (regexp (str $#literal_at_start?) (regopt)))
           (send (regexp (str $#literal_at_start?) (regopt)) {:match :=~} $_)}
"""
  method isLiteralAtStart*(self: StartWith; regexStr: string): void =
    regexStr.=~()

  method onSend*(self: StartWith; node: Node): void =
    if isRedundantRegex node:
    addOffense(node)

  method autocorrect*(self: StartWith; node: Node): void =
    isRedundantRegex node:
      if receiver.isIsA(String):
      regexStr = regexStr[]
      regexStr = interpretStringEscapes(regexStr)
      lambda(proc (corrector: Corrector): void =
        var newSource = receiver.source & ".start_with?(" & toStringLiteral(regexStr) &
            ")"
        corrector.replace(node.sourceRange, newSource))

