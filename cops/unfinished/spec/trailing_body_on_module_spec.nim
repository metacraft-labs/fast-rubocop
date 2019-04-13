
import
  trailing_body_on_module, test_tools

suite "TrailingBodyOnModule":
  var cop = TrailingBodyOnModule()
  let("config", proc (): void =
    Config.new())
  test "registers an offense when body trails after module definition":
    expectOffense("""      module Foo body
                 ^^^^ Place the first line of module body on its own line.
      end
      module Bar extend self
                 ^^^^^^^^^^^ Place the first line of module body on its own line.
      end
""".stripIndent)
  test "registers offense with multi-line module":
    expectOffense("""      module Foo body
                 ^^^^ Place the first line of module body on its own line.
        def bar
          qux
        end
      end
""".stripIndent)
  test "registers offense when module definition uses semicolon":
    expectOffense("""      module Foo; do_stuff
                  ^^^^^^^^ Place the first line of module body on its own line.
      end
""".stripIndent)
  test "accepts regular module":
    expectNoOffenses("""      module Foo
        def no_op; end
      end
""".stripIndent)
  test "auto-corrects body after module definition":
    var corrected = autocorrectSource("""      module Foo extend self 
      end
""".stripIndent)
    expect(corrected).to(eq("""      module Foo 
        extend self 
      end
""".stripIndent))
  test "auto-corrects with comment after body":
    var corrected = autocorrectSource("""      module BarQux; foo # comment
      end
""".stripIndent)
    expect(corrected).to(eq("""      # comment
      module BarQux 
        foo 
      end
""".stripIndent))
  test "auto-corrects when there are multiple semicolons":
    var corrected = autocorrectSource("""      module Bar; def bar; end
      end
""".stripIndent)
    expect(corrected).to(eq("""      module Bar 
        def bar; end
      end
""".stripIndent))
  context("when module is not on first line of processed_source", proc (): void =
    test "auto-correct offense":
      var corrected = autocorrectSource("""
        module Foo; body 
        end
""".stripIndent)
      expect(corrected).to(eq("""
        module Foo 
          body 
        end
""".stripIndent)))
