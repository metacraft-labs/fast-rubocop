
cop :
  type
    UnifiedInteger* = ref object of Cop
  const
    MSG = "Use `Integer` instead of `%<klass>s`."
  nodeMatcher fixnumOrBignumConst,
             "          (:const {nil? (:cbase)} ${:Fixnum :Bignum})\n"
  method onConst*(self: UnifiedInteger; node: Node): void =
    var klass = fixnumOrBignumConst node
    if klass:
    addOffense(node, message = format(MSG, klass = klass))

  method autocorrect*(self: UnifiedInteger; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.name, "Integer"))

