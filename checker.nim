import 
  cops/style/[case_equality, begin_block],
  types, tables, os, strutils, yaml.serialization, streams, options, osproc, bench
  # cops/style/[case_equality, begin_block, send], cops/naming/[variable_name], cops/metrics/[method_length], cops/lint/[boolean_symbol, circular_argument_reference, disjunctive_assignment_in_constructor], 
  
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
setDefaultValue(CopConfig, IgnoreMacros, false)
setDefaultValue(CopConfig, IgnoredMethods, @[])
setDefaultValue(CopConfig, AllowParenthesesInMultilineCall, false)
setDefaultValue(CopConfig, AllowParenthesesInChaining, false)
setDefaultValue(CopConfig, AllowParenthesesInCamelCaseMethod, false)

proc startCops(path: string) =
  load(newFileStream(path), config)


var input = ""
startCops(".rubocop.yml")


if existsDir(paramStr(1)):
  var listOffenses: seq[(string, seq[Offense])] = @[]
  var isOffense = false
  var start = cpuTime()
  for path in walkDirRec(paramStr(1), yieldFilter={pcFile}):
    if path.endsWith(".rb"):
      when defined(ldebug):
        echo path
      benchmark "file":
        input = readFile(path)
      listOffenses.add((path, visitSource(input, path, directory=true)))
      if listOffenses[^1][1].len > 0:
        isOffense = true  
        stdout.write ($listOffenses[^1][1][0].severity)[0].toUpperAscii
      else:
        stdout.write "."
      stdout.flushFile
  stdout.write "\n"
  var finish = cpuTime()
  let elapsed = (finish - start) * 1000
  let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
  echo elapsedStr

  if not isOffense:
    echo "no offenses detected"
  else:
    for item in listOffenses:
      let path = item[0]
      let offenses = item[1]
      echo path
      offenseListEcho(offenses)
    echo listOffenses.len
else:
  var start = cpuTime()
  input = readFile(paramStr(1))
  discard visitSource(input, paramStr(1))
  var finish = cpuTime()
  let elapsed = (finish - start) * 1000
  let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
  echo elapsedStr
  offenseListEcho()


