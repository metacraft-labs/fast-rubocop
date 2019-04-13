
import
  sequtils

import
  configurableEnforcedStyle

cop :
  type
    CommandLiteral* = ref object of Cop
    ##  This cop enforces using `` or %x around command literals.
    ## 
    ##  @example EnforcedStyle: backticks (default)
    ##    # bad
    ##    folders = %x(find . -type d).split
    ## 
    ##    # bad
    ##    %x(
    ##      ln -s foo.example.yml foo.example
    ##      ln -s bar.example.yml bar.example
    ##    )
    ## 
    ##    # good
    ##    folders = `find . -type d`.split
    ## 
    ##    # good
    ##    `
    ##      ln -s foo.example.yml foo.example
    ##      ln -s bar.example.yml bar.example
    ##    `
    ## 
    ##  @example EnforcedStyle: mixed
    ##    # bad
    ##    folders = %x(find . -type d).split
    ## 
    ##    # bad
    ##    `
    ##      ln -s foo.example.yml foo.example
    ##      ln -s bar.example.yml bar.example
    ##    `
    ## 
    ##    # good
    ##    folders = `find . -type d`.split
    ## 
    ##    # good
    ##    %x(
    ##      ln -s foo.example.yml foo.example
    ##      ln -s bar.example.yml bar.example
    ##    )
    ## 
    ##  @example EnforcedStyle: percent_x
    ##    # bad
    ##    folders = `find . -type d`.split
    ## 
    ##    # bad
    ##    `
    ##      ln -s foo.example.yml foo.example
    ##      ln -s bar.example.yml bar.example
    ##    `
    ## 
    ##    # good
    ##    folders = %x(find . -type d).split
    ## 
    ##    # good
    ##    %x(
    ##      ln -s foo.example.yml foo.example
    ##      ln -s bar.example.yml bar.example
    ##    )
    ## 
    ##  @example AllowInnerBackticks: false (default)
    ##    # If `false`, the cop will always recommend using `%x` if one or more
    ##    # backticks are found in the command string.
    ## 
    ##    # bad
    ##    `echo \`ls\``
    ## 
    ##    # good
    ##    %x(echo `ls`)
    ## 
    ##  @example AllowInnerBackticks: true
    ##    # good
    ##    `echo \`ls\``
  const
    MSGUSEBACKTICKS = "Use backticks around command string."
  const
    MSGUSEPERCENTX = "Use `%x` around command string."
  method onXstr*(self: CommandLiteral; node: Node): void =
    if node.isHeredoc:
      return
    if isBacktickLiteral(node):
      checkBacktickLiteral(node)
    else:
      checkPercentXLiteral(node)
  
  method autocorrect*(self: CommandLiteral; node: Node): void =
    if isContainsBacktick(node):
      return
    var replacement = if isBacktickLiteral(node):
      @["%x", ""].zip(preferredDelimiter).mapIt:
        it.oin
    else:
      @["`", "`"]
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.begin, replacement[0])
      corrector.replace(node.loc.end, replacement.last()))

  method checkBacktickLiteral*(self: CommandLiteral; node: Node): void =
    if isAllowedBacktickLiteral(node):
      return
    addOffense(node)

  method checkPercentXLiteral*(self: CommandLiteral; node: Node): void =
    if isAllowedPercentXLiteral(node):
      return
    addOffense(node)

  method message*(self: CommandLiteral; node: Node): void =
    if isBacktickLiteral(node):
      MSGUSEPERCENTX
  
  method isAllowedBacktickLiteral*(self: CommandLiteral; node: Node): void =
    case style
    of "backticks":
      isContainsDisallowedBacktick(node).!
    of "mixed":
      node.isSingleLine and isContainsDisallowedBacktick(node).!
    else:

  method isAllowedPercentXLiteral*(self: CommandLiteral; node: Node): void =
    case style
    of "backticks":
      isContainsDisallowedBacktick(node)
    of "mixed":
      node.isMultiline or isContainsDisallowedBacktick(node)
    of "percent_x":
      true
    else:

  method isContainsDisallowedBacktick*(self: CommandLiteral; node: Node): void =
    isAllowInnerBackticks.! and isContainsBacktick(node)

  method isAllowInnerBackticks*(self: CommandLiteral): void =
    copConfig["AllowInnerBackticks"]

  method isContainsBacktick*(self: CommandLiteral; node: Node): void =
    nodeBody(node).=~()

  method nodeBody*(self: CommandLiteral; node: Node): void =
    var loc = node.loc
    loc.expression.source[]

  method isBacktickLiteral*(self: CommandLiteral; node: Node): void =
    node.loc.begin.source == "`"

  method preferredDelimiter*(self: CommandLiteral): void =
      commandDelimiter or defaultDelimiter.split()

  method commandDelimiter*(self: CommandLiteral): void =
    preferredDelimitersConfig["%x"]

  method defaultDelimiter*(self: CommandLiteral): void =
    preferredDelimitersConfig["default"]

  method preferredDelimitersConfig*(self: CommandLiteral): void =
    config.forCop("Style/PercentLiteralDelimiters")["PreferredDelimiters"]

