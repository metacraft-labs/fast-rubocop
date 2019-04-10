
cop :
  type
    StringHashKeys* = ref object of Cop
    ##  This cop checks for the use of strings as keys in hashes. The use of
    ##  symbols is preferred instead.
    ## 
    ##  @example
    ##    # bad
    ##    { 'one' => 1, 'two' => 2, 'three' => 3 }
    ## 
    ##    # good
    ##    { one: 1, two: 2, three: 3 }
  const
    MSG = "Prefer symbols instead of strings as hash keys."
  nodeMatcher isStringHashKey, "          (pair (str _) _)\n"
  nodeMatcher isReceiveEnvironmentsMethod, """          {
            ^^(send (const {nil? cbase} :IO) :popen ...)
            ^^(send (const {nil? cbase} :Open3)
                {:capture2 :capture2e :capture3 :popen2 :popen2e :popen3} ...)
            ^^^(send (const {nil? cbase} :Open3)
                {:pipeline :pipeline_r :pipeline_rw :pipeline_start :pipeline_w} ...)
            ^^(send {nil? (const {nil? cbase} :Kernel)} {:spawn :system} ...)
          }
"""
  method onPair*(self: StringHashKeys; node: Node): void =
    if isStringHashKey node:
    if isReceiveEnvironmentsMethod node:
      return
    addOffense(node.key)

  method autocorrect*(self: StringHashKeys; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var symbolContent = node.strContent.toSym().inspect()
      corrector.replace(node.sourceRange, symbolContent))

