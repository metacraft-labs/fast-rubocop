
import
  date_time, test_tools

RSpec.describe(DateTime, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"AllowCoercion": false}.newTable())
  test "registers an offense when using DateTime for current time":
    expectOffense("""      DateTime.now
      ^^^^^^^^^^^^ Prefer Time over DateTime.
""".stripIndent)
  test "registers an offense when using ::DateTime for current time":
    expectOffense("""      ::DateTime.now
      ^^^^^^^^^^^^^^ Prefer Time over DateTime.
""".stripIndent)
  test "registers an offense when using DateTime for modern date":
    expectOffense("""      DateTime.iso8601('2016-06-29')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer Time over DateTime.
""".stripIndent)
  test "does not register an offense when using Time for current time":
    expectNoOffenses("Time.now")
  test "does not register an offense when using Date for modern date":
    expectNoOffenses("Date.iso8601(\'2016-06-29\')")
  test "does not register an offense when using DateTime for historic date":
    expectNoOffenses("DateTime.iso8601(\'2016-06-29\', Date::ENGLAND)")
  test "does not register an offense when using DateTime in another namespace":
    expectNoOffenses("Icalendar::Values::DateTime.new(start_at)")
  describe("when configured to not allow #to_datetime", proc (): void =
    before(proc (): void =
      copConfig().[]=("AllowCoercion", false))
    test "registers an offense":
      expectOffense("""        thing.to_datetime
        ^^^^^^^^^^^^^^^^^ Do not use #to_datetime.
""".stripIndent))
  describe("when configured to allow #to_datetime", proc (): void =
    before(proc (): void =
      copConfig().[]=("AllowCoercion", true))
    test "does not register an offense":
      expectNoOffenses("thing.to_datetime")))
