
import
  types

import
  tables

import
  file_name, test_tools

suite "FileName":
  var cop = FileName()
  let("config", proc (): Config =
    Config.new("/some/.rubocop.yml"))
  let("cop_config", proc (): Hash =
    {"IgnoreExecutableScripts": true, "ExpectMatchingDefinition": false, "Regex": }.newTable())
  let("includes", proc (): Array =
    @["**/*.rb"])
  let("source", proc (): string =
    "print 1")
  let("processed_source", proc (): ProcessedSource =
    parseSource(source()))
  before(proc (): void =
    allow(processedSource().buffer).to(receive("name").andReturn(filename()))
    _investigate(cop(), processedSource()))
  context("with camelCase file names ending in .rb", proc (): void =
    let("filename", proc (): string =
      "/some/dir/testCase.rb")
    test "reports an offense":
      expect(cop().offenses.size).to(eq(1)))
  context("with camelCase file names without file extension", proc (): void =
    let("filename", proc (): string =
      "/some/dir/testCase")
    test "reports an offense":
      expect(cop().offenses.size).to(eq(1)))
  context("with snake_case file names ending in .rb", proc (): void =
    let("filename", proc (): string =
      "/some/dir/test_case.rb")
    test "reports an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with snake_case file names without file extension", proc (): void =
    let("filename", proc (): string =
      "/some/dir/test_case")
    test "does not report an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with snake_case file names with non-rb extension", proc (): void =
    let("filename", proc (): string =
      "/some/dir/some_task.rake")
    test "does not report an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with snake_case file names with multiple extensions", proc (): void =
    let("filename", proc (): string =
      "some/dir/some_view.html.slim_spec.rb")
    test "does not report an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with snake_case names which use ? and !", proc (): void =
    let("filename", proc (): string =
      "some/dir/file?!.rb")
    test "does not report an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with snake_case names which use +", proc (): void =
    let("filename", proc (): string =
      "some/dir/some_file.xlsx+mobile.axlsx")
    test "does not report an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with non-snake-case file names with a shebang", proc (): void =
    let("filename", proc (): string =
      "/some/dir/test-case")
    let("source", proc (): string =
      """      #!/usr/bin/env ruby
      print 1
""".stripIndent)
    test "does not report an offense":
      expect(cop().offenses.isEmpty).to(be(true))
    context("when IgnoreExecutableScripts is disabled", proc (): void =
      let("cop_config", proc (): Hash =
        {"IgnoreExecutableScripts": false}.newTable())
      test "reports an offense":
        expect(cop().offenses.size).to(eq(1))))
  context("when the file is specified in AllCops/Include", proc (): Example =
    let("includes", proc (): Array =
      @["**/Gemfile"])
    context("with a non-snake_case file name", proc (): void =
      let("filename", proc (): string =
        "/some/dir/Gemfile")
      test "does not report an offense":
        expect(cop().offenses.isEmpty).to(be(true))))
  context("when ExpectMatchingDefinition is true", proc (): void =
    let("cop_config", proc (): Hash =
      {"IgnoreExecutableScripts": true, "ExpectMatchingDefinition": true}.newTable())
    context("on a file which defines no class or module at all", proc (): Class =
      for dir in @["lib", "src", "test", "spec"]:
        context("""under (lvar :dir)""", proc (): void =
          let("filename", proc (): string =
            """/some/dir/(lvar :dir)/file/test_case.rb""")
          test "registers an offense":
            expect(cop().offenses.size).to(eq(1))
            expect(cop().messages).to(eq(@["""test_case.rb should define a class or module called `File::TestCase`."""])))
      context("under some other random directory", proc (): void =
        let("filename", proc (): string =
          "/some/other/dir/test_case.rb")
        test "registers an offense":
          expect(cop().offenses.size).to(eq(1))
          expect(cop().messages).to(eq(@["""test_case.rb should define a class or module called `TestCase`."""]))))
    context("on an empty file", proc (): void =
      let("source", proc (): string =
        "")
      let("filename", proc (): string =
        "/lib/rubocop/blah.rb")
      test "registers an offense":
        expect(cop().offenses.size).to(eq(1))
        expect(cop().messages).to(eq(@["""blah.rb should define a class or module called `Rubocop::Blah`."""])))
    context("on an empty file with a space in its filename", proc (): void =
      let("source", proc (): string =
        "")
      let("filename", proc (): string =
        "a file.rb")
      test "registers an offense":
        expect(cop().offenses.size).to(eq(1))
        expect(cop().messages).to(eq(@["""The name of this source file (`a file.rb`) should use snake_case."""])))
    sharedExamples("matching module or class", proc (): Example =
      for dir in @["lib", "src", "test", "spec"]:
        context("""in a matching directory under (lvar :dir)""", proc (): void =
          let("filename", proc (): string =
            """/some/dir/(lvar :dir)/a/b.rb""")
          test "does not register an offense":
            expect(cop().offenses.isEmpty).to(be(true)))
        context("""in a non-matching directory under (lvar :dir)""", proc (): void =
          let("filename", proc (): string =
            """/some/dir/(lvar :dir)/c/b.rb""")
          test "registers an offense":
            expect(cop().offenses.size).to(eq(1))
            expect(cop().messages).to(eq(
                @["""b.rb should define a class or module called `C::B`."""])))
        context("""in a directory with multiple instances of (lvar :dir)""", proc (): void =
          let("filename", proc (): string =
            """/some/dir/(lvar :dir)/project/(lvar :dir)/a/b.rb""")
          test "does not register an offense":
            expect(cop().offenses.isEmpty).to(be(true)))
      context("in a directory elsewhere which only matches the module name", proc (): void =
        let("filename", proc (): string =
          "/some/dir/b.rb")
        test "does not register an offense":
          expect(cop().offenses.isEmpty).to(be(true)))
      context("in a directory elsewhere which does not match the module name", proc (): void =
        let("filename", proc (): string =
          "/some/dir/e.rb")
        test "registers an offense":
          expect(cop().offenses.size).to(eq(1))
          expect(cop().messages).to(eq(@[
              """e.rb should define a class or module called `E`."""]))))
    context("on a file which defines a nested module", proc (): void =
      let("source", proc (): string =
        """        module A
          module B
          end
        end
""".stripIndent)
      includeExamples("matching module or class"))
    context("on a file which defines a nested class", proc (): void =
      let("source", proc (): string =
        """        module A
          class B
          end
        end
""".stripIndent)
      includeExamples("matching module or class"))
    context("on a file which uses Name::Spaced::Module syntax", proc (): void =
      let("source", proc (): string =
        """        begin
          module A::B
          end
        end
""".stripIndent)
      includeExamples("matching module or class"))
    context("on a file which defines multiple classes", proc (): void =
      let("source", proc (): string =
        """        class X
        end
        module M
        end
        class A
          class B
          end
        end
""".stripIndent)
      includeExamples("matching module or class")))
  context("when Regex is set", proc (): Example =
    let("cop_config", proc (): Hash =
      {"Regex": }.newTable())
    context("with a matching name", proc (): void =
      let("filename", proc (): string =
        "a.rb")
      test "does not register an offense":
        expect(cop().offenses.isEmpty).to(be(true)))
    context("with a non-matching name", proc (): void =
      let("filename", proc (): string =
        "z.rb")
      test "registers an offense":
        expect(cop().offenses.size).to(eq(1))
        expect(cop().messages).to(eq(@["`z.rb` should match `(?i-mx:\\A[aeiou]\\z)`."]))))
  context("with acronym namespace", proc (): void =
    let("cop_config", proc (): Hash =
      {"IgnoreExecutableScripts": true, "ExpectMatchingDefinition": true,
       "AllowedAcronyms": @["CLI"]}.newTable())
    let("filename", proc (): string =
      "/lib/my/cli/admin_user.rb")
    let("source", proc (): string =
      """      module My
        module CLI
          class AdminUser
          end
        end
      end
""".stripIndent)
    test "does not register an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with acronym class name", proc (): void =
    let("cop_config", proc (): Hash =
      {"IgnoreExecutableScripts": true, "ExpectMatchingDefinition": true,
       "AllowedAcronyms": @["CLI"]}.newTable())
    let("filename", proc (): string =
      "/lib/my/cli.rb")
    let("source", proc (): string =
      """      module My
        class CLI
        end
      end
""".stripIndent)
    test "does not register an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with include acronym name", proc (): void =
    let("cop_config", proc (): Hash =
      {"IgnoreExecutableScripts": true, "ExpectMatchingDefinition": true,
       "AllowedAcronyms": @["HTTP"]}.newTable())
    let("filename", proc (): string =
      "/lib/my/http_server.rb")
    let("source", proc (): string =
      """      module My
        class HTTPServer
        end
      end
""".stripIndent)
    test "does not register an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("with dotfiles", proc (): void =
    let("filename", proc (): string =
      ".pryrc")
    test "does not report an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
