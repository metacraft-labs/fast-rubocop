
import
  unneeded_sort, test_tools

suite "UnneededSort":
  var cop = UnneededSort()
  test "registers an offense when first is called with sort":
    expectOffense("""      [1, 2, 3].sort.first
                ^^^^^^^^^^ Use `min` instead of `sort...first`.
""".stripIndent)
  test "registers an offense when last is called on sort with comparator":
    expectOffense("""      foo.sort { |a, b| b <=> a }.last
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `max` instead of `sort...last`.
""".stripIndent)
  test "registers an offense when first is called on sort_by":
    expectOffense("""      [1, 2, 3].sort_by { |x| x.length }.first
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...first`.
""".stripIndent)
  test "registers an offense when last is called on sort_by no block":
    expectOffense("""      [1, 2, 3].sort_by(&:length).last
                ^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...last`.
""".stripIndent)
  test "registers an offense when slice(0) is called on sort":
    expectOffense("""      [1, 2, 3].sort.slice(0)
                ^^^^^^^^^^^^^ Use `min` instead of `sort...slice(0)`.
""".stripIndent)
  test "registers an offense when [0] is called on sort":
    expectOffense("""      [1, 2, 3].sort[0]
                ^^^^^^^ Use `min` instead of `sort...[0]`.
""".stripIndent)
  test "registers an offense when [](0) is called on sort":
    expectOffense("""      [1, 2, 3].sort.[](0)
                ^^^^^^^^^^ Use `min` instead of `sort...[](0)`.
""".stripIndent)
  test "registers an offense when at(0) is called on sort_by":
    expectOffense("""      [1, 2, 3].sort_by(&:foo).at(0)
                ^^^^^^^^^^^^^^^^^^^^ Use `min_by` instead of `sort_by...at(0)`.
""".stripIndent)
  test "registers an offense when slice(-1) is called on sort_by":
    expectOffense("""      [1, 2, 3].sort_by(&:foo).slice(-1)
                ^^^^^^^^^^^^^^^^^^^^^^^^ Use `max_by` instead of `sort_by...slice(-1)`.
""".stripIndent)
  test "registers an offense when [-1] is called on sort":
    expectOffense("""      [1, 2, 3].sort[-1]
                ^^^^^^^^ Use `max` instead of `sort...[-1]`.
""".stripIndent)
  test "does not register an offense when first has an argument":
    expectNoOffenses("[1, 2, 3].sort.first(1)")
  test "does not register an offense for sort!.first":
    expectNoOffenses("[1, 2, 3].sort!.first")
  test "does not register an offense for sort_by!(&:something).last":
    expectNoOffenses("[1, 2, 3].sort_by!(&:something).last")
  test "does not register an offense when sort_by is used without first":
    expectNoOffenses("[1, 2, 3].sort_by { |x| -x }")
  test "does not register an offense when first is used without sort_by":
    expectNoOffenses("[1, 2, 3].first")
  test "does not register an offense when first is used before sort":
    expectNoOffenses("[[1, 2], [3, 4]].first.sort")
  test "does not register an offense when sort_by is not given a block":
    expectNoOffenses("[2, 1, 3].sort_by.first")
  context("when not taking first or last element", proc (): void =
    test "does not register an offense when [1] is called on sort":
      expectNoOffenses("[1, 2, 3].sort[1]")
    test "does not register an offense when at(-2) is called on sort_by":
      expectNoOffenses("[1, 2, 3].sort_by(&:foo).at(-2)"))
  context("autocorrect", proc (): void =
    test "corrects sort.first to min":
      var newSource = autocorrectSource("[1, 2].sort.first")
      expect(newSource).to(eq("[1, 2].min"))
    test "corrects sort.last to max":
      var newSource = autocorrectSource("[1, 2].sort.last")
      expect(newSource).to(eq("[1, 2].max"))
    test "corrects sort.first (with comparator) to min":
      var newSource = autocorrectSource("[1, 2].sort { |a, b| b <=> a }.first")
      expect(newSource).to(eq("[1, 2].min { |a, b| b <=> a }"))
    test "corrects sort.at(-1) to max":
      var newSource = autocorrectSource("[1, 2].sort.at(-1)")
      expect(newSource).to(eq("[1, 2].max"))
    test "corrects sort_by(&:foo).slice(0) to min_by(&:foo)":
      var newSource = autocorrectSource("[1, 2].sort_by(&:foo).slice(0)")
      expect(newSource).to(eq("[1, 2].min_by(&:foo)"))
    test "corrects sort_by(&:foo)[0] to min_by(&:foo)":
      var newSource = autocorrectSource("[1, 2].sort_by(&:foo)[0]")
      expect(newSource).to(eq("[1, 2].min_by(&:foo)"))
    test "corrects sort_by(&:something).first to min_by(&:something)":
      var newSource = autocorrectSource("[1, 2].sort_by(&:something).first")
      expect(newSource).to(eq("[1, 2].min_by(&:something)"))
    test "corrects sort_by { |x| x.foo }[-1] to max_by { |x| x.foo }":
      var newSource = autocorrectSource("foo.sort_by { |x| x.foo }[-1]")
      expect(newSource).to(eq("foo.max_by { |x| x.foo }"))
    test "corrects sort_by { |x| x.foo }.[](-1) to max_by { |x| x.foo }":
      var newSource = autocorrectSource("foo.sort_by { |x| x.foo }.[](-1)")
      expect(newSource).to(eq("foo.max_by { |x| x.foo }"))
    test """corrects sort_by { |x| x.something }.last to max_by { |x| x.something }""":
      var newSource = autocorrectSource("foo.sort_by { |x| x.something }.last")
      expect(newSource).to(eq("foo.max_by { |x| x.something }")))
