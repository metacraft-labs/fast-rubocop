
import
  onNormalIfUnless

import
  configurableEnforcedStyle

import
  rangeHelp

cop :
  type
    EmptyElse* = ref object of Cop
    ##  Checks for empty else-clauses, possibly including comments and/or an
    ##  explicit `nil` depending on the EnforcedStyle.
    ## 
    ##  @example EnforcedStyle: empty
    ##    # warn only on empty else
    ## 
    ##    # bad
    ##    if condition
    ##      statement
    ##    else
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    else
    ##      nil
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    else
    ##      statement
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    end
    ## 
    ##  @example EnforcedStyle: nil
    ##    # warn on else with nil in it
    ## 
    ##    # bad
    ##    if condition
    ##      statement
    ##    else
    ##      nil
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    else
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    else
    ##      statement
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    end
    ## 
    ##  @example EnforcedStyle: both (default)
    ##    # warn on empty else and else with nil in it
    ## 
    ##    # bad
    ##    if condition
    ##      statement
    ##    else
    ##      nil
    ##    end
    ## 
    ##    # bad
    ##    if condition
    ##      statement
    ##    else
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    else
    ##      statement
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    end
  const
    MSG = "Redundant `else`-clause."
  method onNormalIfUnless*(self: EmptyElse; node: Node): void =
    check(node)

  method onCase*(self: EmptyElse; node: Node): void =
    check(node)

  method autocorrect*(self: EmptyElse; node: Node): void =
    if isAutocorrectForbidden(`$`()):
      return false
    if isCommentInElse(node):
      return false
    lambda(proc (corrector: Corrector): void =
      var endPos = baseNode(node).loc.end.beginPos
      corrector.remove(rangeBetween(node.loc.else.beginPos, endPos)))

  method check*(self: EmptyElse; node: Node): void =
    if isEmptyStyle:
      emptyCheck(node)
    if isNilStyle:
      nilCheck(node)
  
  method isNilStyle*(self: EmptyElse): void =
    style == "nil" or style == "both"

  method isEmptyStyle*(self: EmptyElse): void =
    style == "empty" or style == "both"

  method emptyCheck*(self: EmptyElse; node: Node): void =
    if node.isElse and node.elseBranch.!:
    addOffense(node, location = "else")

  method nilCheck*(self: EmptyElse; node: Node): void =
    if node.elseBranch and node.elseBranch.isNilType():
    addOffense(node, location = "else")

  method isCommentInElse*(self: EmptyElse; node: Node): void =
    var range = elseLineRange(node.loc)
    processedSource.findComment(proc (c: Comment): void =
      range.isInclude(c.loc.line))

  method elseLineRange*(self: EmptyElse; loc: Condition): void =
    if loc.else.isNil() or loc.end.isNil():
      return
  
  method baseNode*(self: EmptyElse; node: Node): void =
    if node.isCaseType():
      return node
    if node.isElsif:
    else:
      return node
    node.eachAncestor("if", "case", "when").find(lambda(proc (): void =
      node), proc (parent: void): void =
      parent.loc.end)

  method isAutocorrectForbidden*(self: EmptyElse; type: string): void =
    (type, "both").isInclude(missingElseStyle)

  method missingElseStyle*(self: EmptyElse): void =
    var missingCfg = config.forCop("Style/MissingElse")
    if missingCfg.fetch("Enabled"):
      missingCfg["EnforcedStyle"]
  
