import types, sequtils

const MSG* = "%<label>s has too many lines. [%<length>d/%<max>d]"


proc message[T](cop: T, length: int, maxLength: int): string =
  format(MSG, label=cop.copLabel(), length=length, max=maxLength)

proc validLine*(node: Node, i: int): bool =
  let line = lines(node, i).strip
  line.len != 0 and not line.startsWith("#")

proc loadCode(node: Node): Node =
  if node.typ == "def":
    node[2]
  elif node.typ == "defs":
    node[3]
  elif node.typ == "block":
    node[1]
  else:
    node

proc checkCodeLength*[T](cop: T, node: Node) =
  if node.isNil:
    return
  let code = loadCode(node)
  if code.isNil:
    return
  let first = code[0].loc.line + 1

  let last = if code.len > 0: code[code.len - 1].loc.line else: first
  var lines = 0
  for i in first .. last:
    if validLine(node, i):
      lines += 1
  if lines > config[cop.location].Max:
    addOffense(node, location=name, message=cop.message(lines, config[cop.location].Max))



