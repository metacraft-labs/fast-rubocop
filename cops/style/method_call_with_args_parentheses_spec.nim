
import
  types

import
  method_call_with_args_parentheses, test_tools

RSpec.describe(MethodCallWithArgsParentheses, "config", proc () =
  var cop = ()
  context("when EnforcedStyle is require_parentheses (default)", proc () =
    let("cop_config", proc (): Table[string, seq[string]] =
      {"IgnoredMethods": @["puts"]}.newTable())
    test "accepts no parens in method call without args":
      expectNoOffenses("top.test")
    test "accepts parens in method call with args":
      expectNoOffenses("top.test(a, b)")
    test "accepts parens in method call with do-end blocks":
      expectNoOffenses("""        foo(:arg) do
          bar
        end
""".stripIndent)
    test "register an offense for method call without parens":
      expectOffense("""        top.test a, b
        ^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
""".stripIndent)
    context("when using safe navigation operator", "ruby23", proc () =
      test "register an offense for method call without parens":
        expectOffense("""          top&.test a, b
          ^^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
""".stripIndent))
    test "register an offense for non-receiver method call without parens":
      expectOffense("""        def foo
          test a, b
          ^^^^^^^^^ Use parentheses for method calls with arguments.
        end
""".stripIndent)
    test "register an offense for methods starting with capital without parens":
      expectOffense("""        def foo
          Test a, b
          ^^^^^^^^^ Use parentheses for method calls with arguments.
        end
""".stripIndent)
    test "register an offense for superclass call without parens":
      expectOffense("""        def foo
          super a
          ^^^^^^^ Use parentheses for method calls with arguments.
        end
""".stripIndent)
    test "register no offense for superclass call without args":
      expectNoOffenses("super")
    test "register no offense for yield without args":
      expectNoOffenses("yield")
    test "register no offense for superclass call with parens":
      expectNoOffenses("super(a)")
    test "register an offense for yield without parens":
      expectOffense("""        def foo
          yield a
          ^^^^^^^ Use parentheses for method calls with arguments.
        end
""".stripIndent)
    test "accepts no parens for operators":
      expectNoOffenses("top.test + a")
    test "accepts no parens for setter methods":
      expectNoOffenses("top.test = a")
    test "accepts no parens for unary operators":
      expectNoOffenses("!test")
    test "auto-corrects call by adding needed braces":
      var newSource = autocorrectSource("top.test a")
      expect(newSource).to(eq("top.test(a)"))
    test "auto-corrects superclass call by adding needed braces":
      var newSource = autocorrectSource("""        def foo
          super a
        end
""".stripIndent)
      expect(newSource).to(eq("""        def foo
          super(a)
        end
""".stripIndent))
    test "auto-corrects yield by adding needed braces":
      var newSource = autocorrectSource("""        def foo
          yield a
        end
""".stripIndent)
      expect(newSource).to(eq("""        def foo
          yield(a)
        end
""".stripIndent))
    test "auto-corrects fully parenthesized args by removing space":
      var newSource = autocorrectSource("        top.eq (1 + 2)\n".stripIndent)
      expect(newSource).to(eq("        top.eq(1 + 2)\n".stripIndent))
    test "auto-corrects parenthesized args for local methods by removing space":
      var newSource = autocorrectSource("""        def foo
          eq (1 + 2)
        end
""".stripIndent)
      expect(newSource).to(eq("""        def foo
          eq(1 + 2)
        end
""".stripIndent))
    test "auto-corrects call with multiple args by adding braces":
      var newSource = autocorrectSource("""        def foo
          eq 1, (2 + 3)
          eq 1, 2, 3
        end
""".stripIndent)
      expect(newSource).to(eq("""        def foo
          eq(1, (2 + 3))
          eq(1, 2, 3)
        end
""".stripIndent))
    test "auto-corrects partially parenthesized args by adding needed braces":
      var newSource = autocorrectSource("        top.eq (1 + 2) + 3\n".stripIndent)
      expect(newSource).to(eq("        top.eq((1 + 2) + 3)\n".stripIndent))
    test "auto-corrects calls with multiple args by adding needed braces":
      var newSource = autocorrectSource("        top.eq (1 + 2), 3\n".stripIndent)
      expect(newSource).to(eq("        top.eq((1 + 2), 3)\n".stripIndent))
    test "auto-corrects calls where arg is method call":
      var newSource = autocorrectSource("""        def my_method
          foo bar.baz(abc, xyz)
        end
""".stripIndent)
      expect(newSource).to(eq("""        def my_method
          foo(bar.baz(abc, xyz))
        end
""".stripIndent))
    test "auto-corrects calls where multiple args are method calls":
      var newSource = autocorrectSource("""        def my_method
          foo bar.baz(abc, xyz), foo(baz)
        end
""".stripIndent)
      expect(newSource).to(eq("""        def my_method
          foo(bar.baz(abc, xyz), foo(baz))
        end
""".stripIndent))
    test "auto-corrects calls where the argument node is a constant":
      var newSource = autocorrectSource("""        def my_method
          raise NotImplementedError
        end
""".stripIndent)
      expect(newSource).to(eq("""        def my_method
          raise(NotImplementedError)
        end
""".stripIndent))
    test "auto-corrects calls where the argument node is a number":
      var newSource = autocorrectSource("""        def my_method
          sleep 1
        end
""".stripIndent)
      expect(newSource).to(eq("""        def my_method
          sleep(1)
        end
""".stripIndent))
    test "ignores method listed in IgnoredMethods":
      expectNoOffenses("puts :test")
    context("when inspecting macro methods", proc () =
      let("cop_config", proc (): Table[string, string] =
        {"IgnoreMacros": "true"}.newTable())
      context("in a class body", proc () =
        test "does not register an offense":
          expectNoOffenses("""            class Foo
              bar :baz
            end
""".stripIndent))
      context("in a module body", proc () =
        test "does not register an offense":
          expectNoOffenses("""            module Foo
              bar :baz
            end
""".stripIndent))))
  context("when EnforcedStyle is omit_parentheses", proc () =
    let("cop_config", proc (): Table[string, string] =
      {"EnforcedStyle": "omit_parentheses"}.newTable())
    test "register an offense for parens in method call without args":
      expectOffense("""        top.test()
                ^^ Omit parentheses for method calls with arguments.
""".stripIndent)
    test "register an offense for multi-line method calls":
      expectOffense("""        test(
            ^ Omit parentheses for method calls with arguments.
          foo: bar
        )
""".stripIndent)
    test "register an offense for superclass call with parens":
      expectOffense("""        def foo
          super(a)
               ^^^ Omit parentheses for method calls with arguments.
        end
""".stripIndent)
    test "register an offense for yield call with parens":
      expectOffense("""        def foo
          yield(a)
               ^^^ Omit parentheses for method calls with arguments.
        end
""".stripIndent)
    test "register an offense for parens in the last chain":
      expectOffense("""        foo().bar(3).wait(4)
                         ^^^ Omit parentheses for method calls with arguments.
""".stripIndent)
    test "register an offense for parens in do-end blocks":
      expectOffense("""        foo(:arg) do
           ^^^^^^ Omit parentheses for method calls with arguments.
          bar
        end
""".stripIndent)
    test "register an offense for hashes in keyword values":
      expectOffense("""        method_call(hash: {foo: :bar})
                   ^^^^^^^^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
""".stripIndent)
    test "register an offense for %r regex literal as arguments":
      expectOffense("""        method_call(%r{foo})
                   ^^^^^^^^^ Omit parentheses for method calls with arguments.
""".stripIndent)
    test "register an offense in complex conditionals":
      expectOffense("""        def foo
          if cond.present? && verify?(:something)
            h.do_with(kw: value)
                     ^^^^^^^^^^^ Omit parentheses for method calls with arguments.
          elsif cond.present? || verify?(:something_else)
            h.do_with(kw: value)
                     ^^^^^^^^^^^ Omit parentheses for method calls with arguments.
          elsif whatevs?
            h.do_with(kw: value)
                     ^^^^^^^^^^^ Omit parentheses for method calls with arguments.
          end
        end
""".stripIndent)
    test "register an offense in assignments":
      expectOffense("""        foo = A::B.new(c)
                      ^^^ Omit parentheses for method calls with arguments.
        bar.foo = A::B.new(c)
                          ^^^ Omit parentheses for method calls with arguments.
        bar.foo(42).quux = A::B.new(c)
                                   ^^^ Omit parentheses for method calls with arguments.

        bar.foo(42).quux &&= A::B.new(c)
                                     ^^^ Omit parentheses for method calls with arguments.

        bar.foo(42).quux += A::B.new(c)
                                    ^^^ Omit parentheses for method calls with arguments.
""".stripIndent)
    test "register an offense for camel-case methods with arguments":
      expectOffense("""        Array(:arg)
             ^^^^^^ Omit parentheses for method calls with arguments.
""".stripIndent)
    test "accepts no parens in method call without args":
      expectNoOffenses("top.test")
    test "accepts no parens in method call with args":
      expectNoOffenses("top.test 1, 2, foo: bar")
    test "accepts parens in default argument value calls":
      expectNoOffenses("""        def regular(arg = default(42))
          nil
        end

        def seatle_style arg = default(42)
          nil
        end
""".stripIndent)
    test "accepts parens in default keyword argument value calls":
      expectNoOffenses("""        def regular(arg: default(42))
          nil
        end

        def seatle_style arg: default(42)
          nil
        end
""".stripIndent)
    test "accepts parens in method args":
      expectNoOffenses("top.test 1, 2, foo: bar(3)")
    test "accepts parens in nested method args":
      expectNoOffenses("top.test 1, 2, foo: [bar(3)]")
    test "accepts parens in calls with hash as arg":
      expectNoOffenses("top.test({foo: :bar})")
      expectNoOffenses("top.test({foo: :bar}.merge(baz: :maz))")
      expectNoOffenses("top.test(:first, {foo: :bar}.merge(baz: :maz))")
    test "accepts special lambda call syntax":
      expectNoOffenses("thing.()")
    test "accepts parens in chained method calls":
      expectNoOffenses("foo().bar(3).wait(4).it")
    test "accepts parens in chaining with operators":
      expectNoOffenses("foo().bar(3).wait(4) + 4")
    test "accepts parens in blocks with braces":
      expectNoOffenses("foo(1) { 2 }")
    test "accepts parens in calls with logical operators":
      expectNoOffenses("foo(a) && bar(b)")
      expectNoOffenses("foo(a) || bar(b)")
    test "accepts parens in calls with args with logical operators":
      expectNoOffenses("foo(a, b || c)")
      expectNoOffenses("foo a, b || c")
      expectNoOffenses("foo a, b(1) || c(2, d(3))")
    test "accepts parens in args splat":
      expectNoOffenses("foo(*args)")
      expectNoOffenses("foo *args")
      expectNoOffenses("foo(**kwargs)")
      expectNoOffenses("foo **kwargs")
    test "accepts parens in slash regexp literal as argument":
      expectNoOffenses("foo(/regexp/)")
    test "accepts parens in argument calls with braced blocks":
      expectNoOffenses("foo(bar(:arg) { 42 })")
    test "accepts parens in implicit #to_proc":
      expectNoOffenses("foo(&block)")
      expectNoOffenses("foo &block")
    test "accepts parens in super without args":
      expectNoOffenses("super()")
    test "accepts parens in super method calls as arguments":
      expectNoOffenses("super foo(bar)")
    test "accepts parens in super calls with braced blocks":
      expectNoOffenses("super(foo(bar)) { yield }")
    test "accepts parens in camel case method without args":
      expectNoOffenses("Array()")
    test "accepts parens in ternary condition calls":
      expectNoOffenses("        foo.include?(bar) ? bar : quux\n")
    test "accepts parens in args with ternary conditions":
      expectNoOffenses("        foo.include?(bar ? baz : quux)\n")
    test "accepts parens in splat calls":
      expectNoOffenses("""        foo(*bar(args))
        foo(**quux(args))
""")
    test "accepts parens in block passing calls":
      expectNoOffenses("        foo(&method(:args))\n")
    test "accepts parens in range literals":
      expectNoOffenses("""        1..limit(n)
        1...limit(n)
""")
    test "auto-corrects single-line calls":
      var original = "        top.test(1, 2, foo: bar(3))\n".stripIndent
      expect(autocorrectSource(original)).to(
          eq("        top.test 1, 2, foo: bar(3)\n".stripIndent))
    test "auto-corrects multi-line calls":
      var original = """        foo(
          bar: 3
        )
""".stripIndent
      expect(autocorrectSource(original)).to(eq("""        foo \
          bar: 3

""".stripIndent))
    test "auto-corrects multi-line calls with trailing whitespace":
      var original = """        foo( 
          bar: 3
        )
""".stripIndent
      expect(autocorrectSource(original)).to(eq("""        foo \ 
          bar: 3

""".stripIndent))
    test "auto-corrects complex multi-line calls":
      var original = """        foo(arg,
          option: true
        )
""".stripIndent
      expect(autocorrectSource(original)).to(eq("""        foo arg,
          option: true

""".stripIndent))
    test "auto-corrects chained calls":
      var original = "        foo().bar(3).wait(4)\n".stripIndent
      expect(autocorrectSource(original)).to(
          eq("        foo().bar(3).wait 4\n".stripIndent))
    test "auto-corrects camel-case methods with arguments":
      var original = "        Array(:arg)\n".stripIndent
      expect(autocorrectSource(original)).to(
          eq("        Array :arg\n".stripIndent))
    context("TargetRubyVersion >= 2.3", "ruby23", proc () =
      test "accepts parens in chaining with safe operators":
        expectNoOffenses("Something.find(criteria: given)&.field"))
    context("allowing parenthesis in chaining", proc () =
      let("cop_config", proc (): Table[string, string] =
        {"EnforcedStyle": "omit_parentheses", "AllowParenthesesInChaining": true}.newTable())
      test "register offense for single-line chaining without previous parens":
        expectOffense("""          Rails.convoluted.example.logger.error("something")
                                               ^^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
""".stripIndent)
      test "register offense for multi-line chaining without previous parens":
        expectOffense("""          Rails
            .convoluted
            .example
            .logger
            .error("something")
                  ^^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
""".stripIndent)
      test "accepts parens in the last call if previous calls with parens":
        expectNoOffenses("foo().bar(3).wait 4")
      test "does not auto-correct if any previous call have parentheses":
        var original = "          foo().bar(3).quux.wait(4)\n".stripIndent
        expect(autocorrectSource(original)).to(eq(original))
      test "auto-correct if previous does calls have parentheses":
        var original = "          foo.bar.wait(4)\n".stripIndent
        expect(autocorrectSource(original)).to(
            eq("          foo.bar.wait 4\n".stripIndent)))
    context("allowing parens in multi-line calls", proc () =
      let("cop_config", proc (): Table[string, string] =
        {"EnforcedStyle": "omit_parentheses",
         "AllowParenthesesInMultilineCall": true}.newTable())
      test "accepts parens for multi-line calls ":
        expectNoOffenses("""          test(
            foo: bar
          )
""".stripIndent)
      test "does not auto-correct":
        var original = """          foo(
            bar: 3
          )
""".stripIndent
        expect(autocorrectSource(original)).to(eq(original)))
    context("allowing parens in camel-case methods", proc () =
      let("cop_config", proc (): Table[string, string] =
        {"EnforcedStyle": "omit_parentheses",
         "AllowParenthesesInCamelCaseMethod": true}.newTable())
      test "accepts parens for camel-case method names":
        expectNoOffenses("Array(nil)"))))
