
import
  types
import
  nre

cop BinaryOperatorParameterName:
  ##  This cop makes sure that certain binary operator methods have their
  ##  sole  parameter named `other`.
  ## 
  ##  @example
  ## 
  ##    # bad
  ##    def +(amount); end
  ## 
  ##    # good
  ##    def +(other); end
  const
    MSG = """When defining the `%<opr>s` operator, name its argument `other`."""
    OPLIKEMETHODS = @["eql?", "equal?"]
    BLACKLISTED = @["+@", "-@", "[]", "[]=", "<<", "===", "`"]
  
  nodeMatcher isOpMethodCandidate, "(def [#op_method? $_] (args $(arg [!:other !:_other])) _)"
  
  # if temp.kind == RbDef and self.isOpMethod(temp[0][0]) and true and temp[1].kind == RbArgs and temp[1][0].kind == RbArg and $temp[1][0] != "other" and arg0 = temp[0][0]; true and arg1 = temp[1][0]; ; 

  method onDef*(self; node) =
    isOpMethodCandidate node, (name, arg):
      addOffense(arg, message = format(MSG, opr = name))

  method isOpMethod*(self; name: Symbol) =
    if name in BLACKLISTED:
      return false
    not name.match(re"\A\w") and name in OPLIKEMETHODS

