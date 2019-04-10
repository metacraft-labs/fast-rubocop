
import
  onNormalIfUnless

import
  rangeHelp

cop :
  type
    MultilineIfThen* = ref object of Cop
    ##  Checks for uses of the `then` keyword in multi-line if statements.
    ## 
    ##  @example
    ##    # bad
    ##    # This is considered bad practice.
    ##    if cond then
    ##    end
    ## 
    ##    # good
    ##    # If statements can contain `then` on the same line.
    ##    if cond then a
    ##    elsif cond then b
    ##    end
  const
    NONMODIFIERTHEN
  const
    MSG = "Do not use `then` for multi-line `%<keyword>s`."
  method onNormalIfUnless*(self: MultilineIfThen; node: Node): void =
    if isNonModifierThen(node):
    addOffense(node, location = "begin",
               message = format(MSG, keyword = node.keyword))

  method autocorrect*(self: MultilineIfThen; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(rangeWithSurroundingSpace(range = node.loc.begin,
          side = "left")))

  method isNonModifierThen*(self: MultilineIfThen; node: Node): void =
    node.loc.begin and node.loc.begin.sourceLine.=~(NONMODIFIERTHEN)

