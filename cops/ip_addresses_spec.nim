
import
  ip_addresses, test_tools

RSpec.describe(IpAddresses, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {:}.newTable())
  test "does not register an offense on an empty string":
    expectNoOffenses("\'\'")
  context("IPv4", proc (): void =
    test "registers an offense for a valid address":
      expectOffense("""        '255.255.255.255'
        ^^^^^^^^^^^^^^^^^ Do not hardcode IP addresses.
""".stripIndent)
    test "does not register an offense for an invalid address":
      expectNoOffenses("\"578.194.591.059\"")
    test "does not register an offense for an address inside larger text":
      expectNoOffenses("\"My IP is 192.168.1.1\""))
  context("IPv6", proc (): void =
    test "registers an offense for a valid address":
      expectOffense("""        '2001:0db8:85a3:0000:0000:8a2e:0370:7334'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not hardcode IP addresses.
""".stripIndent)
    test "registers an offense for an address with 0s collapsed":
      expectOffense("""        '2001:db8:85a3::8a2e:370:7334'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not hardcode IP addresses.
""".stripIndent)
    test "registers an offense for a shortened address":
      expectOffense("""        '2001:db8::1'
        ^^^^^^^^^^^^^ Do not hardcode IP addresses.
""".stripIndent)
    test "registers an offense for a very short address":
      expectOffense("""        '1::'
        ^^^^^ Do not hardcode IP addresses.
""".stripIndent)
    test "registers an offense for the loopback address":
      expectOffense("""        '::1'
        ^^^^^ Do not hardcode IP addresses.
""".stripIndent)
    test "does not register an offense for an invalid address":
      expectNoOffenses("\"2001:db8::1xyz\"")
    context("the unspecified address :: (shortform of 0:0:0:0:0:0:0:0)", proc (): void =
      test "does not register an offense":
        expectNoOffenses("\"::\"")
      context("when it is removed from the whitelist", proc (): void =
        let("cop_config", proc (): void =
          {"Whitelist": @[]}.newTable())
        test "registers an offense":
          expectOffense("""            '::'
            ^^^^ Do not hardcode IP addresses.
""".stripIndent))))
  context("with whitelist", proc (): void =
    let("cop_config", proc (): void =
      {"Whitelist": @["a::b"]}.newTable())
    test "does not register an offense for a whitelisted address":
      expectNoOffenses("\"a::b\"")
    test "does not register an offense if the case differs":
      expectNoOffenses("\"A::B\"")))
