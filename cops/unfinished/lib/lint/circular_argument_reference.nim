
import
  types

cop CircularArgumentReference:
  ##  This cop checks for circular argument references in optional keyword
  ##  arguments and optional ordinal arguments.
  ## 
  ##  This cop mirrors a warning produced by MRI since 2.2.
  ## 
  ##  @example
  ## 
  ##    # bad
  ## 
  ##    def bake(pie: pie)
  ##      pie.heat_up
  ##    end
  ## 
  ##  @example
  ## 
  ##    # good
  ## 
  ##    def bake(pie:)
  ##      pie.refrigerate
  ##    end
  ## 
  ##  @example
  ## 
  ##    # good
  ## 
  ##    def bake(pie: self.pie)
  ##      pie.feed_to(user)
  ##    end
  ## 
  ##  @example
  ## 
  ##    # bad
  ## 
  ##    def cook(dry_ingredients = dry_ingredients)
  ##      dry_ingredients.reduce(&:+)
  ##    end
  ## 
  ##  @example
  ## 
  ##    # good
  ## 
  ##    def cook(dry_ingredients = self.dry_ingredients)
  ##      dry_ingredients.combine
  ##    end
  const
    MSG = "Circular argument reference - `%<arg_name>s`."
  method onKwoptarg*(self; node) =
    self.checkForCircularArgumentReferences(node[0], node[1])

  method onOptarg*(self; node) =
    self.checkForCircularArgumentReferences(node[0], node[1])

  method checkForCircularArgumentReferences*(self; argName: Symbol; argValue: Node) =
    if not argValue.isLvarType:
      return
    if not (argValue.toSeq() == @[argName]):
      return
    addOffense(argValue, message = format(MSG, argName = argName))

