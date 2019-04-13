# This class performs a pattern-matching operation on an AST node.
#
# Initialize a new `NodePattern` with `NodePattern.new(pattern_string)`, then
# pass an AST node to `NodePattern#match`. Alternatively, use one of the class
# macros in `NodePattern::Macros` to define your own pattern-matching method.
#
# If the match fails, `nil` will be returned. If the match succeeds, the
# return value depends on whether a block was provided to `#match`, and
# whether the pattern contained any "captures" (values which are extracted
# from a matching AST.)
#
# - With block: #match yields the captures (if any) and passes the return
#               value of the block through.
# - With no block, but one capture: the capture is returned.
# - With no block, but multiple captures: captures are returned as an array.
# - With no block and no captures: #match returns `true`.
#
# ## Pattern string format examples
#
#     ':sym'              # matches a literal symbol
#     '1'                 # matches a literal integer
#     'nil'               # matches a literal nil
#     'send'              # matches (send ...)
#     '(send)'            # matches (send)
#     '(send ...)'        # matches (send ...)
#     '(op-asgn)'         # node types with hyphenated names also work
#     '{send class}'      # matches (send ...) or (class ...)
#     '({send class})'    # matches (send) or (class)
#     '(send const)'      # matches (send (const ...))
#     '(send _ :new)'     # matches (send <anything> :new)
#     '(send $_ :new)'    # as above, but whatever matches the $_ is captured
#     '(send $_ $_)'      # you can use as many captures as you want
#     '(send !const ...)' # ! negates the next part of the pattern
#     '$(send const ...)' # arbitrary matching can be performed on a capture
#     '(send _recv _msg)' # wildcards can be named (for readability)
#     '(send ... :new)'   # you can specifically match against the last child
#                         # (this only works for the very last)
#     '(send $...)'       # capture all the children as an array
#     '(send $... int)'   # capture all children but the last as an array
#     '(send _x :+ _x)'   # unification is performed on named wildcards
#                         # (like Prolog variables...)
#                         # (#== is used to see if values unify)
#     '(int odd?)'        # words which end with a ? are predicate methods,
#                         # are are called on the target to see if it matches
#                         # any Ruby method which the matched object supports
#                         # can be used
#                         # if a truthy value is returned, the match succeeds
#     '(int [!1 !2])'     # [] contains multiple patterns, ALL of which must
#                         # match in that position
#                         # in other words, while {} is pattern union (logical
#                         # OR), [] is intersection (logical AND)
#     '(send %1 _)'       # % stands for a parameter which must be supplied to
#                         # #match at matching time
#                         # it will be compared to the corresponding value in
#                         # the AST using #==
#                         # a bare '%' is the same as '%1'
#                         # the number of extra parameters passed to #match
#                         # must equal the highest % value in the pattern
#                         # for consistency, %0 is the 'root node' which is
#                         # passed as the 1st argument to #match, where the
#                         # matching process starts
#     '^^send'            # each ^ ascends one level in the AST
#                         # so this matches against the grandparent node
#     '#method'           # we call this a 'funcall'; it calls a method in the
#                         # context where a pattern-matching method is defined
#                         # if that returns a truthy value, the match succeeds
#     'equal?(%1)'        # predicates can be given 1 or more extra args
#     '#method(%0, 1)'    # funcalls can also be given 1 or more extra args
#
# You can nest arbitrarily deep:
#
#     # matches node parsed from 'Const = Class.new' or 'Const = Module.new':
#     '(casgn nil? :Const (send (const nil? {:Class :Module}) :new))'
#     # matches a node parsed from an 'if', with a '==' comparison,
#     # and no 'else' branch:
#     '(if (send _ :== _) _ nil?)'
#
# Note that patterns like 'send' are implemented by calling `#send_type?` on
# the node being matched, 'const' by `#const_type?`, 'int' by `#int_type?`,
# and so on. Therefore, if you add methods which are named like
# `#prefix_type?` to the AST node class, then 'prefix' will become usable as
# a pattern.
#
# Also note that if you need a "guard clause" to protect against possible nils
# in a certain place in the AST, you can do it like this: `[!nil <pattern>]`

