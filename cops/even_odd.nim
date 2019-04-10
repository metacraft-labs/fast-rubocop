
cop :
  type
    EvenOdd* = ref object of Cop
    ##  This cop checks for places where `Integer#even?` or `Integer#odd?`
    ##  can be used.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    if x % 2 == 0
    ##    end
    ## 
    ##    # good
    ##    if x.even?
    ##    end
  const
    MSG = "Replace with `Integer#%<method>s?`."
  nodeMatcher isEvenOddCandidate, """          (send
            {(send $_ :% (int 2))
             (begin (send $_ :% (int 2)))}
            ${:== :!=}
            (int ${0 1 2}))
"""
  method onSend*(self: EvenOdd; node: Node): void =
    isEvenOddCandidate node:
      var replacementMethod = replacementMethod(arg, method)
      addOffense(node, message = format(MSG, method = replacementMethod))

  method autocorrect*(self: EvenOdd; node: Node): void =
    isEvenOddCandidate node:
      var
        replacementMethod = replacementMethod(arg, method)
        correction = """(send
  (lvar :base_number) :source).(lvar :replacement_method)?"""
      lambda(proc (corrector: Corrector): void =
        corrector.replace(node.sourceRange, correction))

  method replacementMethod*(self: EvenOdd; arg: Integer; method: Symbol): void =
    case arg
    of 0:
      if method == "==":
        "even"
    of 1:
      if method == "==":
        "odd"
    else:

