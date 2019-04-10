
import
  methodPreference

cop :
  type
    CollectionMethods* = ref object of Cop
    ##  This cop enforces the use of consistent method names
    ##  from the Enumerable module.
    ## 
    ##  Unfortunately we cannot actually know if a method is from
    ##  Enumerable or not (static analysis limitation), so this cop
    ##  can yield some false positives.
    ## 
    ##  You can customize the mapping from undesired method to desired method.
    ## 
    ##  e.g. to use `detect` over `find`:
    ## 
    ##    Style/CollectionMethods:
    ##      PreferredMethods:
    ##        find: detect
    ## 
    ##  The default mapping for `PreferredMethods` behaves as follows.
    ## 
    ##  @example
    ##    # bad
    ##    items.collect
    ##    items.collect!
    ##    items.inject
    ##    items.detect
    ##    items.find_all
    ## 
    ##    # good
    ##    items.map
    ##    items.map!
    ##    items.reduce
    ##    items.find
    ##    items.select
    ## 
  const
    MSG = "Prefer `%<prefer>s` over `%<current>s`."
  method onBlock*(self: CollectionMethods; node: Node): void =
    checkMethodNode(node.sendNode)

  method onSend*(self: CollectionMethods; node: Node): void =
    if node.arguments.isOne() and node.firstArgument.isBlockPassType():
    checkMethodNode(node)

  method autocorrect*(self: CollectionMethods; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.selector,
                        preferredMethod(node.loc.selector.source)))

  method message*(self: CollectionMethods; node: Node): void =
    format(MSG, prefer = preferredMethod(node.methodName), current = node.methodName)

  method checkMethodNode*(self: CollectionMethods; node: Node): void =
    if preferredMethods[node.methodName]:
    addOffense(node, location = "selector")

