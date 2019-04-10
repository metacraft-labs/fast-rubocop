# Mercy

import os, strformat, strutils, yaml.serialization,  node_pattern, macros, tables, sequtils, terminal, bench
import "rubocop"/treesitter/[api, ruby], "rubocop"/[toast, globals]

type
  Node* = RNode

  Cop* = ref object of RootObj

  Config* = Table[string, CopConfig]

  CopConfig* = object
    RubyInterpreters*: seq[string]
    `Include`*: seq[string]
    DefaultFormatter*: string
    DisplayCopNames*: bool
    DisplayStyleGuide*: bool
    StyleGuideBaseURL*: string
    ExtraDetails*: bool
    Description*: string
    StyleGuide*: string
    Enabled*: bool
    VersionAdded*: string
    EnforcedStyle*: string
    SupportedStyles*: seq[string]
    ExcludedMethods*: seq[string]
    VersionChanged*: string
    CountComments*: bool
    Max*: int
    Severity*: Severity

  Symbol* = string

  Offense* = ref object
    msg*: string
    position*: Position
    copLocation*: string
    severity*: Severity

  Severity* = enum severity_none, refactor, convention, warning, error, fatal

  Position* = object
    path*: string
    line*: int
    col*: int
    endLine*: int
    endCol*: int

    node*: Node
  RNodeKind* = enum RbBegin, RbLvasgn, RbInt, RbDef, RbArgs, RbSymbol, RbClass, RbSend, RbNil, RbSym, RbConst, RbStr, RbArg, RbLvar, RbIvar, RbKwoptarg, RbOrAsgn, RbIvasgn, RbModule, RbArray, RbAnd, RbOr, RbIf, RbRegexp, RbReturn, RbBlockPass, RbErange, RbBlock, RbPair, RbHash, RbTrue, RbGvar, RbRescue, RbFalse, RbAlias, RbRestarg, RbKwbegin, RbCase, RbWhen, RbZsuper, RbSplat, RbOptarg, RbSelf, RbPreexe, RbWhile
  RNode* = ref object
    case kind: RNodeKind:
    of RbInt:
      i*: int
    of RbSymbol, RbArg, RbLvar, RbIvar, RbGvar:
      label*: string
    of RbSym, RbStr:
      text*: string
    else:
      discard
    children*: seq[RNode]
    start*: int
    last*: int


proc parse*(sourceText: string): TSNode

setDefaultValue(CopConfig, RubyInterpreters, @[])
setDefaultValue(CopConfig, `Include`, @[])
setDefaultValue(CopConfig, DefaultFormatter, "")
setDefaultValue(CopConfig, DisplayCopNames, false)
setDefaultValue(CopConfig, DisplayStyleGuide, false)
setDefaultValue(CopConfig, StyleGuideBaseURL, "")
setDefaultValue(CopConfig, ExtraDetails, false)
setDefaultValue(CopConfig, Description, "")
setDefaultValue(CopConfig, StyleGuide, "")
setDefaultValue(CopConfig, Enabled, false)
setDefaultValue(CopConfig, VersionAdded, "")
setDefaultValue(CopConfig, EnforcedStyle, "")
setDefaultValue(CopConfig, SupportedStyles, @[])
setDefaultValue(CopConfig, ExcludedMethods, @[])
setDefaultValue(CopConfig, VersionChanged, "")
setDefaultValue(CopConfig, CountComments, false)
setDefaultValue(CopConfig, Max, 0)
setDefaultValue(CopConfig, Severity, severity_none)

# FAITH
var config*: Config = initTable[string, CopConfig]()
#var cop_config* = config
# cop_config["Naming/VariableName"] = CopConfig(
#   EnforcedStyle: "snake_case"
# )
var source*: string = "" #readFile("class2.rb")

var currentOffenses*: seq[Offense]
var currentPath*: string = ""
var sources* = initTable[string, seq[string]]()

proc translate*(node: TSNode, code: TSNode, depth: int = 0): RNode

proc `[]`*(node: TSNode, index: int): TSNode

proc name*(node: TSNode): string

proc `$`*(node: RNode): string
proc `$`*(node: TSNode): string

