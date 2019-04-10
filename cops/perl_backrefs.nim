
cop :
  type
    PerlBackrefs* = ref object of Cop
    ##  This cop looks for uses of Perl-style regexp match
    ##  backreferences like $1, $2, etc.
    ## 
    ##  @example
    ##    # bad
    ##    puts $1
    ## 
    ##    # good
    ##    puts Regexp.last_match(1)
  const
    MSG = "Avoid the use of Perl-style backrefs."
  method onNthRef*(self: PerlBackrefs; node: Node): void =
    addOffense(node)

  method autocorrect*(self: PerlBackrefs; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var
        backref = node[0]
        parentType = if node.parent:
          node.parent.type
      if @["dstr", "xstr", "regexp"].isInclude(parentType):
        corrector.replace(node.sourceRange,
                          """{Regexp.last_match((lvar :backref))}""")
      else:
        corrector.replace(node.sourceRange,
                          """Regexp.last_match((lvar :backref))""")
    )

