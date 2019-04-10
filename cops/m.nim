type
  Cop* = ref object of RootObj

  CodeLength = concept a
    a is Cop
    a.c is int

  CopB* = ref object of Cop
    
  CopC* = ref object of Cop
    c*: int

  Node* = object

method addOffense*(self: Cop, node: Node) =
  echo node

proc checkCodeLength(self: CodeLength, node: Node) =
  #self.addOffense(node)
  echo self.c


# checkCodeLength(CopB(), Node())
checkCodeLength(CopC(), Node())