template lecho*(a: untyped): untyped =
  when defined(ldetail):
    echo a

template typ*(node: RNode): string =
  ($node.kind)[2 .. ^1].toLowerAscii

template isLabel*(node: TSNode): bool =
  node.tsNodeType() == cstring"str" or node.tsNodeType() == cstring"identifier" or node.tsNodeType() == cstring"operator2" or node.tsNodeType() == cstring"sym"

template len*(node: TSNode): int =
  if isLabel(node):
    1
  else:
    node.tsNodeNamedChildCount().int

template typ*(node: TSNode): string =
  $node.tsNodeType()

iterator items*(node: RNode): RNode =
  for child in node.children:
    yield child

var RB_NIL_NODE = RNode(kind: RbNil)

iterator items*(node: TSNode): TSNode =
  var child: TSNode
  if not node.tsNodeIsNull() and node.tsNodeNamedChildCount() != 0:
    for i in 0 ..< node.tsNodeNamedChildCount():
      child = node.tsNodeNamedChild(i)
      yield child


template a*(b: untyped): untyped =  
  result = RNode(kind: `b`, children: @[])
  if node.tsNodeNamedChildCount() > 0'u32:
    for i in 0 ..< node.tsNodeNamedChildCount():
      var b = translate(node.tsNodeNamedChild(i), code, depth + 1)
      if not b.isNil:
        result.children.add(b)

template copypos*(rnode: untyped, node: untyped): untyped =
  if not rnode.isNil and not node.tsNodeIsNull():
    `rnode`.start = `node`.tsNodeStartByte().int
    `rnode`.last = `node`.tsNodeEndByte().int

template tohash*(node: untyped): untyped =
  var hashChildren: seq[RNode]
  for child in `node`.children:
    if child.isNil or child.kind != RbPair:
      hashChildren.add child
    else:
      if hashChildren.len == 0 or hashChildren[^1].isNil or hashChildren[^1].kind != RbHash:
        hashChildren.add(RNode(kind: RbHash, children: @[]))
      hashChildren[^1].children.add(child)
  `node`.children = hashChildren


const 
  KEYWORD_MAPPING = {
    RbBegin: "begin",
    RbIf: "if",
    RbWhile: "while",
    RbPreexe: "BEGIN"
  }.toTable()

