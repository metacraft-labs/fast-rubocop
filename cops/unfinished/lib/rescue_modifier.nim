
import
  alignment

import
  rescueNode

cop :
  type
    RescueModifier* = ref object of Cop
    ##  This cop checks for uses of rescue in its modifier form.
    ## 
    ##  @example
    ##    # bad
    ##    some_method rescue handle_error
    ## 
    ##    # good
    ##    begin
    ##      some_method
    ##    rescue
    ##      handle_error
    ##    end
  const
    MSG = "Avoid using `rescue` in its modifier form."
  method onResbody*(self: RescueModifier; node: Node): void =
    if isRescueModifier(node):
    addOffense(node.parent)

  method autocorrect*(self: RescueModifier; node: Node): void =
    var
      indent = indentation(node)
      correction = """begin
(begin
  (send
    (send
      (lvar :operation) :source) :gsub
    (regexp
      (str "^")
      (regopt))
    (lvar :indent)))(str "\n")(begin
  (send
    (send
      (lvar :rescue_args) :source) :gsub
    (regexp
      (str "^")
      (regopt))
    (lvar :indent)))(str "\n")"""
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, correction))

