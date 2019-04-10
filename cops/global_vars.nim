
import
  sequtils

cop :
  type
    GlobalVars* = ref object of Cop
    ##  This cop looks for uses of global variables.
    ##  It does not report offenses for built-in global variables.
    ##  Built-in global variables are allowed by default. Additionally
    ##  users can allow additional variables via the AllowedVariables option.
    ## 
    ##  Note that backreferences like $1, $2, etc are not global variables.
    ## 
    ##  @example
    ##    # bad
    ##    $foo = 2
    ##    bar = $foo + 5
    ## 
    ##    # good
    ##    FOO = 2
    ##    foo = 2
    ##    $stdin.read
  const
    MSG = "Do not introduce global variables."
  const
    BUILTINVARS = @["$:", "$LOAD_PATH", "$\"", "$LOADED_FEATURES", "$0",
                  "$PROGRAM_NAME", "$!", "$ERROR_INFO", "$@", "$ERROR_POSITION",
                  "$;", "$FS", "$FIELD_SEPARATOR", "$,", "$OFS",
                  "$OUTPUT_FIELD_SEPARATOR", "$/", "$RS",
                  "$INPUT_RECORD_SEPARATOR", "$\\", "$ORS",
                  "$OUTPUT_RECORD_SEPARATOR", "$.", "$NR", "$INPUT_LINE_NUMBER",
                  "$_", "$LAST_READ_LINE", "$>", "$DEFAULT_OUTPUT", "$<",
                  "$DEFAULT_INPUT", "$$", "$PID", "$PROCESS_ID", "$?",
                  "$CHILD_STATUS", "$~", "$LAST_MATCH_INFO", "$=", "$IGNORECASE",
                  "$*", "$ARGV", "$&", "$MATCH", "$`", "$PREMATCH", "$\'",
                  "$POSTMATCH", "$+", "$LAST_PAREN_MATCH", "$stdin", "$stdout",
                  "$stderr", "$DEBUG", "$FILENAME", "$VERBOSE", "$SAFE", "$-0", "$-a",
                  "$-d", "$-F", "$-i", "$-I", "$-l", "$-p", "$-v", "$-w", "$CLASSPATH",
                  "$JRUBY_VERSION", "$JRUBY_REVISION", "$ENV_JAVA"].mapIt:
      it.oSym
  method userVars*(self: GlobalVars): void =
    copConfig["AllowedVariables"].mapIt:
      it.oSym

  method isAllowedVar*(self: GlobalVars; globalVar: Symbol): void =
    BUILTINVARS.isInclude(globalVar) or userVars.isInclude(globalVar)

  method onGvar*(self: GlobalVars; node: Node): void =
    check(node)

  method onGvasgn*(self: void; node: void): void =
    check(node)

  method check*(self: GlobalVars; node: Node): void =
    var globalVar = node[0]
    if isAllowedVar(globalVar):
    else:
      addOffense(node, location = "name")
  
