
import
  types

cop MethodMissingSuper:
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
  method onDef*(self; node) =
    if not node.isMethod("method_missing"):
      return
    if node.descendants.isAny(proc (it: void) =
      it.isZsuperType):
      return
    addOffense(node)

