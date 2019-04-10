
import
  ordered_magic_comments, test_tools

RSpec.describe(OrderedMagicComments, "config", proc (): void =
  var cop = ()
  test """registers an offense when `encoding` magic comment does not precede all other magic comments""":
    expectOffense("""      # frozen_string_literal: true
      # encoding: ascii
      ^^^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
""".stripIndent)
  test """registers an offense when `coding` magic comment does not precede all other magic comments""":
    expectOffense("""      # frozen_string_literal: true
      # coding: ascii
      ^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
""".stripIndent)
  test """registers an offense when `-*- encoding : ascii-8bit -*-` magic comment does not precede all other magic comments""":
    expectOffense("""      # frozen_string_literal: true
      # -*- encoding : ascii-8bit -*-
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
""".stripIndent)
  test """registers an offense when using `frozen_string_literal` magic comment is next of shebang""":
    expectOffense("""      #!/usr/bin/env ruby
      # frozen_string_literal: true
      # encoding: ascii
      ^^^^^^^^^^^^^^^^^ The encoding magic comment should precede all other magic comments.
""".stripIndent)
  test """does not register an offense when using `encoding` magic comment is first line""":
    expectNoOffenses("""      # encoding: ascii
      # frozen_string_literal: true
""".stripIndent)
  test """does not register an offense when using `encoding` magic comment is next of shebang""":
    expectNoOffenses("""      #!/usr/bin/env ruby
      # encoding: ascii
      # frozen_string_literal: true
""".stripIndent)
  test "does not register an offense when using `encoding` magic comment only":
    expectNoOffenses("      # encoding: ascii\n".stripIndent)
  test """does not register an offense when using `frozen_string_literal` magic comment only""":
    expectNoOffenses("      # frozen_string_literal: true\n".stripIndent)
  test """does not register an offense when using `encoding: Encoding::SJIS` Hash notation after`frozen_string_literal` magic comment""":
    expectNoOffenses("""      # frozen_string_literal: true

      x = { encoding: Encoding::SJIS }
      puts x
""".stripIndent)
  test "autocorrects ordered magic comments":
    var newSource = autocorrectSource("""      # frozen_string_literal: true
      # encoding: ascii
""".stripIndent)
    expect(newSource).to(eq("""      # encoding: ascii
      # frozen_string_literal: true
""".stripIndent))
  test "autocorrects ordered magic comments with shebang":
    var newSource = autocorrectSource("""      #!/usr/bin/env ruby
      # frozen_string_literal: true
      # encoding: ascii
""".stripIndent)
    expect(newSource).to(eq("""      #!/usr/bin/env ruby
      # encoding: ascii
      # frozen_string_literal: true
""".stripIndent)))
