import strformat, strutils, sequtils, sugar, unittest

proc stripIndent*(code: string): string =
  let lines = code.splitLines()
  var b = 0
  for i, c in lines[0]:
    if c != ' ':
      b = i
      break
  result = lines.mapIt(if it.len > b: it[b .. ^1] else: it).join("\n") & "\n"


template isAnnotation(child: string): untyped =
  "^^^" in child

template parseAnnotations(code: string): untyped =
  let lines = code.splitLines()
  var newCode = ""
  var annotations: seq[(int, string)] = @[]
  var line = 1
  for i, child in lines:
    if isAnnotation(child):
      annotations.add((line - 1, child.strip.split("^^^ ", 1)[1]))
    else:
      newCode.add(child)
      line += 1
  (newCode, annotations)

var testIndex = 0

template expectOffense*(code: string): untyped =
  let (source, annotations) = parseAnnotations(code)
  let offenses = visitSource(source, "test" & $testIndex, inTest=true)
  testIndex += 1
  check annotations.len == offenses.len
  for i, offense in offenses:
    check offense.msg == annotations[i][1]
    check offense.position.line == annotations[i][0]

export unittest