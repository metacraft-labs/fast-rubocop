
import
  rangeHelp

cop :
  type
    ChainArrayAllocation* = ref object of Cop
  const
    RETURNNEWARRAYWHENARGS = ":first :last :pop :sample :shift "
  const
    RETURNSNEWARRAYWHENNOBLOCK = ":zip :product "
  const
    ALWAYSRETURNSNEWARRAY = """:* :+ :- :collect :compact :drop :drop_while :flatten :map :reject :reverse :rotate :select :shuffle :sort :take :take_while :transpose :uniq :values_at :| """
  const
    HASMUTATIONALTERNATIVE = """:collect :compact :flatten :map :reject :reverse :rotate :select :shuffle :sort :uniq """
  const
    MSG = """Use unchained `%<method>s!` and `%<second_method>s!` (followed by `return array` if required) instead of chaining `%<method>s...%<second_method>s`."""
  nodeMatcher isFlatMapCandidate, """          {
            (send (send _ ${(const nil :RETURN_NEW_ARRAY_WHEN_ARGS)} {int lvar ivar cvar gvar}) ${(const nil :HAS_MUTATION_ALTERNATIVE)} $...)
            (send (block (send _ ${(const nil :ALWAYS_RETURNS_NEW_ARRAY) }) ...) ${(const nil :HAS_MUTATION_ALTERNATIVE)} $...)
            (send (send _ ${(send
  (const nil :ALWAYS_RETURNS_NEW_ARRAY) :+
  (const nil :RETURNS_NEW_ARRAY_WHEN_NO_BLOCK))} ...) ${(const nil :HAS_MUTATION_ALTERNATIVE)} $...)
          }
"""
  method onSend*(self: ChainArrayAllocation; node: Node): void =
    isFlatMapCandidate node:
      var range = rangeBetween(node.loc.dot.beginPos, node.sourceRange.endPos)
      addOffense(node, location = range,
                 message = format(MSG, method = fm, secondMethod = sm))