var temp = ""
proc translate*(node: TSNode, code: TSNode, depth: int = 0): RNode =
  if node.tsNodeIsNull():
    result = RB_NIL_NODE
    return
  let typ = $node.tsNodeType()
  lecho repeat("  ", depth) & "TYP " & typ
  case typ:
  of "integer":
    result = RNode(kind: RbInt, i: parseInt(gStateRT.code[node.tsNodeStartByte() .. node.tsNodeEndByte() - 1].strip))
  of "program": a RbBegin
  of "assignment":
    if node[0].typ == "identifier":
      a RbLvasgn
  of "identifier":
    result = RNode(kind: RbSymbol, label: node.name)
  of "method_call":
    if node.len <= 2 or node[2].typ != "do_block":
      result = RNode(kind: RbSend, children: @[RNode(kind: RbNil), translate(node[0], code, depth + 1)])
      for child in node[1]:
        result.children.add(translate(child, code, depth + 1))
      tohash(result)
    else:
      result = RNode(kind: RbBlock, children: @[RNode(kind: RbSend, children: @[RNode(kind: RbNil), translate(node[0], code, depth + 1)])])
      for child in node[1]:
        result.children[0].children.add(translate(child, code, depth + 1))
      tohash(result.children[0])
      var args: RNode
      var t: RNode
      if node[2][0].typ != "block_parameters":
        args = RNode(kind: RbArgs, children: @[])
        t = translate(node[2][0], code)
      else:
        args = translate(node[2][0], code)
        t = translate(node[2][1], code)
      result.children.add(args)
      result.children.add(t)
  of "class": 
    a RbClass
    if result.children.len > 2:
      result.children = @[result.children[0], RNode(kind: RbNil), RNode(kind: RbBegin, children: result.children[1 .. ^1])]
  of "method": 
    a RbDef
    if result.children.len < 2:
      return nil
    if result.children[1].kind != RbArgs:
      result.children.insert(@[RNode(kind: RbArgs, children: @[])], 1)
    if result.children.len > 3:
      result.children = @[result.children[0], result.children[1], RNode(kind: RbBegin, children: result.children[2 .. ^1])]
  of "arg": 
    a RbArgs
  of "symbol":
    result = RNode(kind: RbSym, text: gStateRT.code[node.tsNodeStartByte() + 1 .. node.tsNodeEndByte()].strip)
  of "bare_symbol":
    result = RNode(kind: RbSym, text: gStateRT.code[node.tsNodeStartByte() .. node.tsNodeEndByte()].strip)
  of "constant":
    result = RNode(kind: RbConst, children: @[RB_NIL_NODE, RNode(kind: RbSymbol, label: node.name)])
  of "method_parameters", "block_parameters": 
    result = RNode(kind: RbArgs, children: @[])
    if node.tsNodeNamedChildCount() > 0'u32:
      for i in 0 ..< node.tsNodeNamedChildCount():
        var child = translate(node.tsNodeNamedChild(i), code, depth + 1)
        if not child.isNil and child.kind == RbSymbol:
          result.children.add(RNode(kind: RbArg, label: child.label))
        else:
          result.children.add(child)
  of "keyword_parameter":
    a RbKwoptarg
    if result.children.len > 1:
      var child = result.children[1]
      if child.kind == RbSymbol:
        child = RNode(kind: RbLvar, label: child.label)
        result.children[1] = child

  of "comment":
    result = nil

  of "call":
    a RbSend
    if result.children[0].kind == RbSymbol:
      result.children[0] = RNode(kind: RbLvar, label: result.children[0].label)
      copypos result.children[0], node
    tohash(result)
  of "operator_assignment":
    a RbOrAsgn
  of "instance_variable":
    new(result)
    result.kind = RbIvar
    result.label = node.name
  of "module":
    a RbModule
    if result.children.len > 2:
      result.children = @[result.children[0], RNode(kind: RbNil), RNode(kind: RbBegin, children: result.children[1 .. ^1])]
  of "binary":
    # a + b
    var first = translate(node[0], code)
    var second = translate(node[1], code)
    var op = RNode(kind: RbSymbol, label: node.tsNodeChild(1).name)
    if first.kind == RbSymbol:
      first = RNode(kind: RbLvar, label: first.label)
    if op.label notin @["and", "or", "&&", "||"]:
      result = RNode(kind: RbSend, children: @[first, op, second])
    else:
      if op.label in @["and", "&&"]:
        result = RNode(kind: RbAnd, children: @[first, second])
      else:
        result = RNode(kind: RbOr, children: @[first, second])
  of "array":
    a RbArray
  of "element_reference":
    var first = translate(node[0], code)
    var second = translate(node[1], code) 
    result = RNode(kind: RbSend, children: @[first, RNode(kind: RbSymbol, label: "[]"), second])  
  of "superclass":
    result = translate(node[0], code)
  of "if_modifier":
    var first = translate(node[0], code)
    var second = translate(node[1], code)
    result = RNode(kind: RbIf, children: @[second, first, RB_NIL_NODE])
  of "regex":
    a RbRegexp
  of "string", "escape_sequence":
    result = RNode(kind: RbStr, text: node.name)
  of "return":
    if node.len > 0 and node[0].typ == "argument_list":
      result = RNode(kind: RbReturn, children: node[0].mapIt(translate(it, code)))
    else:
      a RbReturn
  of "unless":
    var first = translate(node[0], code)
    var second = translate(node[0], code)
    result = RNode(kind: RbIf, children: @[RB_NIL_NODE, first, second])
  of "if":
    a RbIf
    result.children.add(RB_NIL_NODE)
  of "then":
    result = translate(node[0], code)
  of "unless_modifier":
    var first = translate(node[0], code)
    var second = translate(node[1], code)
    result = RNode(kind: RbIf, children: @[RB_NIL_NODE, second, first])
  of "block_argument":
    a RbBlockPass
  of "range":
    a RbErange
  of "parenthesized_statements":
    result = translate(node[0], code)
  of "else":
    result = translate(node[0], code)
  of "pair":
    a RbPair
  of "nil":
    result = RB_NIL_NODE
  of "true":
    result = RNode(kind: RbTrue)
  of "global_variable":
    result = RNode(kind: RbGvar, label: node.name)
  of "rescue":
    a RbRescue
  of "scope_resolution":
    var first = translate(node[0], code)
    var second = translate(node[1], code)
    if second.kind != RbNil:
      result = RNode(kind: RbConst, children: @[first, RNode(kind: RbSymbol, label: second.children[1].label)])
    else:
      result = first
  of "exceptions":
    a RbArray
  of "false":
    result = RNode(kind: RbFalse)
  of "heredoc_beginning":
    temp = node.name.strip[3 .. ^1]
  of "heredoc_body":
    # workaround: catches end
    var text = node.name
    if text.strip.endsWith(temp):
      text = text.strip(leading=false)[0 .. ^(temp.len + 1)]
    result = RNode(kind: RbStr, text: text)
    temp = ""
  of "heredoc_end":
    temp = ""
  of "alias":
    a RbAlias
  of "unary":
    var first = translate(node[0], code)
    var op = RNode(kind: RbSymbol, label: node.tsNodeChild(0).name)
    if first.kind == RbSymbol:
      first = RNode(kind: RbLvar, label: first.label)
    result = RNode(kind: RbSend, children: @[first, op])
  of "symbol_array":
    a RbArray
  of "conditional":
    a RbIf
    result.children.add(RB_NIL_NODE)
  of "elsif":
    a RbIf
    result.children.add(RB_NIL_NODE)
  of "splat_parameter":
    a RbRestarg
  of "hash":
    a RbHash
  of "begin":
    a RbKwbegin
  of "case":
    a RbCase
  of "when":
    a RbWhen
  of "pattern":
    result = translate(node[0], code)
  of "super":
    a RbZsuper
  of "splat_argument":
    a RbSplat
  of "optional_parameter":
    a RbOptarg
  of "self":
    a RbSelf
  of "begin_block":
    a RbPreexe
  else:
    lecho "ELSE"
    discard
  copypos result, node


