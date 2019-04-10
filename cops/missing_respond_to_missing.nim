
import
  sequtils

cop :
  type
    MissingRespondToMissing* = ref object of Cop
    ##  This cop checks for the presence of `method_missing` without also
    ##  defining `respond_to_missing?`.
    ## 
    ##  @example
    ##    #bad
    ##    def method_missing(name, *args)
    ##      # ...
    ##    end
    ## 
    ##    #good
    ##    def respond_to_missing?(name, include_private)
    ##      # ...
    ##    end
    ## 
    ##    def method_missing(name, *args)
    ##      # ...
    ##    end
    ## 
  const
    MSG = "When using `method_missing`, define `respond_to_missing?`."
  method onDef*(self: MissingRespondToMissing; node: Node): void =
    if node.isMethod("method_missing"):
    if isImplementsRespondToMissing(node):
      return
    addOffense(node)

  method isImplementsRespondToMissing*(self: MissingRespondToMissing; node: Node): void =
    node.parent.eachChildNode(node.type).anyIt:
      it.isMethod("respond_to_missing?")

