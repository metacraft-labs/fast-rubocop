
import
  onNormalIfUnless

import
  configurableEnforcedStyle

cop :
  type
    MissingElse* = ref object of Cop
    ##  Checks for `if` expressions that do not have an `else` branch.
    ## 
    ##  Supported styles are: if, case, both.
    ## 
    ##  @example EnforcedStyle: if
    ##    # warn when an `if` expression is missing an `else` branch.
    ## 
    ##    # bad
    ##    if condition
    ##      statement
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    else
    ##      # the content of `else` branch will be determined by Style/EmptyElse
    ##    end
    ## 
    ##    # good
    ##    case var
    ##    when condition
    ##      statement
    ##    end
    ## 
    ##    # good
    ##    case var
    ##    when condition
    ##      statement
    ##    else
    ##      # the content of `else` branch will be determined by Style/EmptyElse
    ##    end
    ## 
    ##  @example EnforcedStyle: case
    ##    # warn when a `case` expression is missing an `else` branch.
    ## 
    ##    # bad
    ##    case var
    ##    when condition
    ##      statement
    ##    end
    ## 
    ##    # good
    ##    case var
    ##    when condition
    ##      statement
    ##    else
    ##      # the content of `else` branch will be determined by Style/EmptyElse
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    else
    ##      # the content of `else` branch will be determined by Style/EmptyElse
    ##    end
    ## 
    ##  @example EnforcedStyle: both (default)
    ##    # warn when an `if` or `case` expression is missing an `else` branch.
    ## 
    ##    # bad
    ##    if condition
    ##      statement
    ##    end
    ## 
    ##    # bad
    ##    case var
    ##    when condition
    ##      statement
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    else
    ##      # the content of `else` branch will be determined by Style/EmptyElse
    ##    end
    ## 
    ##    # good
    ##    case var
    ##    when condition
    ##      statement
    ##    else
    ##      # the content of `else` branch will be determined by Style/EmptyElse
    ##    end
  const
    MSG = "`%<type>s` condition requires an `else`-clause."
  const
    MSGNIL = """`%<type>s` condition requires an `else`-clause with `nil` in it."""
  const
    MSGEMPTY = """`%<type>s` condition requires an empty `else`-clause."""
  method onNormalIfUnless*(self: MissingElse; node: Node): void =
    if isCaseStyle:
      return
    if isUnlessElseCopEnabled and node.isUnless:
      return
    check(node)

  method onCase*(self: MissingElse; node: Node): void =
    if isIfStyle:
      return
    check(node)

  method check*(self: MissingElse; node: Node): void =
    if node.isElse:
      return
    if isEmptyElseCopEnabled:
      if emptyElseStyle == "empty":
        addOffense(node)
      elif emptyElseStyle == "nil":
        addOffense(node)
    addOffense(node)

  method message*(self: MissingElse; node: Node): void =
    var template = case emptyElseStyle
    of "empty":
      MSGNIL
    of "nil":
      MSGEMPTY
    else:
      MSG
    format(template, type = node.type)

  method isIfStyle*(self: MissingElse): void =
    style == "if"

  method isCaseStyle*(self: MissingElse): void =
    style == "case"

  method isUnlessElseCopEnabled*(self: MissingElse): void =
    unlessElseConfig.fetch("Enabled")

  method unlessElseConfig*(self: MissingElse): void =
    config.forCop("Style/UnlessElse")

  method isEmptyElseCopEnabled*(self: MissingElse): void =
    emptyElseConfig.fetch("Enabled")

  method emptyElseStyle*(self: MissingElse): void =
    if emptyElseConfig.isKey("EnforcedStyle"):
    emptyElseConfig["EnforcedStyle"].toSym()

  method emptyElseConfig*(self: MissingElse): void =
    config.forCop("Style/EmptyElse")

