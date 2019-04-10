import times, os, strutils, sequtils, macros

template finish(benchmarkName: string, a: NimNode): untyped =
  let elapsed = (cpuTime() - `a`) * 1000
  let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
  echo "$1 $2" % [benchmarkName, elapsedStr]

macro benchmark*(benchmarkName: static[string], code: untyped): untyped =
  when defined(ldebug):
    var a = newIdentNode("c$1" % benchmarkName) # WORKS FOR MY SITUATION
    result = nnkStmtList.newTree()
    var empty = newEmptyNode()
    result.add(nnkVarSection.newTree(
      nnkIdentDefs.newTree(
        a,
        empty,
        nnkCall.newTree(
          newIdentNode("cpuTime")))))
    result.add(code)
    result.add(getAst(finish(benchmarkName, a)))
  else:
    result = code
export times
