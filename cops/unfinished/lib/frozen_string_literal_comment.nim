
import
  configurableEnforcedStyle

import
  frozenStringLiteral

import
  rangeHelp

cop :
  type
    FrozenStringLiteralComment* = ref object of Cop
    ##  This cop is designed to help upgrade to after Ruby 3.0. It will add the
    ##  comment `# frozen_string_literal: true` to the top of files to
    ##  enable frozen string literals. Frozen string literals may be default
    ##  after Ruby 3.0. The comment will be added below a shebang and encoding
    ##  comment. The frozen string literal comment is only valid in Ruby 2.3+.
    ## 
    ##  @example EnforcedStyle: when_needed (default)
    ##    # The `when_needed` style will add the frozen string literal comment
    ##    # to files only when the `TargetRubyVersion` is set to 2.3+.
    ##    # bad
    ##    module Foo
    ##      # ...
    ##    end
    ## 
    ##    # good
    ##    # frozen_string_literal: true
    ## 
    ##    module Foo
    ##      # ...
    ##    end
    ## 
    ##  @example EnforcedStyle: always
    ##    # The `always` style will always add the frozen string literal comment
    ##    # to a file, regardless of the Ruby version or if `freeze` or `<<` are
    ##    # called on a string literal.
    ##    # bad
    ##    module Bar
    ##      # ...
    ##    end
    ## 
    ##    # good
    ##    # frozen_string_literal: true
    ## 
    ##    module Bar
    ##      # ...
    ##    end
    ## 
    ##  @example EnforcedStyle: never
    ##    # The `never` will enforce that the frozen string literal comment does
    ##    # not exist in a file.
    ##    # bad
    ##    # frozen_string_literal: true
    ## 
    ##    module Baz
    ##      # ...
    ##    end
    ## 
    ##    # good
    ##    module Baz
    ##      # ...
    ##    end
  const
    MSG = "Missing magic comment `# frozen_string_literal: true`."
  const
    MSGUNNECESSARY = "Unnecessary frozen string literal comment."
  const
    SHEBANG = "#!"
  method investigate*(self: FrozenStringLiteralComment;
                     processedSource: ProcessedSource): void =
    if style == "when_needed" and targetRubyVersion < 0.0:
      return
    if processedSource.tokens.isEmpty:
      return
    if isFrozenStringLiteralCommentExists:
      checkForNoComment(processedSource)
    else:
      checkForComment(processedSource)
  
  method autocorrect*(self: FrozenStringLiteralComment; node: NilClass): void =
    lambda(proc (corrector: Corrector): void =
      if style == "never":
        removeComment(corrector, node)
      else:
        insertComment(corrector)
    )

  method checkForNoComment*(self: FrozenStringLiteralComment;
                           processedSource: ProcessedSource): void =
    if style == "never":
      unnecessaryCommentOffense(processedSource)
  
  method checkForComment*(self: FrozenStringLiteralComment;
                         processedSource: ProcessedSource): void =
    if style == "never":
    else:
      offense(processedSource)
  
  method lastSpecialComment*(self: FrozenStringLiteralComment;
                            processedSource: ProcessedSource): void =
    var tokenNumber = 0
    if processedSource.tokens[tokenNumber].text.isStartWith(SHEBANG):
      var token = processedSource.tokens[tokenNumber]
      tokenNumber += 1
    var nextToken = processedSource.tokens[tokenNumber]
    if nextToken and nextToken.text.=~(ENCODINGPATTERN):
      token = nextToken
    token

  method frozenStringLiteralComment*(self: FrozenStringLiteralComment;
                                    processedSource: ProcessedSource): void =
    processedSource.findToken(proc (token: Token): void =
      token.text.isStartWith(FROZENSTRINGLITERAL))

  method offense*(self: FrozenStringLiteralComment;
                 processedSource: ProcessedSource): void =
    var
      lastSpecialComment = lastSpecialComment(processedSource)
      range = sourceRange(processedSource.buffer, 0, 0)
    addOffense(lastSpecialComment, location = range)

  method unnecessaryCommentOffense*(self: FrozenStringLiteralComment;
                                   processedSource: ProcessedSource): void =
    var frozenStringLiteralComment = frozenStringLiteralComment(processedSource)
    addOffense(frozenStringLiteralComment,
               location = frozenStringLiteralComment.pos, message = MSGUNNECESSARY)

  method removeComment*(self: FrozenStringLiteralComment; corrector: Corrector;
                       node: Token): void =
    corrector.remove(rangeWithSurroundingSpace(range = node.pos, side = "right"))

  method insertComment*(self: FrozenStringLiteralComment; corrector: Corrector): void =
    var lastSpecialComment = lastSpecialComment(processedSource)
    if lastSpecialComment.isNil():
      corrector.insertBefore(correctionRange, precedingComment)
    else:
      corrector.insertAfter(correctionRange, proceedingComment)
  
  method precedingComment*(self: FrozenStringLiteralComment): void =
    if processedSource.tokens[0].isSpaceBefore:
      """(const nil :FROZEN_STRING_LITERAL_ENABLED)
"""
  
  method proceedingComment*(self: FrozenStringLiteralComment): void =
    var
      lastSpecialComment = lastSpecialComment(processedSource)
      followingLine = processedSource.followingLine(lastSpecialComment)
    if followingLine and followingLine.isEmpty:
      """
(const nil :FROZEN_STRING_LITERAL_ENABLED)"""
  
  method correctionRange*(self: FrozenStringLiteralComment): void =
    var lastSpecialComment = lastSpecialComment(processedSource)
    if lastSpecialComment.isNil():
      rangeWithSurroundingSpace(range = processedSource.tokens[0], side = "left")
    else:
      lastSpecialComment.pos
  
