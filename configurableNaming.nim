import types, nre


proc isValidName*[T](cop: T, node: Node, name: string): bool =
  if config[cop.location].EnforcedStyle == "snake_case":
    nre.find(name, re"^@{0,2}[\da-z_]+[!?=]?$").isSome
  else:
    false

proc checkName*[T](cop: T, node: Node, name: Node, nameRange: Position) =
  if cop.isValidName(node, name.name):
    discard
  else:
    addOffense(node, location=nameRange, message=cop.message(config[cop.location].EnforcedStyle))

