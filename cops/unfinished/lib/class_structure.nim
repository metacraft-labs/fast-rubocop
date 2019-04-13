
import
  tables

cop :
  type
    ClassStructure* = ref object of Cop
    ##  Checks if the code style follows the ExpectedOrder configuration:
    ## 
    ##  `Categories` allows us to map macro names into a category.
    ## 
    ##  Consider an example of code style that covers the following order:
    ##  - Constants
    ##  - Associations (has_one, has_many)
    ##  - Attributes (attr_accessor, attr_writer, attr_reader)
    ##  - Initializer
    ##  - Instance methods
    ##  - Protected methods
    ##  - Private methods
    ## 
    ##  You can configure the following order:
    ## 
    ##  ```yaml
    ##   Layout/ClassStructure:
    ##     Categories:
    ##       module_inclusion:
    ##         - include
    ##         - prepend
    ##         - extend
    ##     ExpectedOrder:
    ##         - module_inclusion
    ##         - constants
    ##         - public_class_methods
    ##         - initializer
    ##         - public_methods
    ##         - protected_methods
    ##         - private_methods
    ## 
    ##  ```
    ##  Instead of putting all literals in the expected order, is also
    ##  possible to group categories of macros.
    ## 
    ##  ```yaml
    ##   Layout/ClassStructure:
    ##     Categories:
    ##       association:
    ##         - has_many
    ##         - has_one
    ##       attribute:
    ##         - attr_accessor
    ##         - attr_reader
    ##         - attr_writer
    ##  ```
    ## 
    ##  @example
    ##    # bad
    ##    # Expect extend be before constant
    ##    class Person < ApplicationRecord
    ##      has_many :orders
    ##      ANSWER = 42
    ## 
    ##      extend SomeModule
    ##      include AnotherModule
    ##    end
    ## 
    ##    # good
    ##    class Person
    ##      # extend and include go first
    ##      extend SomeModule
    ##      include AnotherModule
    ## 
    ##      # inner classes
    ##      CustomError = Class.new(StandardError)
    ## 
    ##      # constants are next
    ##      SOME_CONSTANT = 20
    ## 
    ##      # afterwards we have attribute macros
    ##      attr_reader :name
    ## 
    ##      # followed by other macros (if any)
    ##      validates :name
    ## 
    ##      # public class methods are next in line
    ##      def self.some_method
    ##      end
    ## 
    ##      # initialization goes between class methods and instance methods
    ##      def initialize
    ##      end
    ## 
    ##      # followed by other public instance methods
    ##      def some_method
    ##      end
    ## 
    ##      # protected and private methods are grouped near the end
    ##      protected
    ## 
    ##      def some_protected_method
    ##      end
    ## 
    ##      private
    ## 
    ##      def some_private_method
    ##      end
    ##    end
    ## 
    ##  @see https://github.com/rubocop-hq/ruby-style-guide#consistent-classes
  const
    HUMANIZEDNODETYPE = {"casgn": "constants", "defs": "class_methods",
                       "def": "public_methods"}.newTable()
  const
    VISIBILITYSCOPES = @["private", "protected", "public"]
  const
    MSG = """`%<category>s` is supposed to appear before `%<previous>s`."""
  nodeMatcher isVisibilityBlock,
             "          (send nil? { :private :protected :public })\n"
  method onClass*(self: ClassStructure; classNode: Node): void =
    ##  Validates code style on class declaration.
    ##  Add offense when find a node out of expected order.
    var previous = -1
    walkOverNestedClassDefinition(classNode, proc (node: Node; category: string): void =
      var index = expectedOrder.index(category)
      if index < previous:
        var message = format(MSG, category = category,
                          previous = expectedOrder[previous])
        addOffense(node, message = message)
      var previous = index)

  method autocorrect*(self: ClassStructure; node: Node): void =
    ##  Autocorrect by swapping between two nodes autocorrecting them
    var
      nodeClassification = classify(node)
      previous = leftSiblingsOf(node).find(proc (sibling: Node): void =
        var classification = classify(sibling)
        isIgnore(classification).! and nodeClassification != classification)
      currentRange = sourceRangeWithComment(node)
      previousRange = sourceRangeWithComment(previous)
    lambda(proc (corrector: Corrector): void =
      corrector.insertBefore(previousRange, currentRange.source)
      corrector.remove(currentRange))

  method classify*(self: ClassStructure; node: Node): void =
    ##  Classifies a node to match with something in the {expected_order}
    ##  @param node to be analysed
    ##  @return String when the node type is a `:block` then
    ##    {classify} recursively with the first children
    ##  @return String when the node type is a `:send` then {find_category}
    ##    by method name
    ##  @return String otherwise trying to {humanize_node} of the current node
    if node.isRespondTo("type"):
    else:
      return node.toS
    case node.type
    of "block":
      classify(node.sendNode)
    of "send":
      findCategory(node.methodName)
    else:
      humanizeNode(node)
    .toS

  method findCategory*(self: ClassStructure; methodName: Symbol): void =
    ##  Categorize a method_name according to the {expected_order}
    ##  @param method_name try to match {categories} values
    ##  @return [String] with the key category or the `method_name` as string
    var
      name = `$`()
      category = categories[0]
    category or name

  iterator walkOverNestedClassDefinition*(self: ClassStructure; classNode: Node): void =
    for node in classElements(classNode):
      var classification = classify(node)
      if isIgnore(classification):
        continue
      yield node

  method classElements*(self: ClassStructure; classNode: Node): void =
    if classDef:
    else:
      return @[]
    if classDef.isDefType() or classDef.isSendType():
      @[classDef]
    else:
      classDef.children.compact()
  
  method isIgnore*(self: ClassStructure; classification: string): void =
    classification.isNil() or `$`().isEndWith("=") or
        expectedOrder.index(classification).isNil()

  method nodeVisibility*(self: ClassStructure; node: Node): void =
    methodName or "public"

  method findVisibilityStart*(self: ClassStructure; node: Node): void =
    leftSiblingsOf(node).reverse.find(proc (it: void): void =
      it.)

  method findVisibilityEnd*(self: ClassStructure; node: Node): void =
    ##  Navigate to find the last protected method
    var
      possibleVisibilities = VISIBILITYSCOPES - @[nodeVisibility(node)]
      right = rightSiblingsOf(node)
    right.find(proc (childNode: Node): void =
      possibleVisibilities.isInclude(nodeVisibility(childNode))) or
        right.last()

  method siblingsOf*(self: ClassStructure; node: Node): void =
    node.parent.children

  method rightSiblingsOf*(self: ClassStructure; node: Node): void =
    siblingsOf(node)[]

  method leftSiblingsOf*(self: ClassStructure; node: Node): void =
    siblingsOf(node)[0]

  method humanizeNode*(self: ClassStructure; node: Node): void =
    var methodName = node[0]
    if node.isDefType():
      if methodName == "initialize":
        return "initializer"
      return """(send nil :node_visibility
  (lvar :node))_methods"""
    HUMANIZEDNODETYPE[node.type] or node.type

  method sourceRangeWithComment*(self: ClassStructure; node: Node): void =
    Range.new(buffer, beginPos, endPos)

  method endPositionFor*(self: ClassStructure; node: Node): void =
    var endLine = buffer.lineForPosition(node.loc.expression.endPos)
    buffer.lineRange(endLine).endPos

  method beginPosWithComment*(self: ClassStructure; node: Node): void =
    var
      annotationLine = node.firstLine - 1
      firstComment =
    processedSource.commentsBeforeLine(annotationLine).reverseEach(proc (
        comment: void): void =
      if comment.location.line == annotationLine:
        var firstComment = comment
        annotationLine -= 1)
    startLinePosition(firstComment or node)

  method startLinePosition*(self: ClassStructure; node: Node): void =
    buffer.lineRange(node.loc.line).beginPos - 1

  method buffer*(self: ClassStructure): void =
    processedSource.buffer

  method expectedOrder*(self: ClassStructure): void =
    ##  Load expected order from `ExpectedOrder` config.
    ##  Define new terms in the expected order by adding new {categories}.
    copConfig["ExpectedOrder"]

  method categories*(self: ClassStructure): void =
    ##  Setting categories hash allow you to group methods in group to match
    ##  in the {expected_order}.
    copConfig["Categories"]