import macros, tables, strutils, sequtils

type
  NodePattern* = ref object

  Compiler* = ref object
    text*: string
    root*: string
    temp*: int
    capture*: int
    unify*: Table[string, int]
    params*: int
    tokens*: seq[string]
    matchCode*: NimNode

  

const
  UNION_END = "}"
  INTERSECT_END = "]"

proc isIdentifier(name: string): bool =
  if name.len == 0:
    return false
  if name in @["_"]:
    return true
  if name == "===":
    return true
  for c in name:
    if not isAlphaNumeric(c) and c notin {'?', '_', '!'}:
      return false
  return true

proc isMeta(token: string): bool =
  return token == "meta" # TODO

proc isSymbol(name: string): bool = 
  if name.len == 0 or name[0] != ':':
    return false
  return name[1 .. ^1].isIdentifier()

proc isNumber(token: string): bool =
  if token.len == 0:
    return false
  var count = 0
  for c in token:
    if count == 0 and c == '.' :
      count = 1
    elif c == '.':
      return false
    elif not isDigit(c):
      return false
  return true

proc isNode(token: string): bool =
  return isIdentifier(token)

proc isPredicate(token: string): bool =
  return false

proc isWildcard(token: string): bool =
  if token.len == 0 or token[0] != '_':
    return false
  return token.len == 1 or isIdentifier(token[1 .. ^1])

proc isFuncall(token: string): bool =
  if token.len == 0 or token[0] != '#':
    return false
  return isIdentifier(token[1 .. ^1])

proc isLiteral(token: string): bool =
  return token.isSymbol() or token.isNumber() # or token.isString()

proc isParam(token: string): bool =
  if token.len == 0 or token[0] != '%':
    return false
  return isDigit(token[1 .. ^1])

proc compileExpr(compiler: Compiler, node: NimNode, head: bool): NimNode

proc generateMatch(text: string, root: string): NimNode

macro nodeMatcher*(methodName: untyped, pattern: static[string]): untyped =
  result = generateMatch(pattern, "node")
  var name: NimNode
  let node = ident("node")

  # be good
  name = methodName
  result = quote:
    template `name`(`node`: untyped, bl: untyped): untyped =
      if `result`:
          bl

    template `name`(`node`: untyped): bool =
      `result`

  echo result.repr

proc tokenize(text: string): seq[string] =
  result = @[]
  var inLabel = false
  var token = ""
  var i = 0
  while i < text.len:
    var c = text[i]
    if inLabel:
      if c.isAlphaNumeric or c in {'=', '+', '-', '*', '/', '_', '?'}:
        token.add(c)
      else:
        result.add(token)
        token = ""
        if c != ' ':
          result.add($c)
        inLabel = false
    else:
      if c.isAlphaNumeric or c == ':' or c == '#':
        token = $c
        inLabel = true
      elif c == '.' and i < text.len - 2 and text[i .. i + 1] == "..":
        result.add("...")
        token = ""
        inLabel = false
        i += 2
      elif c != ' ':
        result.add($c)
        token = ""
        inLabel = false
    i += 1
  echo result

proc generateMatch(text: string, root: string): NimNode =
  var compiler = Compiler(text: text, root: root,  temp: 0, capture: 0, unify: initTable[string, int](), params: 0)
  compiler.tokens = tokenize(compiler.text)
  result = compileExpr(compiler, ident(compiler.root), false)
  echo result.repr
  

using
  compiler: Compiler
  node: NimNode

