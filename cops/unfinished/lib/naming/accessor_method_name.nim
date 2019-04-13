
import
  types

# cop :
#   type
#     AccessorMethodName* = ref object of Cop
#     ##  This cop makes sure that accessor methods are named properly.
#     ## 
#     ##  @example
#     ##    # bad
#     ##    def set_attribute(value)
#     ##    end
#     ## 
#     ##    # good
#     ##    def attribute=(value)
#     ##    end
#     ## 
#     ##    # bad
#     ##    def get_attribute
#     ##    end
#     ## 
#     ##    # good
#     ##    def attribute
#     ##    end
#   const
#     MSGREADER = "Do not prefix reader method names with `get_`."
#   const
#     MSGWRITER = "Do not prefix writer method names with `set_`."
  
#   method isBadReaderName*(self: AccessorMethodName; node: Node): bool
#   method isBadWriterName*(self: AccessorMethodName; node: Node): bool
  
  
#   method message*(self: AccessorMethodName; node: Node): string

#   method onDef*(self: AccessorMethodName; node: Node): void =
#     if not (self.isBadReaderName(node) or self.isBadWriterName(node)):
#       return
#     addOffense(node, location = name)

#   method message*(self: AccessorMethodName; node: Node): string =
#     if self.isBadReaderName(node):
#       MSGREADER
#     elif self.isBadWriterName(node):
#       MSGWRITER
#     else:
#       ""

#   method isBadReaderName*(self: AccessorMethodName; node: Node): bool =
#     $node.methodName.startsWith("get_") and not node.isArguments()

#   method isBadWriterName*(self: AccessorMethodName; node: Node): bool =
#     ($node.methodName).startsWith("set_") and len(node.arguments) == 1