proc text(node: RNode, depth: int): string =
  result = repeat("  ", depth)
  if node.isNil:
    return result & "nil"
  case node.kind:
  of RbInt:
    result.add &"(:int, {node.i})"
  of RbSymbol:
    result.add &":{node.label}"
  of RbNil:
    result.add "nil"
  of RbSym:
    result.add &"(:sym :{node.text})"
  of RbArg, RbLvar, RbIvar, RbGvar:
    result.add &"(:{($node.kind)[2 .. ^1].toLowerAscii} :{node.label})"
  of RbStr:
    result.add &"(:str, {node.text})"
  else:
    result.add &"(:{($node.kind)[2 .. ^1].toLowerAscii}"
    if node.children.len > 0:
      result.add ",\n"
      result.add node.children.mapIt(text(it, depth + 1)).join(",\n")
    result.add ")"

proc `$`*(node: RNode): string =
  text(node, 0)
  

proc `$`*(node: TSNode): string =
  if node.tsNodeIsNull():
    return "nil"
  else:
    var code = ""
    if $node.tsNodeType() == "sym":
      code = source[node.tsNodeStartByte() + 1..< node.tsNodeEndByte()]
      return code
    elif $node.tsNodeType() in @["identifier", "actual_const", "int", "class_variable", "str", "sym"]:
      code = source[node.tsNodeStartByte() ..< node.tsNodeEndByte()]
      return code
    code = ""
    return &"({$node.tsNodeType()} {code})"

proc name*(node: RNode): string =
  case node.kind:
  of RbSymbol, RbLvar, RbGvar:
    node.label
  else:
    ""

proc name*(node: TSNode): string =
  source[node.tsNodeStartByte() .. node.tsNodeEndByte() - 1]

converter toBool*(node: RNode): bool =
  node.kind != RbNil and node.start != node.last

converter toSymbol*(node: RNode): Symbol =
  $node

converter toBool*(node: TSNode): bool =
  node.tsNodeType() != cstring"identifier" or node.tsNodeStartByte() != node.tsNodeEndByte()