proc compileSeq(compiler, node; head: bool): NimNode =
  if compiler.tokens.len == 0 or compiler.tokens[0] == ")":
    error("empty")
  elif head:
    error("head")
    
  # 'cur_node' is a Ruby expression which evaluates to an AST node,
  # but we don't know how expensive it is
  # to be safe, cache the node in a temp variable and then use the
  # temp variable as 'cur_node'
  let temp = ident("temp" & $compiler.temp)
  compiler.temp += 1
  result = quote:
    let `temp` = `node`; true
  var index = -1
  var terms: seq[NimNode] = @[]
  var size = (0, false)

  while compiler.tokens.len > 0 and compiler.tokens[0] != ")":
    if compiler.tokens[0] == "...":
      size[1] = true
    if index == -1:
      terms.add(compileExpr(compiler, temp, true))
      index = 0
    else:
      let childNode = quote do: `temp`[`index`]
      terms.add(compileExpr(compiler, childNode, false))
      size[0] += 1
      index += 1
  if compiler.tokens.len > 0:
    compiler.tokens = compiler.tokens[1 .. ^1]
  let sizeNode = newLit(size[0])
  if not size[1]:
    terms = @[quote do: `temp`.len == `sizeNode`].concat(terms)
  else:
    terms = @[quote do: `temp`.len >= `sizeNode`].concat(terms)

  for term in terms:
    result = quote do: `result` and `term`

      
      # def compile_capt_ellip(tokens, cur_node, terms, index)
      #   capture = next_capture
      #   if (term = compile_seq_tail(tokens, "#{cur_node}.children.last"))
      #     terms << "(#{cur_node}.children.size > #{index})"
      #     terms << term
      #     terms << "(#{capture} = #{cur_node}.children[#{index}..-2])"
      #   else
      #     terms << "(#{cur_node}.children.size >= #{index})" if index > 0
      #     terms << "(#{capture} = #{cur_node}.children[#{index}..-1])"
      #   end
      #   terms
      # end

      # def compile_seq_tail(tokens, cur_node)
      #   tokens.shift
      #   if tokens.first == ')'
      #     tokens.shift
      #     nil
      #   else
      #     expr = compile_expr(tokens, cur_node, false)
      #     fail_due_to('missing )') unless tokens.shift == ')'
      #     expr
      #   end
      # end

proc compileUnion(compiler, node; head: bool): NimNode =
  if compiler.tokens.len == 0 or compiler.tokens[0] == UNION_END:
    error("empty")
  let temp = ident("temp" & $compiler.temp)
  compiler.temp += 1
  var init = quote:
    let `temp` = `node`; true
  
  var terms: seq[NimNode] = @[]
  while compiler.tokens.len > 0:
    if compiler.tokens[0] == UNION_END:
      compiler.tokens = compiler.tokens[1 .. ^1]
      break  
    terms.add(compileExpr(compiler, node, head))
    
  result = quote do: false
  for term in terms:
    echo term.repr
    result = quote do: `result` or `term`
  result = quote do: `init` and `result`

proc compileIntersect(compiler, node; head: bool): NimNode =
  if compiler.tokens.len == 0 or compiler.tokens[0] == INTERSECT_END:
    error("empty")
  let temp = ident("temp" & $compiler.temp)
  compiler.temp += 1
  var init = quote:
    let `temp` = `node`; true
  
  var terms: seq[NimNode] = @[]
  while compiler.tokens.len > 0:
    if compiler.tokens[0] == INTERSECT_END:
      compiler.tokens = compiler.tokens[1 .. ^1]
      break
    terms.add(compileExpr(compiler, node, head))
    
  result = init
  for term in terms:
    result = quote do: `result` and `term`
          

proc compileCapture(compiler, node; head: bool): NimNode =
  var nextNode = ident("capture" & $compiler.capture)
  compiler.capture += 1

  if head:
    result = quote:
      let `nextNode` = `node`.typ; true
  else:
    result = quote:
      let `nextNode` = `node`
  let n0 = compileExpr(compiler, node, head)
  result = quote do: `result` and `n0`

proc compileNegation(compiler, node; head: bool): NimNode =
  let n0 = compileExpr(compiler, node, head)
  result = quote do: not `n0`

