import os, strformat, strutils, macros, tables
import "nimterop"/treesitter/[api, ruby], mercy, node_pattern

nodeMatcher isCaseEquality, "(send _ :=== _)"
var node = parse("0 === 0")

echo node


isCaseEquality(node[0]):
  echo "case"

