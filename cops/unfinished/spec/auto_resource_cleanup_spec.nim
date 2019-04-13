
import
  auto_resource_cleanup, test_tools

suite "AutoResourceCleanup":
  var cop = AutoResourceCleanup()
  test "registers an offense for File.open without block":
    expectOffense("""      File.open("filename")
      ^^^^^^^^^^^^^^^^^^^^^ Use the block version of `File.open`.
""".stripIndent)
  test "does not register an offense for File.open with block":
    expectNoOffenses("File.open(\"file\") { |f| something }")
  test "does not register an offense for File.open with block-pass":
    expectNoOffenses("File.open(\"file\", &:read)")
  test "does not register an offense for File.open with immediate close":
    expectNoOffenses("File.open(\"file\", \"w\", 0o777).close")
