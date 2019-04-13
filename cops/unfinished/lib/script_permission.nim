
cop :
  type
    ScriptPermission* = ref object of Cop
  const
    MSG = "Script file %<file>s doesn\'t have execute permission."
  const
    SHEBANG = "#!"
  method investigate*(self: ScriptPermission; processedSource: ProcessedSource): void =
    if self.options.isKey("stdin"):
      return
    if Platform.isWindows:
      return
    if processedSource.isStartWith(SHEBANG):
    if isExecutable(processedSource):
      return
    var
      comment = processedSource.comments[0]
      message = formatMessageFrom(processedSource)
    addOffense(comment, message = message)

  method autocorrect*(self: ScriptPermission; node: Comment): void =
    lambda(proc (_corrector: Corrector): void =
      FileUtils.chmod("+x", node.loc.expression.sourceBuffer.name))

  method isExecutable*(self: ScriptPermission; processedSource: ProcessedSource): void =
    File.stat(processedSource.filePath).isExecutable()

  method formatMessageFrom*(self: ScriptPermission;
                           processedSource: ProcessedSource): void =
    var basename = File.basename(processedSource.filePath)
    format(MSG, file = basename)

