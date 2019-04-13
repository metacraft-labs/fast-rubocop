
import
  sequtils

import
  configurableEnforcedStyle

cop :
  type
    SpecialGlobalVars* = ref object of Cop
    ## 
    ##  This cop looks for uses of Perl-style global variables.
    ## 
    ##  @example EnforcedStyle: use_english_names (default)
    ##    # good
    ##    puts $LOAD_PATH
    ##    puts $LOADED_FEATURES
    ##    puts $PROGRAM_NAME
    ##    puts $ERROR_INFO
    ##    puts $ERROR_POSITION
    ##    puts $FIELD_SEPARATOR # or $FS
    ##    puts $OUTPUT_FIELD_SEPARATOR # or $OFS
    ##    puts $INPUT_RECORD_SEPARATOR # or $RS
    ##    puts $OUTPUT_RECORD_SEPARATOR # or $ORS
    ##    puts $INPUT_LINE_NUMBER # or $NR
    ##    puts $LAST_READ_LINE
    ##    puts $DEFAULT_OUTPUT
    ##    puts $DEFAULT_INPUT
    ##    puts $PROCESS_ID # or $PID
    ##    puts $CHILD_STATUS
    ##    puts $LAST_MATCH_INFO
    ##    puts $IGNORECASE
    ##    puts $ARGV # or ARGV
    ##    puts $MATCH
    ##    puts $PREMATCH
    ##    puts $POSTMATCH
    ##    puts $LAST_PAREN_MATCH
    ## 
    ##  @example EnforcedStyle: use_perl_names
    ##    # good
    ##    puts $:
    ##    puts $"
    ##    puts $0
    ##    puts $!
    ##    puts $@
    ##    puts $;
    ##    puts $,
    ##    puts $/
    ##    puts $\
    ##    puts $.
    ##    puts $_
    ##    puts $>
    ##    puts $<
    ##    puts $$
    ##    puts $?
    ##    puts $~
    ##    puts $=
    ##    puts $*
    ##    puts $&
    ##    puts $`
    ##    puts $'
    ##    puts $+
    ## 
  const
    MSGBOTH = """Prefer `%<prefer>s` from the stdlib 'English' module (don't forget to require it) or `%<regular>s` over `%<global>s`."""
  const
    MSGENGLISH = """Prefer `%<prefer>s` from the stdlib 'English' module (don't forget to require it) over `%<global>s`."""
  const
    MSGREGULAR = "Prefer `%<prefer>s` over `%<global>s`."
  const
    ENGLISHVARS = {"$:": @["$LOAD_PATH"], "$\"": @["$LOADED_FEATURES"],
                 "$0": @["$PROGRAM_NAME"], "$!": @["$ERROR_INFO"],
                 "$@": @["$ERROR_POSITION"], "$;": @["$FIELD_SEPARATOR", "$FS"],
                 "$,": @["$OUTPUT_FIELD_SEPARATOR", "$OFS"],
                 "$/": @["$INPUT_RECORD_SEPARATOR", "$RS"],
                 "$\\": @["$OUTPUT_RECORD_SEPARATOR", "$ORS"],
                 "$.": @["$INPUT_LINE_NUMBER", "$NR"], "$_": @["$LAST_READ_LINE"],
                 "$>": @["$DEFAULT_OUTPUT"], "$<": @["$DEFAULT_INPUT"],
                 "$$": @["$PROCESS_ID", "$PID"], "$?": @["$CHILD_STATUS"],
                 "$~": @["$LAST_MATCH_INFO"], "$=": @["$IGNORECASE"],
                 "$*": @["$ARGV", "ARGV"], "$&": @["$MATCH"], "$`": @["$PREMATCH"],
                 "$\'": @["$POSTMATCH"], "$+": @["$LAST_PAREN_MATCH"]}.newTable()
  const
    PERLVARS = Hash[ENGLISHVARS.flatMap(proc (k: Symbol; vs: Array): void =
      vs.mapIt:
        (it, @[k]))]
  const
    NONENGLISHVARS = Set.new(@["$LOAD_PATH", "$LOADED_FEATURES", "$PROGRAM_NAME",
                             "ARGV"])
  method onGvar*(self: SpecialGlobalVars; node: Node): void =
    var globalVar = node[0]
    if
      var preferred = preferredNames(globalVar):
    if preferred.isInclude(globalVar):
      correctStyleDetected
    else:
      oppositeStyleDetected
      addOffense(node)

  method message*(self: SpecialGlobalVars; node: Node): void =
    var globalVar = node[0]
    if style == "use_english_names":
      formatEnglishMessage(globalVar)
    else:
      format(MSGREGULAR, prefer = preferredNames(globalVar)[0], global = globalVar)
  
  method autocorrect*(self: SpecialGlobalVars; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var globalVar = node[0]
      while node.parent and node.parent.isBeginType() and
          node.parent.children.isOne():
        var node = node.parent
      corrector.replace(node.sourceRange, replacement(node, globalVar)))

  method formatEnglishMessage*(self: SpecialGlobalVars; globalVar: Symbol): void =
    formatMessage(english, regular, globalVar)

  method formatMessage*(self: SpecialGlobalVars; english: Array; regular: Array;
                       global: Symbol): void =
    if regular.isEmpty.! and english.isEmpty.!:
      format(MSGBOTH, prefer = formatList(english), regular = formatList(regular),
             global = global)
    elif regular.isEmpty.!:
      format(MSGREGULAR, prefer = formatList(regular), global = global)
    elif english.isEmpty.!:
      format(MSGENGLISH, prefer = formatList(english), global = global)
    else:
      raise("Bug in SpecialGlobalVars - global var w/o preferred vars!")
  
  method formatList*(self: SpecialGlobalVars; items: Array): void =
    ##  For now, we assume that lists are 2 items or less. Easy grammar!
    items.join("` or `")

  method replacement*(self: SpecialGlobalVars; node: Node; globalVar: Symbol): void =
    var
      parentType = node.parent and node.parent.type
      preferredName = preferredNames(globalVar)[0]
    if @["dstr", "xstr", "regexp"].isInclude(parentType):
    else:
      return `$`()
    if style == "use_english_names":
      return englishNameReplacement(preferredName, node)
    """#(lvar :preferred_name)"""

  method preferredNames*(self: SpecialGlobalVars; global: Symbol): void =
    if style == "use_english_names":
      ENGLISHVARS[global]
    else:
      PERLVARS[global]
  
  method englishNameReplacement*(self: SpecialGlobalVars; preferredName: Symbol;
                                node: Node): void =
    if node.isBeginType():
      return """#{(lvar :preferred_name)}"""
    """{(lvar :preferred_name)}"""

  ENGLISHVARS.merge!(Hash[ENGLISHVARS.flatMap(proc (_: Symbol; vs: Array): void =
    vs.mapIt:
      (it, @[it]))])
  PERLVARS.merge!(Hash[PERLVARS.flatMap(proc (_: Symbol; vs: Array): void =
    vs.mapIt:
      (it, @[it]))])
  ENGLISHVARS.eachValue(proc (it: void): void =
    it.reeze).freeze()
  PERLVARS.eachValue(proc (it: void): void =
    it.reeze).freeze()