converter toSymbol*(node: TSNode): Symbol =
  $node

proc `==`*(nodes: seq[RNode], values: seq[string]): bool =
  if nodes.len != values.len:
    return false
  for i in 0 ..< nodes.len:
    case nodes[i].kind:
    of RbStr, RbSym:
      if nodes[i].text != values[i][1 .. ^1]:
        return false
    of RbSymbol, RbArg, RbLvar, RbIvar, RbGvar:
      if nodes[i].label != values[i][1 .. ^1]:
        return false
    else:
      return false
  return true

proc `==`*(nodes: seq[TSNode], values: seq[string]): bool =
  if nodes.len != values.len:
    return false
  for i in 0 ..< nodes.len:
    if ($nodes[i]).strip != values[i]:
      return false
  return true

var targetRubyVersion* = 2.5

type
  NodeHandler* = proc(cop: Cop, node: Node)
const kinds = @["send", "lvasgn", "const", "cvasgn"]

macro initHandlers: untyped =
  result = nnkStmtList.newTree()
  for kind in kinds:
    let name = "on" & kind.capitalizeAscii
    # echo name
    if declared(name):
      let nameNode = ident(name)
      var n = quote:
        when declared(`nameNode`):
          handlers[`kind`.cstring] = @[(NodeHandler)`nameNode`]

      result.add(n)
  # echo result.repr

var NIL_NODE: TsNode

template parent*(node: RNode): Node =
  RNode(kind: RbNil)

proc isNil*(node: RNode): bool =
  let t = node
  let tptr = cast[pointer](t)
  tptr == nil or node.kind == RbNil

template parent*(node: TSNode): Node =
  NIL_NODE

proc isNil*(node: TSNode): bool =
  node == NIL_NODE


template isLabel*(node: RNode): bool =
  node.kind == RbSymbol



proc `[]`*(node: RNode, index: int): RNode =
  case node.kind:
  of RbLvar, RbIvar, RbArg, RbGvar:
    if index == 0:
      return RNode(kind: RbSymbol, label: node.label)
    else:
      return RB_NIL_NODE
  of RbTrue, RbFalse, RbNil, RbSelf:
    if index == 0:
      return RNode(kind: RbSymbol, label: ($node.kind).toLowerAscii[2 .. ^1])
    else:
      return RB_NIL_NODE
  of RbInt:
    return node
  of RbStr, RbSymbol:
    return node
  of RbSym:
    return RNode(kind: RbSymbol, label: node.text)
  else:
    if node.children.len <= index:
      return RB_NIL_NODE
    else:
      return node.children[index]

proc `[]`*(node: TSNode, index: int): TSNode =
  if isLabel(node) and index == 0:
    return node
  elif node.tsNodeIsNull() or node.tsNodeNamedChildCount() <= index.uint32:
    return NIL_NODE
  else:
    return node.tsNodeNamedChild(index.uint32)

template `==`*(node: RNode, text: string): bool =
  node.kind == RbSymbol and node.name == text

template len*(node: RNode): int =
  if node.kind in {RbSymbol, RbInt, RbStr, RbSym, RbArg, RbLvar, RbGvar, RbTrue, RbFalse, RbNil, RbSelf}:
    1
  else:
    node.children.len

# HACK space
template `==`*(node: TSNode, text: string): bool =
  isLabel(node) and (source[node.tsNodeStartByte()] != ' ' and source[node.tsNodeStartByte() ..< node.tsNodeEndByte()] == text or source[node.tsNodeStartByte()] in {' ', ':'} and source[node.tsNodeStartByte() + 1 ..< node.tsNodeEndByte()] == text)

  
proc getLineCol*(node: RNode): tuple[line: int, col: int, lastLine: int, lastCol: int] =
  result.line = 1
  result.col = 1
  result.lastLine = 1
  result.lastCol = 1
  if node.isNil:
    return
  if node.start < 0 or node.start - 1 >= source.len:
    return
  for i in 0 .. node.start - 1:
    if source[i] == '\n':
      result.col = 0
      result.line += 1
    result.col += 1
  if node.last < 0 or node.last - 1 >= source.len:
    return
  for i in 0 .. node.last - 1:
    if source[i] == '\n':
      result.lastCol = 0
      result.lastLine += 1
    result.lastCol += 1
  
  

