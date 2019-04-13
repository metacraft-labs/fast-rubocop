
import
  configurableEnforcedStyle

import
  rangeHelp

cop :
  type
    MethodDefParentheses* = ref object of Cop
    ##  This cop checks for parentheses around the arguments in method
    ##  definitions. Both instance and class/singleton methods are checked.
    ## 
    ##  @example EnforcedStyle: require_parentheses (default)
    ##    # The `require_parentheses` style requires method definitions
    ##    # to always use parentheses
    ## 
    ##    # bad
    ##    def bar num1, num2
    ##      num1 + num2
    ##    end
    ## 
    ##    def foo descriptive_var_name,
    ##            another_descriptive_var_name,
    ##            last_descriptive_var_name
    ##      do_something
    ##    end
    ## 
    ##    # good
    ##    def bar(num1, num2)
    ##      num1 + num2
    ##    end
    ## 
    ##    def foo(descriptive_var_name,
    ##            another_descriptive_var_name,
    ##            last_descriptive_var_name)
    ##      do_something
    ##    end
    ## 
    ##  @example EnforcedStyle: require_no_parentheses
    ##    # The `require_no_parentheses` style requires method definitions
    ##    # to never use parentheses
    ## 
    ##    # bad
    ##    def bar(num1, num2)
    ##      num1 + num2
    ##    end
    ## 
    ##    def foo(descriptive_var_name,
    ##            another_descriptive_var_name,
    ##            last_descriptive_var_name)
    ##      do_something
    ##    end
    ## 
    ##    # good
    ##    def bar num1, num2
    ##      num1 + num2
    ##    end
    ## 
    ##    def foo descriptive_var_name,
    ##            another_descriptive_var_name,
    ##            last_descriptive_var_name
    ##      do_something
    ##    end
    ## 
    ##  @example EnforcedStyle: require_no_parentheses_except_multiline
    ##    # The `require_no_parentheses_except_multiline` style prefers no
    ##    # parentheses when method definition arguments fit on single line,
    ##    # but prefers parentheses when arguments span multiple lines.
    ## 
    ##    # bad
    ##    def bar(num1, num2)
    ##      num1 + num2
    ##    end
    ## 
    ##    def foo descriptive_var_name,
    ##            another_descriptive_var_name,
    ##            last_descriptive_var_name
    ##      do_something
    ##    end
    ## 
    ##    # good
    ##    def bar num1, num2
    ##      num1 + num2
    ##    end
    ## 
    ##    def foo(descriptive_var_name,
    ##            another_descriptive_var_name,
    ##            last_descriptive_var_name)
    ##      do_something
    ##    end
  const
    MSGPRESENT = "Use def without parentheses."
  const
    MSGMISSING = """Use def with parentheses when there are parameters."""
  method onDef*(self: MethodDefParentheses; node: Node): void =
    var args = node.arguments
    if isRequireParentheses(args):
      if isArgumentsWithoutParentheses(node):
        missingParentheses(node)
    elif isParentheses(args):
      unwantedParentheses(args)
  
  method autocorrect*(self: MethodDefParentheses; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if node.isArgsType():
        corrector.replace(node.loc.begin, " ")
        corrector.remove(node.loc.end)
      else:
        var
          argsExpr = node.arguments.sourceRange
          argsWithSpace = rangeWithSurroundingSpace(range = argsExpr, side = "left")
          justSpace = rangeBetween(argsWithSpace.beginPos, argsExpr.beginPos)
        corrector.replace(justSpace, "(")
        corrector.insertAfter(argsExpr, ")"))

  method isRequireParentheses*(self: MethodDefParentheses; args: Node): void =
    style == "require_parentheses" or
      style == "require_no_parentheses_except_multiline" and args.isMultiline

  method isArgumentsWithoutParentheses*(self: MethodDefParentheses; node: Node): void =
    node.isArguments and isParentheses(node.arguments).!

  method missingParentheses*(self: MethodDefParentheses; node: Node): void =
    var location = node.arguments.sourceRange
    addOffense(node, location = location, message = MSGMISSING, proc (): void =
      unexpectedStyleDetected("require_no_parentheses"))

  method unwantedParentheses*(self: MethodDefParentheses; args: Node): void =
    addOffense(args, message = MSGPRESENT, proc (): void =
      unexpectedStyleDetected("require_parentheses"))

