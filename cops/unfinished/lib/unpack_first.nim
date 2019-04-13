
cop :
  type
    UnpackFirst* = ref object of Cop
    ##  This cop checks for accessing the first element of `String#unpack`
    ##  which can be replaced with the shorter method `unpack1`.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    'foo'.unpack('h*').first
    ##    'foo'.unpack('h*')[0]
    ##    'foo'.unpack('h*').slice(0)
    ##    'foo'.unpack('h*').at(0)
    ## 
    ##    # good
    ##    'foo'.unpack1('h*')
    ## 
  const
    MSG = """Use `%<receiver>s.unpack1(%<format>s)` instead of `%<receiver>s.unpack(%<format>s)%<method>s`."""
  nodeMatcher isUnpackAndFirstElement, """          {
            (send $(send (...) :unpack $(...)) :first)
            (send $(send (...) :unpack $(...)) {:[] :slice :at} (int 0))
          }
"""
  method onSend*(self: UnpackFirst; node: Node): void =
    isUnpackAndFirstElement node:
      var
        range = firstElementRange(node, unpackCall)
        message = format(MSG, receiver = unpackCall.receiver.source,
                       format = unpackArg.source, method = range.source)
      addOffense(node, message = message)

  method autocorrect*(self: UnpackFirst; node: Node): void =
    isUnpackAndFirstElement node:
      lambda(proc (corrector: Corrector): void =
        corrector.remove(firstElementRange(node, unpackCall))
        corrector.replace(unpackCall.loc.selector, "unpack1"))

  method firstElementRange*(self: UnpackFirst; node: Node; unpackCall: Node): void =
    Range.new(node.loc.expression.sourceBuffer, unpackCall.loc.expression.endPos,
              node.loc.expression.endPos)

  extend(TargetRubyVersion)
  minimumTargetRubyVersion(0.0)