proc loc*(node: RNode): Position =
  let (line, col, lastLine, lastCol) = node.getLineCol()
  Position(path: currentPath, line: line, col: col, endLine: lastLine, endCol: lastCol, node: node)

proc operator*(position: Position): Position =
  var a= position.node[0]
  a.loc

proc nameRange*(position: Position): Position =
  position.node[0][0].loc

proc name*(position: Position): Position =
  position.node[0].loc

proc selector*(position: Position): Position =
  position

proc keyword*(position: Position): Position =
  result = position.node.loc
  let kind = position.node.kind
  let keyword = KEYWORD_MAPPING[kind]
  result.endLine = result.line
  result.endCol = result.col + keyword.len

template methodName*(node: RNode): string =
  var res = node[0]
  if res.start >= res.last:
    ""
  else:
    source[res.start ..< res.last]

template sendNode*(node: RNode): Node =
  node[0]

template body*(node: RNode): Node =
  node[node.len - 1]

template lines*(node: RNode, i: int): string =
  sources[currentPath][i]

template loc*(node: TSNode): Position =
  let (line, col) = node.getLineCol()
  Position(path: currentPath, line: line, col: col)

template methodName*(node: TSNode): string =
  var res = node[0]
  source[res.tsNodeStartByte() + 1 ..< res.tsNodeEndByte()]

template sendNode*(node: TSNode): Node =
  node[0]

template body*(node: TSNode): Node =
  node[node.len - 1]

template lines*(node: TSNode, i: int): string =
  sources[currentPath][i]


method location*(cop: Cop): string =
  "default"

method message*(cop: Cop, value: string): string =
  ""

method message*(cop: Cop, node: Node): string =
  ""

proc toSeq*(node: RNode): seq[RNode] =
  if node.kind in {RbArg, RbLvar, RbIvar, RbGvar, RBTrue, RbFalse, RbNil}:
    return @[node]
  else:
    result = @[]
    for child in node:
      result.add(child)

proc childNodes*(node: RNode): seq[RNode] =
  node.toSeq

proc toSeq*(node: TSNode): seq[TSNode] =
  if isLabel(node):
    return @[node]
  else:
    result = @[]
    for child in node:
      result.add(child)

proc childNodes*(node: TSNode): seq[TSNode] =
  node.toSeq

var handlers* = initTable[cstring, seq[(NodeHandler, Cop, string)]]()
var lastCop*: Cop

proc visit*(node: RNode, depth: int = 0, inTest: bool = false) =
  if not node.isNil:
    var kind = ($node.kind)[2 .. ^1].toLowerAscii
    if handlers.hasKey(kind):
      for handler in handlers[kind]:
        if inTest or config.hasKey(handler[2]) and config[handler[2]].Enabled:
          lastCop = handler[1]
          handler[0](handler[1], node)
    for child in node:
      visit(child, depth + 1, inTest=inTest)

# approach seen in nimterop
proc visit*(node: TSNode, depth: int = 0, inTest: bool = false) =
  var
    nextnode: TSNode
    depth = 0

  when defined(TSMODE):
    if not node.tsNodeIsNull() and depth > -1:
      let kind = node.tsNodeType()
      # echo "VISIT ", kind
      if handlers.hasKey(kind):
        for handler in handlers[kind]:
          if inTest or config.hasKey(handler[2]) and config[handler[2]].Enabled:
            lastCop = handler[1]
            handler[0](handler[1], node)
      for child in node:
        visit(child, depth + 1, inTest=inTest)

proc visitSource*(source: string, path: string, inTest: bool = false, directory: bool = false): seq[Offense] =
  currentOffenses = @[]
  var node: TSNode

  benchmark "parse":
    node = parse(source)
  lecho lisp(node)
  var rNode: RNode
  benchmark "translate":
    rNode = translate(node, node)
  lecho rNode
  currentPath = path
  sources[currentPath] = source.splitLines()
  gStateRT.code = source
  benchmark "visit":
    visit(rNode, inTest=true)
  when defined(ldebug):
    echo ""
  currentOffenses

