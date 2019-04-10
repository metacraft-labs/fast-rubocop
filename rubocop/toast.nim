import os, strformat, strutils

import "."/treesitter/[api, ruby]

import "."/[globals]

var source = ""

# FAITH

proc getLineCol*(node: TSNode): tuple[line, col: int] =
  result.line = 1
  result.col = 1
  for i in 0 .. node.tsNodeStartByte().int-1:
    if gStateRT.code[i] == '\n':
      result.col = 0
      result.line += 1
    result.col += 1


proc lisp*(node: TSNode, depth: int = 0): string =
  result = spaces(depth)
  if node.tsNodeIsNull():
    result.add("nil")
    return
  let
    (line, col) = node.getLineCol()
  var code = ""

  var many = false
  let typ = $node.tsNodeType()
  if typ in @["identifier", "class_variable"]: 
    result.add ":" & gStateRT.code[node.tsNodeStartByte() .. node.tsNodeEndByte()]
  elif typ in @["actual_const", "class_variable", "operator2", "sym"]:
    result.add ":" & typ & ", :" & gStateRT.code[node.tsNodeStartByte() .. node.tsNodeEndByte()]
  elif typ in @["str", "int"]:
    result.add ":" & typ & ", " & gStateRT.code[node.tsNodeStartByte() .. node.tsNodeEndByte()]
  else:
    result.add "(" & ":" & $node.tsNodeType() & ", "# {code})" #{line} {col} {node.tsNodeEndByte() - node.tsNodeStartByte()} {code}"
    many = true
  
  if not many:
    return result
  if node.tsNodeNamedChildCount() == 0:
    return result
  
  var lastShort = true
  for i in 0 ..< node.tsNodeNamedChildCount():
    let child = node.tsNodeNamedChild(i)
    let childTyp = $child.tsNodeType()
    if childTyp in @["identifier", "actual_const", "int", "class_variable", "str", "operator2", "sym"]:
      result.add(lisp(child, 0)[0 .. ^2])
      lastShort = true
    else:
      if lastShort:
        result.add("\n")
      result.add(lisp(child, depth + 1) & "\n")
      lastShort = false
    result.add(", ")
  result = result[0 .. ^3] & ")"
  