
cop :
  type
    DateTime* = ref object of Cop
    ##  This cop checks for consistent usage of the `DateTime` class over the
    ##  `Time` class. This cop is disabled by default since these classes,
    ##  although highly overlapping, have particularities that make them not
    ##  replaceable in certain situations when dealing with multiple timezones
    ##  and/or DST.
    ## 
    ##  @example
    ## 
    ##    # bad - uses `DateTime` for current time
    ##    DateTime.now
    ## 
    ##    # good - uses `Time` for current time
    ##    Time.now
    ## 
    ##    # bad - uses `DateTime` for modern date
    ##    DateTime.iso8601('2016-06-29')
    ## 
    ##    # good - uses `Time` for modern date
    ##    Time.iso8601('2016-06-29')
    ## 
    ##    # good - uses `DateTime` with start argument for historical date
    ##    DateTime.iso8601('1751-04-23', Date::ENGLAND)
    ## 
    ##  @example AllowCoercion: false (default)
    ## 
    ##    # bad - coerces to `DateTime`
    ##    something.to_datetime
    ## 
    ##    # good - coerces to `Time`
    ##    something.to_time
    ## 
    ##  @example AllowCoercion: true
    ## 
    ##    # good
    ##    something.to_datetime
    ## 
    ##    # good
    ##    something.to_time
  const
    CLASSMSG = "Prefer Time over DateTime."
  const
    COERCIONMSG = "Do not use #to_datetime."
  nodeMatcher isDateTime,
             "          (send (const {nil? (cbase)} :DateTime) ...)\n"
  nodeMatcher isHistoricDate,
             "          (send _ _ _ (const (const nil? :Date) _))\n"
  nodeMatcher isToDatetime, "          (send _ :to_datetime)\n"
  method onSend*(self: DateTime; node: Node): void =
    if isDateTime node or
      isToDatetime node and isDisallowCoercion:
    if isHistoricDate node:
      return
    var message = if isToDatetime node:
      COERCIONMSG
    addOffense(node, message = message)

  method isDisallowCoercion*(self: DateTime): void =
    copConfig["AllowCoercion"].!

