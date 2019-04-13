
import
  useless_assignment, test_tools

suite "UselessAssignment":
  var cop = UselessAssignment()
  context("when a variable is assigned and unreferenced in a method", proc (): void =
    test "registers an offense":
      expectOffense("""        class SomeClass
          foo = 1
          puts foo
          def some_method
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
""".stripIndent))
  context("""when a variable is assigned and unreferenced in a singleton method defined with self keyword""", proc (): void =
    test "registers an offense":
      expectOffense("""        class SomeClass
          foo = 1
          puts foo
          def self.some_method
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
""".stripIndent))
  context("""when a variable is assigned and unreferenced in a singleton method defined with variable name""", proc (): void =
    test "registers an offense":
      expectOffense("""        1.times do
          foo = 1
          puts foo
          instance = Object.new
          def instance.some_method
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
""".stripIndent))
  context("when a variable is assigned and unreferenced in a class", proc (): void =
    test "registers an offense":
      expectOffense("""        1.times do
          foo = 1
          puts foo
          class SomeClass
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
""".stripIndent))
  context("""when a variable is assigned and unreferenced in a class subclassing another class stored in local variable""", proc (): void =
    test "registers an offense":
      expectOffense("""        1.times do
          foo = 1
          puts foo
          array_class = Array
          class SomeClass < array_class
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
""".stripIndent))
  context("""when a variable is assigned and unreferenced in a singleton class""", proc (): void =
    test "registers an offense":
      expectOffense("""        1.times do
          foo = 1
          puts foo
          instance = Object.new
          class << instance
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
""".stripIndent))
  context("when a variable is assigned and unreferenced in a module", proc (): void =
    test "registers an offense":
      expectOffense("""        1.times do
          foo = 1
          puts foo
          module SomeModule
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
""".stripIndent))
  context("when a variable is assigned and referenced when defining a module", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        x = Object.new
        module x::Foo
        end
""".stripIndent))
  context("when a variable is assigned and unreferenced in top level", proc (): void =
    test "registers an offense":
      expectOffense("""        foo = 1
        ^^^ Useless assignment to variable - `foo`.
        bar = 2
        puts bar
""".stripIndent))
  context("""when a variable is assigned with operator assignment in top level""", proc (): void =
    test "registers an offense":
      expectOffense("""        foo ||= 1
        ^^^ Useless assignment to variable - `foo`. Use `||` instead of `||=`.
""".stripIndent))
  context("""when a variable is assigned multiple times but unreferenced""", proc (): void =
    test "registers offenses for each assignment":
      expectOffense("""        def some_method
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          bar = 2
          foo = 3
          ^^^ Useless assignment to variable - `foo`.
          puts bar
        end
""".stripIndent))
  context("""when a referenced variable is reassigned but not re-referenced""", proc (): void =
    test "registers an offense for the non-re-referenced assignment":
      expectOffense("""        def some_method
          foo = 1
          puts foo
          foo = 3
          ^^^ Useless assignment to variable - `foo`.
        end
""".stripIndent))
  context("""when an unreferenced variable is reassigned and re-referenced""", proc (): void =
    test "registers an offense for the unreferenced assignment":
      expectOffense("""        def some_method
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          foo = 3
          puts foo
        end
""".stripIndent))
  context("when an unreferenced variable is reassigned in a block", proc (): void =
    test "accepts":
      expectNoOffenses("""        def const_name(node)
          const_names = []
          const_node = node

          loop do
            namespace_node, name = *const_node
            const_names << name
            break unless namespace_node
            break if namespace_node.type == :cbase
            const_node = namespace_node
          end

          const_names.reverse.join('::')
        end
""".stripIndent))
  context("when a referenced variable is reassigned in a block", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          foo = 1
          puts foo
          1.times do
            foo = 2
          end
        end
""".stripIndent))
  context("when a block local variable is declared but not assigned", proc (): void =
    test "accepts":
      expectNoOffenses("""        1.times do |i; foo|
        end
""".stripIndent))
  context("when a block local variable is assigned and unreferenced", proc (): void =
    test "registers offenses for the assignment":
      expectOffense("""        1.times do |i; foo|
          foo = 2
          ^^^ Useless assignment to variable - `foo`.
        end
""".stripIndent))
  context("when a variable is assigned in loop body and unreferenced", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          while true
            foo = 1
            ^^^ Useless assignment to variable - `foo`.
          end
        end
""".stripIndent))
  context("""when a variable is reassigned at the end of loop body and would be referenced in next iteration""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          total = 0
          foo = 0

          while total < 100
            total += foo
            foo += 1
          end

          total
        end
""".stripIndent))
  context("""when a variable is reassigned at the end of loop body and would be referenced in loop condition""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          total = 0
          foo = 0

          while foo < 100
            total += 1
            foo += 1
          end

          total
        end
""".stripIndent))
  context("when a setter is invoked with operator assignment in loop body", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          obj = {}

          while obj[:count] < 100
            obj[:count] += 1
          end
        end
""".stripIndent))
  context("""when a variable is reassigned in loop body but won't be referenced either next iteration or loop condition""", proc (): void =
    test "registers an offense":
      pending("""Requires an advanced logic that checks whether the return value of an operator assignment is used or not.""")
      expectOffense("""        def some_method
          total = 0
          foo = 0

          while total < 100
            total += 1
            foo += 1
            ^^^ Useless assignment to variable - `foo`.
          end

          total
        end
""".stripIndent))
  context("""when a referenced variable is reassigned but not re-referenced in a method defined in loop""", proc (): void =
    test "registers an offense":
      expectOffense("""        while true
          def some_method
            foo = 1
            puts foo
            foo = 3
            ^^^ Useless assignment to variable - `foo`.
          end
        end
""".stripIndent))
  context("""when a variable that has same name as outer scope variable is not referenced in a method defined in loop""", proc (): void =
    test "registers an offense":
      expectOffense("""        foo = 1

        while foo < 100
          foo += 1
          def some_method
            foo = 1
            ^^^ Useless assignment to variable - `foo`.
          end
        end
""".stripIndent))
  context("""when a variable is assigned in single branch if and unreferenced""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method(flag)
          if flag
            foo = 1
            ^^^ Useless assignment to variable - `foo`.
          end
        end
""".stripIndent))
  context("""when a unreferenced variable is reassigned in same branch and referenced after the branching""", proc (): void =
    test "registers an offense for the unreferenced assignment":
      expectOffense("""        def some_method(flag)
          if flag
            foo = 1
            ^^^ Useless assignment to variable - `foo`.
            foo = 2
          end

          foo
        end
""".stripIndent))
  context("""when a variable is reassigned in single branch if and referenced after the branching""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(flag)
          foo = 1

          if flag
            foo = 2
          end

          foo
        end
""".stripIndent))
  context("when a variable is reassigned in a loop", proc (): void =
    context("while loop", proc (): void =
      test "accepts":
        expectNoOffenses("""          def while(param)
            ret = 1

            while param != 10
              param += 2
              ret = param + 1
            end

            ret
          end
""".stripIndent))
    context("post while loop", proc (): void =
      test "accepts":
        expectNoOffenses("""          def post_while(param)
            ret = 1

            begin
              param += 2
              ret = param + 1
            end while param < 40

            ret
          end
""".stripIndent))
    context("until loop", proc (): void =
      test "accepts":
        expectNoOffenses("""          def until(param)
            ret = 1

            until param == 10
              param += 2
              ret = param + 1
            end

            ret
          end
""".stripIndent))
    context("post until loop", proc (): void =
      test "accepts":
        expectNoOffenses("""          def post_until(param)
            ret = 1

            begin
              param += 2
              ret = param + 1
            end until param == 10

            ret
          end
""".stripIndent))
    context("for loop", proc (): void =
      test "accepts":
        expectNoOffenses("""          def for(param)
            ret = 1

            for x in param...10
              param += x
              ret = param + 1
            end

            ret
          end
""".stripIndent)))
  context("""when a variable is assigned in each branch of if and referenced after the branching""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(flag)
          if flag
            foo = 2
          else
            foo = 3
          end

          foo
        end
""".stripIndent))
  context("""when a variable is reassigned in single branch if and referenced in the branch""", proc (): void =
    test "registers an offense for the unreferenced assignment":
      expectOffense("""        def some_method(flag)
          foo = 1
          ^^^ Useless assignment to variable - `foo`.

          if flag
            foo = 2
            puts foo
          end
        end
""".stripIndent))
  context("""when a variable is assigned in each branch of if and referenced in the else branch""", proc (): void =
    test "registers an offense for the assignment in the if branch":
      expectOffense("""        def some_method(flag)
          if flag
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
          else
            foo = 3
            puts foo
          end
        end
""".stripIndent))
  context("""when a variable is reassigned and unreferenced in a if branch while the variable is referenced in the paired else branch """, proc (): void =
    test "registers an offense for the reassignment in the if branch":
      expectOffense("""        def some_method(flag)
          foo = 1

          if flag
            puts foo
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
          else
            puts foo
          end
        end
""".stripIndent))
  context("""when there's an unreferenced assignment in top level if branch while the variable is referenced in the paired else branch""", proc (): void =
    test "registers an offense for the assignment in the if branch":
      expectOffense("""        if flag
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
        else
          puts foo
        end
""".stripIndent))
  context("""when there's an unreferenced reassignment in a if branch while the variable is referenced in the paired elsif branch""", proc (): void =
    test "registers an offense for the reassignment in the if branch":
      expectOffense("""        def some_method(flag_a, flag_b)
          foo = 1

          if flag_a
            puts foo
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
          elsif flag_b
            puts foo
          end
        end
""".stripIndent))
  context("""when there's an unreferenced reassignment in a if branch while the variable is referenced in a case branch in the paired else branch""", proc (): void =
    test "registers an offense for the reassignment in the if branch":
      expectOffense("""        def some_method(flag_a, flag_b)
          foo = 1

          if flag_a
            puts foo
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
          else
            case
            when flag_b
              puts foo
            end
          end
        end
""".stripIndent))
  context("""when an assignment in a if branch is referenced in another if branch""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(flag_a, flag_b)
          if flag_a
            foo = 1
          end

          if flag_b
            puts foo
          end
        end
""".stripIndent))
  context("""when a variable is assigned in branch of modifier if that references the variable in its conditional clauseand referenced after the branching""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(flag)
          foo = 1 unless foo
          puts foo
        end
""".stripIndent))
  context("""when a variable is assigned in branch of modifier if that references the variable in its conditional clauseand unreferenced""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method(flag)
          foo = 1 unless foo
          ^^^ Useless assignment to variable - `foo`.
        end
""".stripIndent))
  context("""when a variable is assigned on each side of && and referenced after the &&""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          (foo = do_something_returns_object_or_nil) && (foo = 1)
          foo
        end
""".stripIndent))
  context("""when a unreferenced variable is reassigned on the left side of && and referenced after the &&""", proc (): void =
    test "registers an offense for the unreferenced assignment":
      expectOffense("""        def some_method
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          (foo = do_something_returns_object_or_nil) && do_something
          foo
        end
""".stripIndent))
  context("""when a unreferenced variable is reassigned on the right side of && and referenced after the &&""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          foo = 1
          do_something_returns_object_or_nil && foo = 2
          foo
        end
""".stripIndent))
  context("""when a variable is reassigned while referencing itself in rhs and referenced""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          foo = [1, 2]
          foo = foo.map { |i| i + 1 }
          puts foo
        end
""".stripIndent))
  context("""when a variable is reassigned with binary operator assignment and referenced""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          foo = 1
          foo += 1
          foo
        end
""".stripIndent))
  context("""when a variable is reassigned with logical operator assignment and referenced""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          foo = do_something_returns_object_or_nil
          foo ||= 1
          foo
        end
""".stripIndent))
  context("""when a variable is reassigned with binary operator assignment while assigning to itself in rhs then referenced""", proc (): void =
    test "registers an offense for the assignment in rhs":
      expectOffense("""        def some_method
          foo = 1
          foo += foo = 2
                 ^^^ Useless assignment to variable - `foo`.
          foo
        end
""".stripIndent))
  context("when a variable is assigned first with ||= and referenced", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          foo ||= 1
          foo
        end
""".stripIndent))
  context("""when a variable is assigned with ||= at the last expression of the scope""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          foo = do_something_returns_object_or_nil
          foo ||= 1
          ^^^ Useless assignment to variable - `foo`. Use `||` instead of `||=`.
        end
""".stripIndent))
  context("""when a variable is assigned with ||= before the last expression of the scope""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          foo = do_something_returns_object_or_nil
          foo ||= 1
          ^^^ Useless assignment to variable - `foo`.
          some_return_value
        end
""".stripIndent))
  context("""when a variable is assigned with multiple assignment and unreferenced""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          foo, bar = do_something
               ^^^ Useless assignment to variable - `bar`. Use `_` or `_bar` as a variable name to indicate that it won't be used.
          puts foo
        end
""".stripIndent))
  context("""when a variable is reassigned with multiple assignment while referencing itself in rhs and referenced""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          foo = 1
          foo, bar = do_something(foo)
          puts foo, bar
        end
""".stripIndent))
  context("""when a variable is assigned in loop body and referenced in post while condition""", proc (): void =
    test "accepts":
      expectNoOffenses("""        begin
          a = (a || 0) + 1
          puts a
        end while a <= 2
""".stripIndent))
  context("""when a variable is assigned in loop body and referenced in post until condition""", proc (): void =
    test "accepts":
      expectNoOffenses("""        begin
          a = (a || 0) + 1
          puts a
        end until a > 2
""".stripIndent))
  context("""when a variable is assigned in main body of begin with rescue but unreferenced""", proc (): void =
    test "registers an offense":
      expectOffense("""        begin
          do_something
          foo = true
          ^^^ Useless assignment to variable - `foo`.
        rescue
          do_anything
        end
""".stripIndent))
  context("""when a variable is assigned in main body of begin, rescue and else then referenced after the begin""", proc (): void =
    test "accepts":
      expectNoOffenses("""        begin
          do_something
          foo = :in_begin
        rescue FirstError
          foo = :in_first_rescue
        rescue SecondError
          foo = :in_second_rescue
        else
          foo = :in_else
        end

        puts foo
""".stripIndent))
  context("""when a variable is reassigned multiple times in main body of begin then referenced after the begin""", proc (): void =
    test "accepts":
      expectNoOffenses("""        begin
          status = :initial
          connect_sometimes_fails!
          status = :connected
          fetch_sometimes_fails!
          status = :fetched
        rescue
          do_something
        end

        puts status
""".stripIndent))
  context("""when a variable is reassigned multiple times in main body of begin then referenced in rescue""", proc (): void =
    test "accepts":
      expectNoOffenses("""        begin
          status = :initial
          connect_sometimes_fails!
          status = :connected
          fetch_sometimes_fails!
          status = :fetched
        rescue
          puts status
        end
""".stripIndent))
  context("""when a variable is reassigned multiple times in main body of begin then referenced in ensure""", proc (): void =
    test "accepts":
      expectNoOffenses("""        begin
          status = :initial
          connect_sometimes_fails!
          status = :connected
          fetch_sometimes_fails!
          status = :fetched
        ensure
          puts status
        end
""".stripIndent))
  context("""when a variable is reassigned multiple times in rescue and referenced after the begin""", proc (): void =
    test "registers an offense":
      expectOffense("""        foo = false

        begin
          do_something
        rescue
          foo = true
          ^^^ Useless assignment to variable - `foo`.
          foo = true
        end

        puts foo
""".stripIndent))
  context("""when a variable is reassigned multiple times in rescue with ensure then referenced after the begin""", proc (): void =
    test "registers an offense":
      expectOffense("""        foo = false

        begin
          do_something
        rescue
          foo = true
          ^^^ Useless assignment to variable - `foo`.
          foo = true
        ensure
          do_anything
        end

        puts foo
""".stripIndent))
  context("""when a variable is reassigned multiple times in ensure with rescue then referenced after the begin""", proc (): void =
    test "registers an offense":
      expectOffense("""        begin
          do_something
        rescue
          do_anything
        ensure
          foo = true
          ^^^ Useless assignment to variable - `foo`.
          foo = true
        end

        puts foo
""".stripIndent))
  context("""when a variable is assigned at the end of rescue and would be referenced with retry""", proc (): void =
    test "accepts":
      expectNoOffenses("""        retried = false

        begin
          do_something
        rescue
          fail if retried
          retried = true
          retry
        end
""".stripIndent))
  context("""when a variable is assigned with operator assignment in rescue and would be referenced with retry""", proc (): void =
    test "accepts":
      expectNoOffenses("""        retry_count = 0

        begin
          do_something
        rescue
          fail if (retry_count += 1) > 3
          retry
        end
""".stripIndent))
  context("""when a variable is assigned in main body of begin, rescue and else and reassigned in ensure then referenced after the begin""", proc (): void =
    test "registers offenses for each assignment before ensure":
      expectOffense("""        begin
          do_something
          foo = :in_begin
          ^^^ Useless assignment to variable - `foo`.
        rescue FirstError
          foo = :in_first_rescue
          ^^^ Useless assignment to variable - `foo`.
        rescue SecondError
          foo = :in_second_rescue
          ^^^ Useless assignment to variable - `foo`.
        else
          foo = :in_else
          ^^^ Useless assignment to variable - `foo`.
        ensure
          foo = :in_ensure
        end

        puts foo
""".stripIndent))
  context("""when a rescued error variable is wrongly tried to be referenced in another rescue body""", proc (): void =
    test "registers an offense":
      expectOffense("""        begin
          do_something
        rescue FirstError => error
                             ^^^^^ Useless assignment to variable - `error`.
        rescue SecondError
          p error # => nil
        end
""".stripIndent))
  context("""when a method argument is reassigned and zero arity super is called""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(foo)
          foo = 1
          super
        end
""".stripIndent))
  context("""when a local variable is unreferenced and zero arity super is called""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method(bar)
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          super
        end
""".stripIndent))
  context("""when a method argument is reassigned but not passed to super""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method(foo, bar)
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          super(bar)
        end
""".stripIndent))
  context("when a named capture is unreferenced in top level", proc (): void =
    test "registers an offense":
      expectOffense("""        /(?<foo>w+)/ =~ 'FOO'
        ^^^^^^^^^^^^ Useless assignment to variable - `foo`.
""".stripIndent))
  context("""when a named capture is unreferenced in other than top level""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          /(?<foo>\w+)/ =~ 'FOO'
          ^^^^^^^^^^^^^ Useless assignment to variable - `foo`.
        end
""".stripIndent))
  context("when a named capture is referenced", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          /(?<foo>w+)(?<bar> +)/ =~ 'FOO'
          puts foo
          puts bar
        end
""".stripIndent))
  context("""when a variable is referenced in rhs of named capture expression""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          foo = 'some string'
          /(?<foo>w+)/ =~ foo
          puts foo
        end
""".stripIndent))
  context("""when a variable is assigned in begin and referenced outside""", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          begin
            foo = 1
          end
          puts foo
        end
""".stripIndent))
  context("""when a variable is shadowed by a block argument and unreferenced""", proc (): void =
    test "registers an offense":
      expectOffense("""        def some_method
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          1.times do |foo|
            puts foo
          end
        end
""".stripIndent))
  context("when a variable is not used and the name starts with _", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method
          _foo = 1
          bar = 2
          puts bar
        end
""".stripIndent))
  context("when a method argument is not used", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(arg)
        end
""".stripIndent))
  context("when an optional method argument is not used", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(arg = nil)
        end
""".stripIndent))
  context("when a block method argument is not used", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(&block)
        end
""".stripIndent))
  context("when a splat method argument is not used", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(*args)
        end
""".stripIndent))
  context("when a optional keyword method argument is not used", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(name: value)
        end
""".stripIndent))
  context("when a keyword splat method argument is used", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(name: value, **rest_keywords)
          p rest_keywords
        end
""".stripIndent))
  context("when a keyword splat method argument is not used", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(name: value, **rest_keywords)
        end
""".stripIndent))
  context("when an anonymous keyword splat method argument is defined", proc (): void =
    test "accepts":
      expectNoOffenses("""        def some_method(name: value, **)
        end
""".stripIndent))
  context("when a block argument is not used", proc (): void =
    test "accepts":
      expectNoOffenses("""        1.times do |i|
        end
""".stripIndent))
  context("when there is only one AST node and it is unused variable", proc (): void =
    test "registers an offense":
      expectOffense("""        foo = 1
        ^^^ Useless assignment to variable - `foo`.
""".stripIndent))
  context("""when a variable is assigned while being passed to a method taking block""", proc (): void =
    context("and the variable is used", proc (): void =
      test "accepts":
        expectNoOffenses("""          some_method(foo = 1) do
          end
          puts foo
""".stripIndent))
    context("and the variable is not used", proc (): void =
      test "registers an offense":
        expectOffense("""          some_method(foo = 1) do
                      ^^^ Useless assignment to variable - `foo`.
          end
""".stripIndent)))
  context("""when a variable is assigned and passed to a method followed by method taking block""", proc (): void =
    test "accepts":
      expectNoOffenses("""        pattern = '*.rb'
        Dir.glob(pattern).map do |path|
        end
""".stripIndent))
  context("when a variable is assigned in 2 identical if branches", proc (): void =
    test "doesn\'t think 1 of the 2 assignments is useless":
      expectNoOffenses("""        def foo
          if bar
            foo = 1
          else
            foo = 1
          end
          foo.bar.baz
        end
""".stripIndent))
  describe("similar name suggestion", proc (): void =
    context("when there\'s a similar variable-like method invocation", proc (): void =
      test "suggests the method name":
        expectOffense("""          def some_method
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`. Did you mean `environment`?
            another_symbol
            puts environment
          end
""".stripIndent))
    context("when there\'s a similar variable", proc (): void =
      test "suggests the variable name":
        expectOffense("""          def some_method
            environment = nil
            another_symbol
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`. Did you mean `environment`?
            puts environment
          end
""".stripIndent))
    context("when there are only less similar names", proc (): void =
      test "does not suggest any name":
        expectOffense("""          def some_method
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`.
            another_symbol
            puts envelope
          end
""".stripIndent))
    context("when there\'s a similar method invocation with explicit receiver", proc (): void =
      test "does not suggest any name":
        expectOffense("""          def some_method
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`.
            another_symbol
            puts self.environment
          end
""".stripIndent))
    context("when there\'s a similar method invocation with arguments", proc (): void =
      test "does not suggest any name":
        expectOffense("""          def some_method
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`.
            another_symbol
            puts environment(1)
          end
""".stripIndent))
    context("when there\'s a similar name but it\'s in inner scope", proc (): void =
      test "does not suggest any name":
        expectOffense("""          class SomeClass
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`.

            def some_method(environment)
              puts environment
            end
          end
""".stripIndent)))
