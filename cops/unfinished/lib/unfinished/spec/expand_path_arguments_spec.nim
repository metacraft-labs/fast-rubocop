
import
  expand_path_arguments, test_tools

RSpec.describe(ExpandPathArguments, "config", proc (): void =
  var cop = ()
  test "registers an offense when using `File.expand_path(\'..\', __FILE__)`":
    expectOffense("""      File.expand_path('..', __FILE__)
           ^^^^^^^^^^^ Use `expand_path(__dir__)` instead of `expand_path('..', __FILE__)`.
""".stripIndent)
    expectCorrection("      File.expand_path(__dir__)\n".stripIndent)
  test "registers an offense when using `File.expand_path(\'../..\', __FILE__)`":
    expectOffense("""      File.expand_path('../..', __FILE__)
           ^^^^^^^^^^^ Use `expand_path('..', __dir__)` instead of `expand_path('../..', __FILE__)`.
""".stripIndent)
    expectCorrection("      File.expand_path(\'..\', __dir__)\n".stripIndent)
  test """registers an offense when using `File.expand_path('../../..', __FILE__)`""":
    expectOffense("""      File.expand_path('../../..', __FILE__)
           ^^^^^^^^^^^ Use `expand_path('../..', __dir__)` instead of `expand_path('../../..', __FILE__)`.
""".stripIndent)
    expectCorrection("      File.expand_path(\'../..\', __dir__)\n".stripIndent)
  test "registers an offense when using `File.expand_path(\'.\', __FILE__)`":
    expectOffense("""      File.expand_path('.', __FILE__)
           ^^^^^^^^^^^ Use `expand_path(__FILE__)` instead of `expand_path('.', __FILE__)`.
""".stripIndent)
    expectCorrection("      File.expand_path(__FILE__)\n".stripIndent)
  test """registers an offense when using `File.expand_path('../../lib', __FILE__)`""":
    expectOffense("""      File.expand_path('../../lib', __FILE__)
           ^^^^^^^^^^^ Use `expand_path('../lib', __dir__)` instead of `expand_path('../../lib', __FILE__)`.
""".stripIndent)
    expectCorrection("      File.expand_path(\'../lib\', __dir__)\n".stripIndent)
  test """registers an offense when using `File.expand_path('./../..', __FILE__)`""":
    expectOffense("""      File.expand_path('./../..', __FILE__)
           ^^^^^^^^^^^ Use `expand_path('..', __dir__)` instead of `expand_path('./../..', __FILE__)`.
""".stripIndent)
    expectCorrection("      File.expand_path(\'..\', __dir__)\n".stripIndent)
  test """registers an offense when using `Pathname(__FILE__).parent.expand_path`""":
    expectOffense("""      Pathname(__FILE__).parent.expand_path
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Pathname(__dir__).expand_path` instead of `Pathname(__FILE__).parent.expand_path`.
""".stripIndent)
    expectCorrection("      Pathname(__dir__).expand_path\n".stripIndent)
  test """registers an offense when using `Pathname.new(__FILE__).parent.expand_path`""":
    expectOffense("""      Pathname.new(__FILE__).parent.expand_path
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Pathname.new(__dir__).expand_path` instead of `Pathname.new(__FILE__).parent.expand_path`.
""".stripIndent)
    expectCorrection("      Pathname.new(__dir__).expand_path\n".stripIndent)
  test "does not register an offense when using `File.expand_path(__dir__)`":
    expectNoOffenses("      File.expand_path(__dir__)\n".stripIndent)
  test :
    expectNoOffenses("      File.expand_path(\'..\', __dir__)\n".stripIndent)
  test "does not register an offense when using `File.expand_path(__FILE__)`":
    expectNoOffenses("      File.expand_path(__FILE__)\n".stripIndent)
  test """does not register an offense when using `File.expand_path(path, __FILE__)`""":
    expectNoOffenses("      File.expand_path(path, __FILE__)\n".stripIndent)
  test """does not register an offense when using `File.expand_path("#{path_to_file}.png", __FILE__)`""":
    expectNoOffenses("      File.expand_path(\"#{path_to_file}.png\", __FILE__)\n".stripIndent)
  test """does not register an offense when using `Pathname(__dir__).expand_path`""":
    expectNoOffenses("      Pathname(__dir__).expand_path\n".stripIndent))
