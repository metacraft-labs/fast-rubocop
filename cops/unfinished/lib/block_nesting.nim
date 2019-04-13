
import
  configurableMax

cop :
  type
    BlockNesting* = ref object of Cop
    ##  This cop checks for excessive nesting of conditional and looping
    ##  constructs.
    ## 
    ##  You can configure if blocks are considered using the `CountBlocks`
    ##  option. When set to `false` (the default) blocks are not counted
    ##  towards the nesting level. Set to `true` to count blocks as well.
    ## 
    ##  The maximum level of nesting allowed is configurable.
  const
    NESTINGBLOCKS = @["case", "if", "while", "while_post", "until", "until_post", "for",
                    "resbody"]
  method investigate*(self: BlockNesting; processedSource: ProcessedSource): void =
    if processedSource.isBlank:
      return
    var max = copConfig["Max"]
    checkNestingLevel(processedSource.ast, max, 0)

  method checkNestingLevel*(self: BlockNesting; node: Node; max: Integer;
                           currentLevel: Integer): void =
    if isConsiderNode(node):
      if node.isIfType() and node.isElsif:
      else:
        currentLevel += 1
      if currentLevel > max:
        self.max=(currentLevel)
        if isPartOfIgnoredNode(node):
        else:
          addOffense(node, message = message(max), proc (): void =
            ignoreNode(node))
    node.eachChildNode(proc (childNode: Node): void =
      checkNestingLevel(childNode, max, currentLevel))

  method isConsiderNode*(self: BlockNesting; node: Node): void =
    if NESTINGBLOCKS.isInclude(node.type):
      return true
    isCountBlocks and node.isBlockType()

  method message*(self: BlockNesting; max: Integer): void =
    """Avoid more than (lvar :max) levels of block nesting."""

  method isCountBlocks*(self: BlockNesting): void =
    copConfig["CountBlocks"]

