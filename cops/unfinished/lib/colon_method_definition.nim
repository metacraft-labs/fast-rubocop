
cop :
  type
    ColonMethodDefinition* = ref object of Cop
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
  method onDefs*(self: ColonMethodDefinition; node: Node): void =
    if node.loc.operator.source == "::":
    addOffense(node, location = "operator")

  method autocorrect*(self: ColonMethodDefinition; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.operator, "."))

