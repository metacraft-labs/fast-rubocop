
import
  trailing_body_on_class, test_tools

suite "TrailingBodyOnClass":
  var cop = TrailingBodyOnClass()
  let("config", proc (): void =
    Config.new())
  test "registers an offense when body trails after class definition":
    expectOffense("""      class Foo; body
                 ^^^^ Place the first line of class body on its own line.
      end
      class Bar; def bar; end
                 ^^^^^^^^^^^^ Place the first line of class body on its own line.
      end
""".stripIndent)
  test "registers offense with multi-line class":
    expectOffense("""      class Foo; body
                 ^^^^ Place the first line of class body on its own line.
        def bar
          qux
        end
      end
""".stripIndent)
  test "accepts regular class":
    expectNoOffenses("""      class Foo
        def no_op; end
      end
""".stripIndent)
  test "accepts class inheritance":
    expectNoOffenses("""      class Foo < Bar
      end
""".stripIndent)
  test "auto-corrects body after class definition":
    var corrected = autocorrectSource("""      class Foo; body 
      end
""".stripIndent)
    expect(corrected).to(eq("""      class Foo 
        body 
      end
""".stripIndent))
  test "auto-corrects with comment after body":
    var corrected = autocorrectSource("""      class BarQux; foo # comment
      end
""".stripIndent)
    expect(corrected).to(eq("""      # comment
      class BarQux 
        foo 
      end
""".stripIndent))
  test "auto-corrects when there are multiple semicolons":
    var corrected = autocorrectSource("""      class Bar; def bar; end
      end
""".stripIndent)
    expect(corrected).to(eq("""      class Bar 
        def bar; end
      end
""".stripIndent))
  context("when class is not on first line of processed_source", proc (): void =
    test "auto-correct offense":
      var corrected = autocorrectSource(@["", "  class Foo; body ", "  end"].join(
          "\n"))
      expect(corrected).to(eq(@["", "  class Foo ", "    body ", "  end"].join("\n"))))
