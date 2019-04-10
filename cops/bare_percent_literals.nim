
import
  configurableEnforcedStyle

cop :
  type
    BarePercentLiterals* = ref object of Cop
    ##  This cop checks if usage of %() or %Q() matches configuration.
    ## 
    ##  @example EnforcedStyle: bare_percent (default)
    ##    # bad
    ##    %Q(He said: "#{greeting}")
    ##    %q{She said: 'Hi'}
    ## 
    ##    # good
    ##    %(He said: "#{greeting}")
    ##    %{She said: 'Hi'}
    ## 
    ##  @example EnforcedStyle: percent_q
    ##    # bad
    ##    %|He said: "#{greeting}"|
    ##    %/She said: 'Hi'/
    ## 
    ##    # good
    ##    %Q|He said: "#{greeting}"|
    ##    %q/She said: 'Hi'/
    ## 
  const
    MSG = "Use `%%%<good>s` instead of `%%%<bad>s`."
  method onDstr*(self: BarePercentLiterals; node: Node): void =
    check(node)

  method onStr*(self: BarePercentLiterals; node: Node): void =
    check(node)

  method autocorrect*(self: BarePercentLiterals; node: Node): void =
    var
      src = node.loc.begin.source
      replacement = if src.isStartWith("%Q"):
        "%"
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.begin, src.sub(replacement)))

  method check*(self: BarePercentLiterals; node: Node): void =
    ##  guards : we can move them before call and inline them anyway before the on_
    if node.isHeredoc:
      return
    if node.loc.isRespondTo("begin"):
    if node.loc.begin:
    var source = node.loc.begin.source
    if isRequiresPercentQ(source):
      addOffenseForWrongStyle(node, "Q", "")
    elif isRequiresBarePercent(source):
      addOffenseForWrongStyle(node, "", "Q")
  
  method isRequiresPercentQ*(self: BarePercentLiterals; source: string): void =
    style == "percent_q" and source.=~()

  method isRequiresBarePercent*(self: BarePercentLiterals; source: string): void =
    style == "bare_percent" and source.=~()

  method addOffenseForWrongStyle*(self: BarePercentLiterals; node: Node;
                                 good: string; bad: string): void =
    addOffense(node, location = "begin",
               message = format(MSG, good = good, bad = bad))

