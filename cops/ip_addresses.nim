
import
  strutils, sequtils

import
  stringHelp

cop :
  type
    IpAddresses* = ref object of Cop
    ##  This cop checks for hardcoded IP addresses, which can make code
    ##  brittle. IP addresses are likely to need to be changed when code
    ##  is deployed to a different server or environment, which may break
    ##  a deployment if forgotten. Prefer setting IP addresses in ENV or
    ##  other configuration.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    ip_address = '127.59.241.29'
    ## 
    ##    # good
    ##    ip_address = ENV['DEPLOYMENT_IP_ADDRESS']
  const
    IPV6MAXSIZE = 45
  const
    MSG = "Do not hardcode IP addresses."
  method isOffense*(self: IpAddresses; node: Node): void =
    var contents = node.source[]
    if contents.isEmpty:
      return false
    if whitelist.isInclude(contents.toLowerAscii()):
      return false
    if isCouldBeIp(contents):
    else:
      return false
    contents.=~(Regex) or contents.=~(Regex)

  method oppositeStyleDetected*(self: IpAddresses): void =
    ##  Dummy implementation of method in ConfigurableEnforcedStyle that is
    ##  called from StringHelp.
  
  method correctStyleDetected*(self: IpAddresses): void =
    ##  Dummy implementation of method in ConfigurableEnforcedStyle that is
    ##  called from StringHelp.
  
  method whitelist*(self: IpAddresses): void =
    var whitelist = copConfig["Whitelist"]
    Array(whitelist).mapIt:
      it.owncase

  method isCouldBeIp*(self: IpAddresses; str: string): void =
    if isTooLong(str):
      return false
    isStartsWithHexOrColon(str)

  method isTooLong*(self: IpAddresses; str: string): void =
    str.size > IPV6MAXSIZE

  method isStartsWithHexOrColon*(self: IpAddresses; str: string): void =
    var firstChar = str[0].ord()
    .isCover(firstChar) or
    .isCover(firstChar) or
    .isCover(firstChar)