macro format*(msg: static[string], args: varargs[untyped]): untyped =
  result = quote do: &""
  var newMsg = ""
  var i = 0
  var inToken = false
  while i < msg.len:
    var m = msg[i]
    if m == '%' and i < msg.len - 1 and msg[i + 1] == '<' and not inToken:
      newMsg.add('{')
      i += 2
      inToken = true
    elif m == '>' and inToken:
      newMsg.add('}')
      if i < msg.len - 2 and msg[i + 1] in {'d', 's', 'f'}:
        i += 2
      else:
        i += 1
      inToken = false
    else:
      newMsg.add(m)
      i += 1

  result[1] = newLit(newMsg)
  let msgNode = result
  result = nnkBlockStmt.newTree(newEmptyNode(), nnkStmtList.newTree())
  for arg in args:
    var left = arg[0]
    var right = arg[1]
    var q = quote:
      let `left` = `right`
    result[1].add(q)
  result[1].add(quote do: `msgNode`)
  echo result.repr

proc parse*(sourceText: string): TSNode =
  var parser = tsParserNew()
  source = sourceText
  gStateRT.code = sourceText
  doAssert parser.tsParserSetLanguage(treeSitterRuby()), "Failed to load Ruby parser"
  var input = parser.tsParserParseString(nil, source.cstring, source.len.uint32)
  result = input.tsTreeRootNode()

template value*(node: RNode): RNode =
  node[0]

template isIvasgnType*(node: RNode): bool =
  node.kind == RbIvasgn

template isLvarType*(node: RNode): bool =
  node.kind == RbLvar

template isSymType*(node: RNode): bool =
  node.kind == RbSym

template isSendType*(node: RNode): bool =
  node.kind == RbSend

template value*(node: TSNode): RNode =
  node[0]

template arguments*(node: RNode): RNode =
  node[1]

template isIvasgnType*(node: TSNode): bool =
  node.typ == "ivasgn" or node.typ == "send" and node.len == 1 and node[0].typ == "instance_variable"

template isLvarType*(node: TSNode): bool =
  node.typ == "send" and node.len == 1 and node[0].typ == "identifier" or node.typ == "identifier"

template isSymType*(node: TSNode): bool =
  node.typ == "sym"

template isSendType*(node: TSNode): bool =
  node.typ == "send"

template isArguments*(node: RNode): bool =
  node[1].len > 0



template first*[T](a: seq[T]): T =
  a[0]

template last*[T](a: seq[T]): T =
  a[a.len - 1]

when isMainModule:
  var node = parse(source)

  const MSG = "Replace class var %<class_var>s with a class " &
                "instance var."

  proc onCvasgn(node: Node) =
    var classVar = node[0]
    format(MSG, classVar=classVar)

  initHandlers()

  visit(node)

export toast, api

method msg*(cop: Cop, node: Node): string =
  cop.message(node)

template loc2*(cop: Cop): string =
  cop.location


# template addOffense*(node: Node, location: Position, message: string = "") =
#   let (line, col) = node.getLineCol()
#   var position = location
#   position.line = line
#   position.col = col
#   var severity = "W"
#   var copLocation = lastCop.loc
  
#   when declared(MSG):
#     currentOffenses.add(Offense(msg: if message.len == 0: MSG else: message, position: position, severity: severity, copLocation: copLocation))
#   else:
#     currentOffenses.add(Offense(msg: if message.len == 0: lastCop.msg(node) else: message, position: position, severity: severity, copLocation: copLocation))

macro addOffense*(node: Node, location: untyped = nil, message: string = "", sev: untyped = nil): untyped =
  result = nnkStmtList.newTree()
  if location.kind == nnkNilLit:
    var p = quote:
      var pos {.inject.} = `node`.loc
    result.add(p)
  else:
    var p = quote:
      var pos {.inject.} = `node`.loc.`location`
    result.add(p)
  if sev.kind == nnkNilLit:
    var t = quote:
      var severity {.inject.}: Severity
      if cop_config.Severity != severity_none:
        severity = cop_config.Severity
      else:
        severity = warning
    result.add(t)
  else:
    var t = quote:
      var severity {.inject.} = `sev`
    result.add(t)

  # we have the position of node by default but we add the selector
  # if we have it: we dont need dynamic code here, we can use CT
  result = quote:
    `result`
    # rubocop severity
    
    var copLocation = lastCop.loc2

    when declared(MSG):
      currentOffenses.add(Offense(msg: if `message`.len == 0: MSG else: `message`, position: pos, severity: severity, copLocation: copLocation))
    else:
      currentOffenses.add(Offense(msg: if `message`.len == 0: lastCop.msg(node) else: `message`, position: pos, severity: severity, copLocation: copLocation))

