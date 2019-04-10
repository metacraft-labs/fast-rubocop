
import
  erb_new_arguments, test_tools

RSpec.describe(ErbNewArguments, "config", proc (): void =
  var cop = ()
  context("<= Ruby 2.5", "ruby25", proc (): void =
    test """does not register an offense when using `ERB.new` with non-keyword arguments""":
      expectNoOffenses("        ERB.new(str, nil, \'-\', \'@output_buffer\')\n".stripIndent))
  context(">= Ruby 2.6", "ruby26", proc (): void =
    test """registers an offense when using `ERB.new` with non-keyword 2nd argument""":
      expectOffense("""        ERB.new(str, nil)
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
""".stripIndent)
    test """registers an offense when using `ERB.new` with non-keyword 2nd and 3rd arguments""":
      expectOffense("""        ERB.new(str, nil, '-')
                          ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
""".stripIndent)
    test """registers an offense when using `ERB.new` with non-keyword 2nd, 3rd and 4th arguments""":
      expectOffense("""        ERB.new(str, nil, '-', '@output_buffer')
                               ^^^^^^^^^^^^^^^^ Passing eoutvar with the 4th argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, eoutvar: '@output_buffer')` instead.
                          ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
""".stripIndent)
    test """registers an offense when using `ERB.new` with non-keyword 2nd, 3rd and 4th arguments andkeyword 5th argument""":
      expectOffense("""        ERB.new(str, nil, '-', '@output_buffer', trim_mode: '-', eoutvar: '@output_buffer')
                               ^^^^^^^^^^^^^^^^ Passing eoutvar with the 4th argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, eoutvar: '@output_buffer')` instead.
                          ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
""".stripIndent)
    test """registers an offense when using `ERB.new` with non-keyword 2nd and 3rd arguments andkeyword 4th argument""":
      expectOffense("""        ERB.new(str, nil, '-', trim_mode: '-', eoutvar: '@output_buffer')
                          ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                     ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
""".stripIndent)
    test """registers an offense when using `::ERB.new` with non-keyword 2nd, 3rd and 4th arguments""":
      expectOffense("""        ::ERB.new(str, nil, '-', '@output_buffer')
                                 ^^^^^^^^^^^^^^^^ Passing eoutvar with the 4th argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, eoutvar: '@output_buffer')` instead.
                            ^^^ Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: '-')` instead.
                       ^^^ Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.
""".stripIndent)
    test """does not register an offense when using `ERB.new` with keyword arguments""":
      expectNoOffenses("        ERB.new(str, trim_mode: \'-\', eoutvar: \'@output_buffer\')\n".stripIndent)
    test """does not register an offense when using `ERB.new` without optional arguments""":
      expectNoOffenses("        ERB.new(str)\n".stripIndent)))
