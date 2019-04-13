
cop :
  type
    UriEscapeUnescape* = ref object of Cop
  const
    ALTERNATEMETHODSOFURIESCAPE = @["CGI.escape", "URI.encode_www_form",
                                  "URI.encode_www_form_component"]
  const
    ALTERNATEMETHODSOFURIUNESCAPE = @["CGI.unescape", "URI.decode_www_form",
                                    "URI.decode_www_form_component"]
  const
    MSG = """`%<uri_method>s` method is obsolete and should not be used. Instead, use %<replacements>s depending on your specific use case."""
  nodeMatcher isUriEscapeUnescape, """          (send
            (const ${nil? cbase} :URI) ${:escape :encode :unescape :decode}
            ...)
"""
  method onSend*(self: UriEscapeUnescape; node: Node): void =
    isUriEscapeUnescape node:
      var
        replacements = if @["escape", "encode"].isInclude(obsoleteMethod):
          ALTERNATEMETHODSOFURIESCAPE
        doubleColon = if topLevel:
          "::"
        message = format(MSG, uriMethod = """(lvar :double_colon)URI.(lvar :obsolete_method)""",
                       replacements = """(str "`")(str "or `")""")
      addOffense(node, message = message)

