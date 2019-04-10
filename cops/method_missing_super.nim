
import
  sequtils

cop :
  type
    MethodMissingSuper* = ref object of Cop
    ##  This cop checks for the presence of `method_missing` without
    ##  falling back on `super`.
    ## 
    ##  @example
    ##    #bad
    ##    def method_missing(name, *args)
    ##      # ...
    ##    end
    ## 
    ##    #good
    ## 
    ##    def method_missing(name, *args)
    ##      # ...
    ##      super
    ##    end
  const
    MSG = "When using `method_missing`, fall back on `super`."
  method onDef*(self: MethodMissingSuper; node: Node): void =
    if node.isMethod("method_missing"):
    if node.descendants.anyIt:
      it.isSuperType:
      return
    addOffense(node)

