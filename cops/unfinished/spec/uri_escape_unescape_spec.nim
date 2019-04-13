
import
  uri_escape_unescape, test_tools

suite "UriEscapeUnescape":
  var cop = UriEscapeUnescape()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when using `URI.escape(\'http://example.com\')`":
    expectOffense("""      URI.escape('http://example.com')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `URI.escape` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
""".stripIndent)
  test "registers an offense when using `URI.escape(\'@?@!\', \'!?\')`":
    expectOffense("""      URI.escape('@?@!', '!?')
      ^^^^^^^^^^^^^^^^^^^^^^^^ `URI.escape` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
""".stripIndent)
  test "registers an offense when using `::URI.escape(\'http://example.com\')`":
    expectOffense("""      ::URI.escape('http://example.com')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `::URI.escape` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
""".stripIndent)
  test "registers an offense when using `URI.encode(\'http://example.com\')`":
    expectOffense("""      URI.encode('http://example.com')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `URI.encode` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
""".stripIndent)
  test "registers an offense when using `::URI.encode(\'http://example.com)`":
    expectOffense("""      ::URI.encode('http://example.com')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `::URI.encode` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
""".stripIndent)
  test "registers an offense when using `URI.unescape(enc_uri)`":
    expectOffense("""      URI.unescape(enc_uri)
      ^^^^^^^^^^^^^^^^^^^^^ `URI.unescape` method is obsolete and should not be used. Instead, use `CGI.unescape`, `URI.decode_www_form` or `URI.decode_www_form_component` depending on your specific use case.
""".stripIndent)
  test "registers an offense when using `::URI.unescape(enc_uri)`":
    expectOffense("""      ::URI.unescape(enc_uri)
      ^^^^^^^^^^^^^^^^^^^^^^^ `::URI.unescape` method is obsolete and should not be used. Instead, use `CGI.unescape`, `URI.decode_www_form` or `URI.decode_www_form_component` depending on your specific use case.
""".stripIndent)
  test "registers an offense when using `URI.decode(enc_uri)`":
    expectOffense("""      URI.decode(enc_uri)
      ^^^^^^^^^^^^^^^^^^^ `URI.decode` method is obsolete and should not be used. Instead, use `CGI.unescape`, `URI.decode_www_form` or `URI.decode_www_form_component` depending on your specific use case.
""".stripIndent)
  test "registers an offense when using `::URI.decode(enc_uri)`":
    expectOffense("""      ::URI.decode(enc_uri)
      ^^^^^^^^^^^^^^^^^^^^^ `::URI.decode` method is obsolete and should not be used. Instead, use `CGI.unescape`, `URI.decode_www_form` or `URI.decode_www_form_component` depending on your specific use case.
""".stripIndent)