proc offenseListEcho*(offenses: seq[Offense] = currentOffenses): void =
  # we just immitate the progress format of rubocop
  for offense in offenses:
    styledWriteLine stdout, fgBlue, offense.position.path, resetStyle, & ":" & $offense.position.line & ":"  & $offense.position.col & ":" & " " & ($offense.severity)[0].toUpperAscii & ": " & offense.copLocation & ": " & $offense.msg
    echo sources[offense.position.path][offense.position.line - 1]
    var source = ""
    # echo offense.position
    for i in 1 .. < sources[offense.position.path][offense.position.line - 1].len + 1:
      if i < offense.position.col:
        source.add(' ')
      elif i >= offense.position.endCol:
        break
      else:
        # echo i, " ", offense.position.endCol
        source.add('^')
    echo source & "\n"

macro cop*(label: untyped, code: untyped): untyped =
  # we generate also forward methods, without using!

  result = nnkStmtList.newTree()
  var handlers: seq[NimNode]
  var a: seq[NimNode]
  var l: seq[NimNode]
  let typ = quote:
    type
      `label`* = ref object of Cop
  
  let usingNode = quote:
    using
      self: `label`
      node: Node

  var docstring: NimNode
  var e: seq[NimNode]
  for child in code:
    case child.kind:
    of nnkTypeSection:
      result.add(child)
      # label = child[0][0]
      # if label.kind != nnkIdent:
      #   label = label[1]
      # echo label.repr
      
    of nnkConstSection:
      result.add(child)
    of nnkCommentStmt:
      docstring = child
    of nnkMethodDef:
      if child[3].len > 1: # and child[3][1][1].repr == label.repr:
        let self1 = ident"self1"
        let self = ident"self"

        if ($child[0][1]).startsWith("on"):
          child[3][1][0] = self1
          child[3][1][1] = ident"Cop"
          handlers.add(child[0][1])
          let 
            b = quote:
              var `self` = (`label`)`self1`
          child[^1] = nnkStmtList.newTree(
            b,
            child[^1])
      l.add(child)
      var b = child.copy
      b[^1] = newEmptyNode()
      a.add(b)
    else:
      e.add(child)
  result.add(typ)
  result.add(docstring)
  result.add(usingNode)
  for i in a:
    result.add(i)
  for i in e:
    result.add(i)
  for i in l:
    result.add(i)

  result.add(quote do: saveCop `label`)
  for handler in handlers:
    result[^1].add(handler)
  let name = newLit($label)
  let t = quote:
    template cop_name: untyped =
      let path = instantiationInfo(0).filename
      path.split('/')[^2].capitalizeAscii & '/' & `name`
    
    
    template cop_config: untyped =
      config[cop_name()]

  let t2 = quote:
    method location*(cop: `label`): string =
      cop_name()
    
  result = quote:
    `t`
    `result`
    `t2`
  echo result.repr






macro saveCop*(cop: untyped, functions: varargs[untyped]): untyped =
  result = nnkStmtList.newTree()
  for label in functions:
    var b0 = label.repr[2 .. ^1]
    b0[0] = b0[0].toLowerAscii
    let b1 = newLit(b0)
    let b2 = newLit($cop)
    var b = quote:
      if not handlers.hasKey(cstring(`b1`)):
        handlers[cstring(`b1`)] = @[]
      # HACK
      handlers[cstring(`b1`)].add(((NodeHandler)`label`, (Cop)`cop`(), "Style/" & `b2`))
    result.add(b)
  echo result.repr

export strformat, sequtils, strutils, node_pattern, tables

