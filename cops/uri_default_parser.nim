
cop :
  type
    UriDefaultParser* = ref object of Cop
  const
    MSG = """Use `%<double_colon>sURI::DEFAULT_PARSER` instead of `%<double_colon>sURI::Parser.new`."""
  nodeMatcher isUriParserNew, """          (send
            (const
              (const ${nil? cbase} :URI) :Parser) :new)
"""
  method onSend*(self: UriDefaultParser; node: Node): void =
    if isUriParserNew node:
      var
        doubleColon = if capturedValue:
          "::"
        message = format(MSG, doubleColon = doubleColon)
      addOffense(node, message = message):

  method autocorrect*(self: UriDefaultParser; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var doubleColon = if isUriParserNew node:
        "::"
      corrector.replace(node.loc.expression,
                        """(lvar :double_colon)URI::DEFAULT_PARSER"""))

