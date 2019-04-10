
cop :
  type
    TimesMap* = ref object of Cop
  const
    MESSAGE = """Use `Array.new(%<count>s)` with a block instead of `.times.%<map_or_collect>s`"""
  const
    MESSAGEONLYIF = "only if `%<count>s` is always 0 or more"
  nodeMatcher timesMapCall, """          {(block $(send (send $!nil? :times) {:map :collect}) ...)
           $(send (send $!nil? :times) {:map :collect} (block_pass ...))}
"""
  method onSend*(self: TimesMap; node: Node): void =
    check(node)

  method onBlock*(self: TimesMap; node: Node): void =
    check(node)

  method autocorrect*(self: TimesMap; node: Node): void =
    var replacement = """(str "Array.new(")(begin
  (send
    (block
      (send
        (send
          (lvar :map_or_collect) :arguments) :map)
      (args
        (arg :arg))
      (dstr
        (str ", ")
        (begin
          (send
            (lvar :arg) :source)))) :join))"""
    lambda(proc (corrector: Corrector): void =
      corrector.replace(mapOrCollect.loc.expression, replacement))

  method check*(self: TimesMap; node: Node): void =
    timesMapCall node:
      addOffense(node, message = message(mapOrCollect, count))

  method message*(self: TimesMap; mapOrCollect: Node; count: Node): void =
    var template = if count.isLiteral:
      MESSAGE & "."
    format(template, count = count.source, mapOrCollect = mapOrCollect.methodName)

