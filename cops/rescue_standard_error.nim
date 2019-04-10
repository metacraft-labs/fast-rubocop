
import
  rescueNode

import
  configurableEnforcedStyle

import
  rangeHelp

cop :
  type
    RescueStandardError* = ref object of Cop
    ##  This cop checks for rescuing `StandardError`. There are two supported
    ##  styles `implicit` and `explicit`. This cop will not register an offense
    ##  if any error other than `StandardError` is specified.
    ## 
    ##  @example EnforcedStyle: implicit
    ##    # `implicit` will enforce using `rescue` instead of
    ##    # `rescue StandardError`.
    ## 
    ##    # bad
    ##    begin
    ##      foo
    ##    rescue StandardError
    ##      bar
    ##    end
    ## 
    ##    # good
    ##    begin
    ##      foo
    ##    rescue
    ##      bar
    ##    end
    ## 
    ##    # good
    ##    begin
    ##      foo
    ##    rescue OtherError
    ##      bar
    ##    end
    ## 
    ##    # good
    ##    begin
    ##      foo
    ##    rescue StandardError, SecurityError
    ##      bar
    ##    end
    ## 
    ##  @example EnforcedStyle: explicit (default)
    ##    # `explicit` will enforce using `rescue StandardError`
    ##    # instead of `rescue`.
    ## 
    ##    # bad
    ##    begin
    ##      foo
    ##    rescue
    ##      bar
    ##    end
    ## 
    ##    # good
    ##    begin
    ##      foo
    ##    rescue StandardError
    ##      bar
    ##    end
    ## 
    ##    # good
    ##    begin
    ##      foo
    ##    rescue OtherError
    ##      bar
    ##    end
    ## 
    ##    # good
    ##    begin
    ##      foo
    ##    rescue StandardError, SecurityError
    ##      bar
    ##    end
  const
    MSGIMPLICIT = """Omit the error class when rescuing `StandardError` by itself."""
  const
    MSGEXPLICIT = """Avoid rescuing without specifying an error class."""
  nodeMatcher isRescueWithoutErrorClass, "          (resbody nil? _ _)\n"
  nodeMatcher isRescueStandardError,
             "          (resbody $(array (const nil? :StandardError)) _ _)\n"
  method onResbody*(self: RescueStandardError; node: Node): void =
    if isRescueModifier(node):
      return
    case style
    of "implicit":
      isRescueStandardError node:
        addOffense(node, location = node.loc.keyword.join(error.loc.expression),
                   message = MSGIMPLICIT)
    of "explicit":
      isRescueWithoutErrorClass node:
        addOffense(node, location = "keyword", message = MSGEXPLICIT)
    else:

  method autocorrect*(self: RescueStandardError; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      case style
      of "implicit":
        var
          error = isRescueStandardError node
          range = rangeBetween(node.loc.keyword.endPos, error.loc.expression.endPos)
        corrector.remove(range)
      of "explicit":
        corrector.insertAfter(node.loc.keyword, " StandardError")
      else: )

