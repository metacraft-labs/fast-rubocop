
import
  tables

import
  rangeHelp

import
  surroundingSpace

cop :
  type
    UnneededCopEnableDirective* = ref object of Cop
  const
    MSG = "Unnecessary enabling of %<cop>s."
  method investigate*(self: UnneededCopEnableDirective;
                     processedSource: ProcessedSource): void =
    if processedSource.isBlank:
      return
    var offenses = processedSource.commentConfig.extraEnabledComments
    for comment, name in offenses:
      addOffense(@[comment, name], location = rangeOfOffense(comment, name),
                 message = format(MSG, cop = allOrName(name)))

  method autocorrect*(self: UnneededCopEnableDirective; commentAndName: Array): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(rangeWithComma()))

  method rangeOfOffense*(self: UnneededCopEnableDirective; comment: Comment;
                        name: string): void =
    var startPos = commentStart(comment) & copNameIndention(comment, name)
    rangeBetween(startPos, startPos & name.size)

  method commentStart*(self: UnneededCopEnableDirective; comment: Comment): void =
    comment.loc.expression.beginPos

  method copNameIndention*(self: UnneededCopEnableDirective; comment: Comment;
                          name: string): void =
    comment.text.index(name)

  method rangeWithComma*(self: UnneededCopEnableDirective; comment: Comment;
                        name: string): void =
    var
      source = comment.loc.expression.source
      beginPos = copNameIndention(comment, name)
      endPos = beginPos & name.size
    beginPos = reposition(source, beginPos, -1)
    endPos = reposition(source, endPos, 1)
    var commaPos = if source[beginPos - 1] == ",":
      "before"
    elif source[endPos] == ",":
      "after"
    rangeToRemove(beginPos, endPos, commaPos, comment)

  method rangeToRemove*(self: UnneededCopEnableDirective; beginPos: Integer;
                       endPos: Integer; commaPos: Symbol; comment: Comment): void =
    var
      start = commentStart(comment)
      buffer = processedSource.buffer
      rangeClass = Range
    case commaPos
    of "before":
      rangeClass.new(buffer, (start & beginPos) - 1, start & endPos)
    of "after":
      rangeClass.new(buffer, start & beginPos, start & endPos & 1)
    else:
      rangeClass.new(buffer, start, comment.loc.expression.endPos)
  
  method allOrName*(self: UnneededCopEnableDirective; name: string): void =
    if name == "all":
      "all cops"
  
