
import
  methodComplexity

cop :
  type
    AbcSize* = ref object of Cop
    ##  This cop checks that the ABC size of methods is not higher than the
    ##  configured maximum. The ABC size is based on assignments, branches
    ##  (method calls), and conditions. See http://c2.com/cgi/wiki?AbcMetric
  const
    MSG = """Assignment Branch Condition size for %<method>s is too high. [%<complexity>.4g/%<max>.4g]"""
  method complexity*(self: AbcSize; node: Node): void =
    AbcSizeCalculator.calculate(node)

