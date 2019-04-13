
import
  tables

cop :
  type
    AutoResourceCleanup* = ref object of Cop
    ##  This cop checks for cases when you could use a block
    ##  accepting version of a method that does automatic
    ##  resource cleanup.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    f = File.open('file')
    ## 
    ##    # good
    ##    File.open('file') do |f|
    ##      # ...
    ##    end
  const
    MSG = "Use the block version of `%<class>s.%<method>s`."
  const
    TARGETMETHODS = {"File": "open"}.newTable()
  method onSend*(self: AutoResourceCleanup; node: Node): void =
    for targetClass, targetMethod in TARGETMETHODS:
      var targetReceiver = s("const", targetClass)
      if node.receiver != targetReceiver:
        continue
      if node.methodName != targetMethod:
        continue
      if isCleanup(node):
        continue
      addOffense(node, message = format(MSG, class = targetClass, method = targetMethod))

  method isCleanup*(self: AutoResourceCleanup; node: Node): void =
    var parent = node.parent
    node.isBlockArgument or
      parent and
        parent.isBlockType() or parent.isLvasgnType().!

