
import
  mixin_usage, test_tools

suite "MixinUsage":
  var cop = MixinUsage()
  context("include", proc (): void =
    test "registers an offense when using outside class (used above)":
      expectOffense("""        include M
        ^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
        class C
        end
""".stripIndent)
    test "registers an offense when using outside class (used below)":
      expectOffense("""        class C
        end
        include M
        ^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
""".stripIndent)
    test "registers an offense when using only `include` statement":
      expectOffense("""        include M
        ^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
""".stripIndent)
    test """registers an offense when using `include` in method definition outside class or module""":
      expectOffense("""        def foo
          include M
          ^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
        end
""".stripIndent)
    test "does not register an offense when using outside class":
      expectNoOffenses("""        Foo.include M
        class C; end
""".stripIndent)
    test "does not register an offense when using inside class":
      expectNoOffenses("""        class C
          include M
        end
""".stripIndent)
    test "does not register an offense when using inside block":
      expectNoOffenses("""        Class.new do
          include M
        end
""".stripIndent)
    test "doesn\'t register an offense when `include` call is a method argument":
      expectNoOffenses("        do_something(include(M))\n".stripIndent)
    test """does not register an offense when using `include` in method definition inside class""":
      expectNoOffenses("""        class X
          def foo
            include M
          end
        end
""".stripIndent)
    test """does not register an offense when using `include` in method definition inside module""":
      expectNoOffenses("""        module X
          def foo
            include M
          end
        end
""".stripIndent)
    context("Multiple definition classes in one", proc (): void =
      test "does not register an offense when using inside class":
        expectNoOffenses("""          class C1
            include M
          end

          class C2
            include M
          end
""".stripIndent))
    context("Nested module", proc (): void =
      test "registers an offense when using outside class":
        expectOffense("""          include M1::M2::M3
          ^^^^^^^^^^^^^^^^^^ `include` is used at the top level. Use inside `class` or `module`.
          class C
          end
""".stripIndent)))
  context("extend", proc (): void =
    test "registers an offense when using outside class":
      expectOffense("""        extend M
        ^^^^^^^^ `extend` is used at the top level. Use inside `class` or `module`.
        class C
        end
""".stripIndent)
    test "does not register an offense when using inside class":
      expectNoOffenses("""        class C
          extend M
        end
""".stripIndent))
  context("prepend", proc (): void =
    test "registers an offense when using outside class":
      expectOffense("""        prepend M
        ^^^^^^^^^ `prepend` is used at the top level. Use inside `class` or `module`.
        class C
        end
""".stripIndent)
    test "does not register an offense when using inside class":
      expectNoOffenses("""        class C
          prepend M
        end
""".stripIndent))
  test "does not register an offense when using inside nested module":
    expectNoOffenses("""      module M1
        include M2

        class C
          include M3
        end
      end
""".stripIndent)
