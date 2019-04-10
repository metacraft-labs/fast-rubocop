
import
  rangeHelp

cop :
  type
    ExpandPathArguments* = ref object of Cop
    ##  This cop checks for use of the `File.expand_path` arguments.
    ##  Likewise, it also checks for the `Pathname.new` argument.
    ## 
    ##  Contrastive bad case and good case are alternately shown in
    ##  the following examples.
    ## 
    ##  @example
    ##    # bad
    ##    File.expand_path('..', __FILE__)
    ## 
    ##    # good
    ##    File.expand_path(__dir__)
    ## 
    ##    # bad
    ##    File.expand_path('../..', __FILE__)
    ## 
    ##    # good
    ##    File.expand_path('..', __dir__)
    ## 
    ##    # bad
    ##    File.expand_path('.', __FILE__)
    ## 
    ##    # good
    ##    File.expand_path(__FILE__)
    ## 
    ##    # bad
    ##    Pathname(__FILE__).parent.expand_path
    ## 
    ##    # good
    ##    Pathname(__dir__).expand_path
    ## 
    ##    # bad
    ##    Pathname.new(__FILE__).parent.expand_path
    ## 
    ##    # good
    ##    Pathname.new(__dir__).expand_path
    ## 
  const
    MSG = """Use `expand_path(%<new_path>s%<new_default_dir>s)` instead of `expand_path(%<current_path>s, __FILE__)`."""
  const
    PATHNAMEMSG = """Use `Pathname(__dir__).expand_path` instead of `Pathname(__FILE__).parent.expand_path`."""
  const
    PATHNAMENEWMSG = """Use `Pathname.new(__dir__).expand_path` instead of `Pathname.new(__FILE__).parent.expand_path`."""
  nodeMatcher fileExpandPath, """          (send
            (const nil? :File) :expand_path
            $_
            $_)
"""
  nodeMatcher pathnameParentExpandPath, """          (send
            (send
              (send nil? :Pathname
                $_) :parent) :expand_path)
"""
  nodeMatcher pathnameNewParentExpandPath, """          (send
            (send
              (send
                (const nil? :Pathname) :new
                $_) :parent) :expand_path)
"""
  method onSend*(self: ExpandPathArguments; node: Node): void =
    if
      var capturedValues = fileExpandPath node:
      inspectOffenseForExpandPath(node, currentPath, defaultDir)
    elif
      var defaultDir = pathnameParentExpandPath node:
      if isUnrecommendedArgument(defaultDir):
      addOffense(node, message = PATHNAMEMSG)
    elif
      defaultDir = pathnameNewParentExpandPath node:
      if isUnrecommendedArgument(defaultDir):
      addOffense(node, message = PATHNAMENEWMSG)

  method autocorrect*(self: ExpandPathArguments; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if
        var capturedValues = fileExpandPath node:
        autocorrectExpandPath(corrector, currentPath, defaultDir)
      elif
        var defaultDir = pathnameParentExpandPath node or
        defaultDir = pathnameNewParentExpandPath node:
        corrector.replace(defaultDir.loc.expression, "__dir__")
        removeParentMethod(corrector, defaultDir))

  method isUnrecommendedArgument*(self: ExpandPathArguments; defaultDir: Node): void =
    defaultDir.source == "__FILE__"

  method inspectOffenseForExpandPath*(self: ExpandPathArguments; node: Node;
                                     currentPath: Node; defaultDir: Node): void =
    if isUnrecommendedArgument(defaultDir) and currentPath.isStrType():
    currentPath = stripSurroundedQuotes!(currentPath.source)
    var
      parentPath = parentPath(currentPath)
      newPath = if parentPath == "":
        ""
      newDefaultDir = if depth(currentPath).isZero():
        "__FILE__"
      message = format(MSG, newPath = newPath, newDefaultDir = newDefaultDir,
                     currentPath = """'(lvar :current_path)'""")
    addOffense(node, location = "selector", message = message)

  method autocorrectExpandPath*(self: ExpandPathArguments; corrector: Corrector;
                               currentPath: Node; defaultDir: Node): void =
    var strippedCurrentPath = stripSurroundedQuotes!(currentPath.source)
    case depth(strippedCurrentPath)
    of 0:
      var range = argumentsRange(currentPath)
      corrector.replace(range, "__FILE__")
    of 1:
      range = argumentsRange(currentPath)
      corrector.replace(range, "__dir__")
    else:
      var newPath = """'(send nil :parent_path
  (lvar :stripped_current_path))'"""
      corrector.replace(currentPath.loc.expression, newPath)
      corrector.replace(defaultDir.loc.expression, "__dir__")

  method stripSurroundedQuotes!*(self: ExpandPathArguments; pathString: string): void =
    pathString.slice!(pathString.length - 1)
    pathString.slice!(0)
    pathString

  method depth*(self: ExpandPathArguments; currentPath: string): void =
    var paths = currentPath.split(SEPARATOR)
    paths.reject(proc (path: string): void =
      path == ".").count()

  method parentPath*(self: ExpandPathArguments; currentPath: string): void =
    var paths = currentPath.split(SEPARATOR)
    paths.delete(".")
    paths.eachWithIndex(proc (path: string; index: Integer): void =
      if path == "..":
        paths.deleteAt(index)
        break )
    paths.join(SEPARATOR)

  method removeParentMethod*(self: ExpandPathArguments; corrector: Corrector;
                            defaultDir: Node): void =
    var node = defaultDir.parent.parent.parent.children[0]
    corrector.remove(node.loc.dot)
    corrector.remove(node.loc.selector)

  method argumentsRange*(self: ExpandPathArguments; node: Node): void =
    rangeBetween(node.parent.firstArgument.sourceRange.beginPos,
                 node.parent.lastArgument.sourceRange.endPos)

