
import
  unneeded_capital_w, test_tools

suite "UnneededCapitalW":
  var cop = UnneededCapitalW()
  test "registers no offense for normal arrays of strings":
    expectNoOffenses("[\"one\", \"two\", \"three\"]")
  test "registers no offense for normal arrays of strings with interpolation":
    expectNoOffenses("[\"one\", \"two\", \"th#{?r}ee\"]")
  test "registers an offense for misused %W":
    expectOffense("""      %W(cat dog)
      ^^^^^^^^^^^ Do not use `%W` unless interpolation is needed. If not, use `%w`.
""".stripIndent)
    expectCorrection("      %w(cat dog)\n".stripIndent)
  test "registers an offense for misused %W with different bracket":
    expectOffense("""      %W[cat dog]
      ^^^^^^^^^^^ Do not use `%W` unless interpolation is needed. If not, use `%w`.
""".stripIndent)
    expectCorrection("      %w[cat dog]\n".stripIndent)
  test "registers no offense for %W with interpolation":
    expectNoOffenses("%W(c#{?a}t dog)")
  test "registers no offense for %W with special characters":
    expectNoOffenses("""      def dangerous_characters
        %W(\000) +
        %W(\001) +
        %W(\027) +
        %W(\002) +
        %W(\003) +
        %W(\004) +
        %W(\005) +
        %W(\006) +
        %W(\007) +
        %W(\00) +
        %W(\a)
        %W(\s)
        %W(\n)
        %W(\!)
      end
""".stripIndent)
  test "registers no offense for %w without interpolation":
    expectNoOffenses("%w(cat dog)")
  test "registers no offense for %w with interpolation-like syntax":
    expectNoOffenses("%w(c#{?a}t dog)")
  test "registers no offense for arrays with character constants":
    expectNoOffenses("[\"one\", ?\\n]")
  test "does not register an offense for array of non-words":
    expectNoOffenses("[\"one space\", \"two\", \"three\"]")
  test "does not register an offense for array containing non-string":
    expectNoOffenses("[\"one\", \"two\", 3]")
  test "does not register an offense for array with one element":
    expectNoOffenses("[\"three\"]")
  test "does not register an offense for array with empty strings":
    expectNoOffenses("[\"\", \"two\", \"three\"]")
