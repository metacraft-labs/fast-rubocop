
import
  tables, sequtils

import
  configurableEnforcedStyle

cop :
  type
    MixinGrouping* = ref object of Cop
    ##  This cop checks for grouping of mixins in `class` and `module` bodies.
    ##  By default it enforces mixins to be placed in separate declarations,
    ##  but it can be configured to enforce grouping them in one declaration.
    ## 
    ##  @example EnforcedStyle: separated (default)
    ##    # bad
    ##    class Foo
    ##      include Bar, Qox
    ##    end
    ## 
    ##    # good
    ##    class Foo
    ##      include Qox
    ##      include Bar
    ##    end
    ## 
    ##  @example EnforcedStyle: grouped
    ##    # bad
    ##    class Foo
    ##      extend Bar
    ##      extend Qox
    ##    end
    ## 
    ##    # good
    ##    class Foo
    ##      extend Qox, Bar
    ##    end
  const
    MIXINMETHODS = @["extend", "include", "prepend"]
  const
    MSG = "Put `%<mixin>s` mixins in %<suffix>s."
  method onClass*(self: MixinGrouping; node: Node): void =
    var beginNode = node.childNodes.find(proc (it: void): void =
      it.isEginType) or node
    for macro in beginNode.eachChildNode("send").filterIt:
      it.isAcro:
      if MIXINMETHODS.isInclude(macro.methodName):
      check(macro)

  method autocorrect*(self: MixinGrouping; node: Node): void =
    var range = node.loc.expression
    if isSeparatedStyle:
      var correction = separateMixins(node)
    else:
      var mixins = siblingMixins(node)
      if node == mixins[0]:
        correction = groupMixins(node, mixins)
      else:
        range = rangeToRemoveForSubsequentMixin(mixins, node)
        correction = ""
    lambda(proc (corrector: Corrector): void =
      corrector.replace(range, correction))

  method rangeToRemoveForSubsequentMixin*(self: MixinGrouping; mixins: Array;
      node: Node): void =
    var
      range = node.loc.expression
      prevMixin = mixins.eachCons(2, proc (m: Node; n: Node): void =
        if n == node:
          break
      )
      between = prevMixin.loc.expression.end.join(range.begin)
    if between.source.!~():
      range = range.join(between)
    range

  method check*(self: MixinGrouping; sendNode: Node): void =
    if isSeparatedStyle:
      checkSeparatedStyle(sendNode)
    else:
      checkGroupedStyle(sendNode)
  
  method checkGroupedStyle*(self: MixinGrouping; sendNode: Node): void =
    if siblingMixins(sendNode).size == 1:
      return
    addOffense(sendNode)

  method checkSeparatedStyle*(self: MixinGrouping; sendNode: Node): void =
    if sendNode.arguments.isOne():
      return
    addOffense(sendNode)

  method siblingMixins*(self: MixinGrouping; sendNode: Node): void =
    var siblings = sendNode.parent.eachChildNode("send").filterIt:
      it.isAcro
    siblings.filterIt:
      it.methodName == sendNode.methodName

  method message*(self: MixinGrouping; sendNode: Node): void =
    var suffix = if isSeparatedStyle:
      "separate statements"
    format(MSG, mixin = sendNode.methodName, suffix = suffix)

  method isGroupedStyle*(self: void): void =
    style == "grouped"

  method isSeparatedStyle*(self: MixinGrouping): void =
    style == "separated"

  method separateMixins*(self: MixinGrouping; node: Node): void =
    args.reverse!()
    var firstMixin = String.new("""(lvar :mixin) (send
  (send
    (lvar :args) :first) :source)""")
    args[].inject(firstMixin, proc (replacement: string; arg: Node): void =
      replacement.<<("""
(send nil :indent
  (lvar :node))(lvar :mixin) (send
  (lvar :arg) :source)"""))

  method groupMixins*(self: MixinGrouping; node: Node; mixins: Array): void =
    var allMixinArguments = mixins.reverse().flatMap(proc (m: Node): void =
      m.arguments.mapIt:
        it.ource)
    """(lvar :mixin) (send
  (lvar :all_mixin_arguments) :join
  (str ", "))"""

  method indent*(self: MixinGrouping; node: Node): void =
    " " * node.loc.column

