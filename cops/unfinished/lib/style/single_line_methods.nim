
import
  types

import
  alignment

cop SingleLineMethods:
  ##  This cop checks for single-line method definitions that contain a body.
  ##  It will accept single-line methods with no body.
  ## 
  ##  @example
  ##    # bad
  ##    def some_method; body end
  ##    def link_to(url); {:name => url}; end
  ##    def @table.columns; super; end
  ## 
  ##    # good
  ##    def no_op; end
  ##    def self.resource_class=(klass); end
  ##    def @table.columns; end
  ## 
  const
    MSG = "Avoid single-line method definitions."
  
  method onDef*(self; node) =
    if not node.isSingleLine:
      return
    if self.isAllowEmpty() and not node.body:
      return
    addOffense(node)

  method isAllowEmpty*(self): bool =
    copConfig.AllowIfMethodIsEmpty

