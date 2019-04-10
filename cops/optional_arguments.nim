
import
  tables

cop :
  type
    OptionalArguments* = ref object of Cop
    ##  This cop checks for optional arguments to methods
    ##  that do not come at the end of the argument list
    ## 
    ##  @example
    ##    # bad
    ##    def foo(a = 1, b, c)
    ##    end
    ## 
    ##    # good
    ##    def baz(a, b, c = 1)
    ##    end
    ## 
    ##    def foobar(a = 1, b = 2, c = 3)
    ##    end
  const
    MSG = """Optional arguments should appear at the end of the argument list."""
  method onDef*(self: OptionalArguments; node: Node): void =
    var arguments = @[]
    eachMisplacedOptionalArg(arguments, proc (argument: Node): void =
      addOffense(argument))

  iterator eachMisplacedOptionalArg*(self: OptionalArguments; arguments: Array): void =
    if optargPositions.isEmpty or argPositions.isEmpty:
      return
    for optargPosition in optargPositions:
      if optargPosition > argPositions.max():
        break
      yield arguments[optargPosition]

  method argumentPositions*(self: OptionalArguments; arguments: Array): void =
    var
      optargPositions = @[]
      argPositions = @[]
    arguments.eachWithIndex(proc (argument: Node; index: Integer): void =
      if argument.isOptargType():
        optargPositions.<<(index)
      if argument.isArgType():
        argPositions.<<(index)
    )
    @[optargPositions, argPositions]

