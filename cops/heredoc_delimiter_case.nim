
import
  strutils

import
  heredoc

import
  configurableEnforcedStyle

cop :
  type
    HeredocDelimiterCase* = ref object of Cop
    ##  This cop checks that your heredocs are using the configured case.
    ##  By default it is configured to enforce uppercase heredocs.
    ## 
    ##  @example EnforcedStyle: uppercase (default)
    ##    # bad
    ##    <<-sql
    ##      SELECT * FROM foo
    ##    sql
    ## 
    ##    # good
    ##    <<-SQL
    ##      SELECT * FROM foo
    ##    SQL
    ## 
    ##  @example EnforcedStyle: lowercase
    ##    # bad
    ##    <<-SQL
    ##      SELECT * FROM foo
    ##    SQL
    ## 
    ##    # good
    ##    <<-sql
    ##      SELECT * FROM foo
    ##    sql
  const
    MSG = "Use %<style>s heredoc delimiters."
  method onHeredoc*(self: HeredocDelimiterCase; node: Node): void =
    if isCorrectCaseDelimiters(node):
      return
    addOffense(node, location = "heredoc_end")

  method message*(self: HeredocDelimiterCase; _node: Node): void =
    format(MSG, style = style)

  method isCorrectCaseDelimiters*(self: HeredocDelimiterCase; node: Node): void =
    delimiterString(node) == correctDelimiters(node)

  method correctDelimiters*(self: HeredocDelimiterCase; node: Node): void =
    if style == "uppercase":
      delimiterString(node).toUpperAscii()
    else:
      delimiterString(node).toLowerAscii()
  