proc compileAscend(compiler, node; head: bool): NimNode =
  let n0 = quote do: not `node`.parent.isNil
  let n1 = compileExpr(compiler, quote do: `n0`.parent, head)
  result = quote do: `n0` and `n1`

proc compileWildcard(compiler, node; name: string, head: bool): NimNode =
  if name == "":
    result = ident("true")
  elif compiler.unify.hasKey(name):
    # (from ruby):
    # we have already seen a wildcard with this name before
    # so the value it matched the first time will already be stored
    # in a temp. check if this value matches the one stored in the temp
    let n0 = if head: (quote do: `node`.typ) else: (node)
    let n1 = ident("temp" & $compiler.unify[name])
    result = quote do: `n0` == `n1`
  else:
    let temp = ident("temp" & $compiler.temp)
    compiler.temp += 1
    compiler.unify[name] = compiler.temp - 1
    let n0 = if head: (quote do: `node`.typ) else: (node)
    result  = quote do: (let `temp` = `n0`; true)


proc compileFuncall(compiler, node; m: string, head: bool): NimNode =
  # call a method in the context which this pattern-matching
  # code is used in. pass target value as an argument
  echo "func"
  let n0 = ident(m[1 .. ^1])
  if m.endsWith("("):
    # TODO
    return nil
  else:
    let n1 = if head: (quote do: `node`.typ) else: node
    result = quote do: `m`(`n1`)


proc compileNumber(compiler, node; i: int, head: bool): NimNode =
  let n0 = if head: (quote do: `node`.typ) else: node
  let n1 = newLit(i)
  result = quote do: `n0` == `n1`

proc compileSymbol(compiler, node; text: string, head: bool): NimNode =
  let n0 = if head: (quote do: `node`.typ) else: node
  let n1 = newLit(text)
  result = quote do: `n0` == `n1`

proc compilePredicate(compiler, node; label: string, head: bool): NimNode =
  if label.endsWith(")"):
    # TODO
    result = nil
  else:
    let nimLabel = ident(if label.endsWith("?"): "is_" & label else: label)
    let n0 = if head: (quote do: `node`.typ) else: node
    result = quote do: `n0`.`nimLabel`()

proc compileNodeType(compiler, node; token: NimNode): NimNode =
  result = quote do: not `node`.isNil and `node`.`token`()


proc compileExpr(compiler: Compiler, node: NimNode, head: bool): NimNode =
  # read a single pattern-matching expression from the token stream,
  # return Ruby code which performs the corresponding matching operation
  # on 'cur_node' (which is Ruby code which evaluates to an AST node)
  #
  # the 'pattern-matching' expression may be a composite which
  # contains an arbitrary number of sub-expressions
  let token = compiler.tokens[0]
  compiler.tokens = compiler.tokens[1 .. ^1]
  echo "compile"
  echo token
  if token == "(": result = compileSeq(compiler, node, head)
  elif token == "{": result = compileUnion(compiler, node, head)
  elif token == "[": result = compileIntersect(compiler, node, head)
  elif token == "!": result = compileNegation(compiler, node, head)
  elif token == "$": result = compileCapture(compiler, node, head)
  elif token == "^": result = compileAscend(compiler, node, head)
  elif token == "...": result = ident("true")
  elif token.isWildcard():  result = compileWildcard(compiler, node, token[1..^1], head)
  elif token.isFuncall():   result = compileFuncall(compiler, node, token, head)
  elif token.isNumber():   result = compileNumber(compiler, node, token.parseInt(), head)
  elif token.isSymbol():   result = compileSymbol(compiler, node, token[1 .. ^1], head)
  elif token.isPredicate(): result = compilePredicate(compiler, node, token, head)
  elif token.isNode():      result = compileNodetype(compiler, node, ident("is" & token.capitalizeAscii() & "Type"))
  else:         error("token error")

nodeMatcher isCaseEquality, "(send _ :=== _)"

