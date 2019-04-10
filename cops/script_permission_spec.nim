
import
  script_permission, test_tools

suite "ScriptPermission":
  var cop = ScriptPermission()
  let("config", proc (): void =
    Config.new)
  let("options", proc (): void =
  )
  let("file", proc (): void =
    Tempfile.new(""))
  let("filename", proc (): void =
    file().path.split("/").last())
  let("source", proc (): void =
    "#!/usr/bin/ruby\n\n")
  after(proc (): void =
    file().close
    file().unlink)
  context("with file permission 0644", proc (): void =
    before(proc (): void =
      File.write(file().path, source())
      FileUtils.chmod(420, file().path))
    if Platform.isWindows:
      context("Windows", proc (): void =
        test "allows any file permissions":
          expectNoOffenses("""            #!/usr/bin/ruby

""".stripIndent, file))
    else:
      test "registers an offense for script permission":
        expectOffense("""        #!/usr/bin/ruby
        ^^^^^^^^^^^^^^^ Script file (send nil :filename) doesn't have execute permission.

""".stripIndent,
                      file())
  )
  context("with file permission 0755", proc (): void =
    before(proc (): void =
      FileUtils.chmod(493, file().path))
    test "accepts with shebang line":
      File.write(file().path, source())
      expectNoOffenses(file().read(), file())
    test "accepts without shebang line":
      File.write(file().path, "puts \"hello\"")
      expectNoOffenses(file().read(), file())
    test "accepts with blank":
      File.write(file().path, "")
      expectNoOffenses(file().read(), file()))
  context("with stdin", proc (): void =
    let("options", proc (): void =
      {"stdin": ""}.newTable())
    test "skips investigation":
      expectNoOffenses(source()))
  if Platform.isWindows:
  else:
    context("auto-correct", proc (): void =
      test "adds execute permissions to the file":
        File.write(file().path, source())
        autocorrectSource(file().read(), file())
        expect(file().stat().isExecutable()).to(beTruthy))
