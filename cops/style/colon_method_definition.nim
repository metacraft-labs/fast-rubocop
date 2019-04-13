
import
  types

cop ColonMethodDefinition:
  ##  This cop checks for class methods that are defined using the `::`
  ##  operator instead of the `.` operator.
  ## 
  ##  @example
  ##    # bad
  ##    class Foo
  ##      def self::bar
  ##      end
  ##    end
  ## 
  ##    # good
  ##    class Foo
  ##      def self.bar
  ##      end
  ##    end
  ## 
  const
    MSG = "Do not use `::` for defining class methods."
  method onDefs*(self; node) =
    if not (node.loc.operator.source == "::"):
      return
    addOffense(node, location = operator)

