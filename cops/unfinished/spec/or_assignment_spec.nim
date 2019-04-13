
import
  or_assignment, test_tools

suite "OrAssignment":
  var cop = OrAssignment()
  let("config", proc (): void =
    Config.new)
  context("when using var = var ? var : something", proc (): void =
    test "registers an offense with normal variables":
      expectOffense("""        foo = foo ? foo : 'default'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
""".stripIndent)
    test "registers an offense with instance variables":
      expectOffense("""        @foo = @foo ? @foo : 'default'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
""".stripIndent)
    test "registers an offense with class variables":
      expectOffense("""        @@foo = @@foo ? @@foo : 'default'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
""".stripIndent)
    test "registers an offense with global variables":
      expectOffense("""        $foo = $foo ? $foo : 'default'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
""".stripIndent)
    test "autocorrects normal variables to `var ||= something`":
      expect(autocorrectSource("x = x ? x : 3")).to(eq("x ||= 3"))
    test "autocorrects instance variables to `var ||= something`":
      expect(autocorrectSource("@x = @x ? @x : 3")).to(eq("@x ||= 3"))
    test "autocorrects class variables to `var ||= something`":
      expect(autocorrectSource("@@x = @@x ? @@x : 3")).to(eq("@@x ||= 3"))
    test "autocorrects global variables to `var ||= something`":
      expect(autocorrectSource("$x = $x ? $x : 3")).to(eq("$x ||= 3"))
    test "does not register an offense if any of the variables are different":
      expectNoOffenses("foo = bar ? foo : 3")
      expectNoOffenses("foo = foo ? bar : 3"))
  context("when using var = if var; var; else; something; end", proc (): void =
    test "registers an offense with normal variables":
      expectOffense("""        foo = if foo
        ^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
                foo
              else
                'default'
              end
""".stripIndent)
    test "registers an offense with instance variables":
      expectOffense("""        @foo = if @foo
        ^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
                 @foo
               else
                 'default'
               end
""".stripIndent)
    test "registers an offense with class variables":
      expectOffense("""        @@foo = if @@foo
        ^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
                  @@foo
                else
                  'default'
                end
""".stripIndent)
    test "registers an offense with global variables":
      expectOffense("""        $foo = if $foo
        ^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
                 $foo
               else
                 'default'
               end
""".stripIndent)
    test "autocorrects normal variables to `var ||= something`":
      expect(autocorrectSource("""        x = if x
              x
            else
              3
            end
""".stripIndent)).to(
          eq("x ||= 3\n"))
    test "autocorrects instance variables to `var ||= something`":
      expect(autocorrectSource("""        @x = if @x
               @x
             else
               3
             end
""".stripIndent)).to(
          eq("@x ||= 3\n"))
    test "autocorrects class variables to `var ||= something`":
      expect(autocorrectSource("""        @@x = if @@x
                @@x
              else
                3
              end
""".stripIndent)).to(
          eq("@@x ||= 3\n"))
    test "autocorrects global variables to `var ||= something`":
      expect(autocorrectSource("""        $x = if $x
               $x
             else
               3
             end
""".stripIndent)).to(
          eq("$x ||= 3\n"))
    test "does not register an offense if any of the variables are different":
      expectNoOffenses("""        foo = if foo
                bar
              else
                3
              end
""".stripIndent)
      expectNoOffenses("""        foo = if bar
                foo
              else
                3
              end
""".stripIndent))
  context("when using var = something unless var", proc (): void =
    test "registers an offense for normal variables":
      expectOffense("""        foo = 'default' unless foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
""".stripIndent)
    test "registers an offense for instance variables":
      expectOffense("""        @foo = 'default' unless @foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
""".stripIndent)
    test "registers an offense for class variables":
      expectOffense("""        @@foo = 'default' unless @@foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
""".stripIndent)
    test "registers an offense for global variables":
      expectOffense("""        $foo = 'default' unless $foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
""".stripIndent)
    test "autocorrects normal variables to `var ||= something`":
      expect(autocorrectSource("x = 3 unless x")).to(eq("x ||= 3"))
    test "autocorrects instance variables to `var ||= something`":
      expect(autocorrectSource("@x = 3 unless @x")).to(eq("@x ||= 3"))
    test "autocorrects class variables to `var ||= something`":
      expect(autocorrectSource("@@x = 3 unless @@x")).to(eq("@@x ||= 3"))
    test "autocorrects global variables to `var ||= something`":
      expect(autocorrectSource("$x = 3 unless $x")).to(eq("$x ||= 3"))
    test "does not register an offense if any of the variables are different":
      expectNoOffenses("foo = 3 unless bar")
      expectNoOffenses("""        unless foo
          bar = 3
        end
""".stripIndent))
  context("when using unless var; var = something; end", proc (): void =
    test "registers an offense for normal variables":
      expectOffense("""        foo = nil
        unless foo
        ^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
          foo = 'default'
        end
""".stripIndent)
    test "registers an offense for instance variables":
      expectOffense("""        @foo = nil
        unless @foo
        ^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
          @foo = 'default'
        end
""".stripIndent)
    test "registers an offense for class variables":
      expectOffense("""        @@foo = nil
        unless @@foo
        ^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
          @@foo = 'default'
        end
""".stripIndent)
    test "registers an offense for global variables":
      expectOffense("""        $foo = nil
        unless $foo
        ^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
          $foo = 'default'
        end
""".stripIndent)
    test "autocorrects normal variables to `var ||= something`":
      var newSourceNormal = autocorrectSource("""        foo = nil
        unless foo
          foo = 3
        end
""".stripIndent)
      expect(newSourceNormal).to(eq("foo = nil\nfoo ||= 3\n"))
    test "autocorrects instance variables to `var ||= something`":
      var newSourceInstance = autocorrectSource("""        @foo = nil
        unless @foo
          @foo = 3
        end
""".stripIndent)
      expect(newSourceInstance).to(eq("@foo = nil\n@foo ||= 3\n"))
    test "autocorrects class variables to `var ||= something`":
      var newSourceClass = autocorrectSource("""        @@foo = nil
        unless @@foo
          @@foo = 3
        end
""".stripIndent)
      expect(newSourceClass).to(eq("@@foo = nil\n@@foo ||= 3\n"))
    test "autocorrects global variables to `var ||= something`":
      var newSourceGlobal = autocorrectSource("""        $foo = nil
        unless $foo
          $foo = 3
        end
""".stripIndent)
      expect(newSourceGlobal).to(eq("$foo = nil\n$foo ||= 3\n"))
    test "does not register an offense if any of the variables are different":
      expectNoOffenses("""        unless foo
          bar = 3
        end
""".stripIndent))
