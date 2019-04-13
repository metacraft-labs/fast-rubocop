
import
  types

import
  sequtils

import
  rangeHelp

cop :
  type
    FileName* = ref object of Cop
    ##  This cop makes sure that Ruby source files have snake_case
    ##  names. Ruby scripts (i.e. source files with a shebang in the
    ##  first line) are ignored.
    ## 
    ##  The cop also ignores `.gemspec` files, because Bundler
    ##  recommends using dashes to separate namespaces in nested gems
    ##  (i.e. `bundler-console` becomes `Bundler::Console`). As such, the
    ##  gemspec is supposed to be named `bundler-console.gemspec`.
    ## 
    ##  @example
    ##    # bad
    ##    lib/layoutManager.rb
    ## 
    ##    anything/usingCamelCase
    ## 
    ##    # good
    ##    lib/layout_manager.rb
    ## 
    ##    anything/using_snake_case.rake
  const
    MSGSNAKECASE = """The name of this source file (`%<basename>s`) should use snake_case."""
  const
    MSGNODEFINITION = """%<basename>s should define a class or module called `%<namespace>s`."""
  const
    MSGREGEX = "`%<basename>s` should match `%<regex>s`."
  const
    SNAKECASE
  method investigate*(self: FileName; processedSource: ProcessedSource): TrueClass =
    var filePath = processedSource.filePath
    if config.isFileToExclude(filePath) or
        config.isAllowedCamelCaseFile(filePath):
      return
    self.forBadFilename(filePath, proc (range: Range; msg: string): NilClass =
      addOffense(location = range, message = msg))

  iterator forBadFilename*(self: FileName; filePath: string): NilClass =
    var
      basename = File.basename(filePath)
      msg = if self.isFilenameGood(basename):
        if not self.isExpectMatchingDefinition():
          return
        if self.findClassOrModule(processedSource.ast, self.toNamespace(filePath)):
          return
        self.noDefinitionMessage(basename, filePath)
      else:
        if self.isIgnoreExecutableScripts() and
            processedSource.isStartWith("#!"):
          return
        self.otherMessage(basename)
    yield self.sourceRange(processedSource.buffer, 1, 0)

  method noDefinitionMessage*(self: FileName; basename: string; filePath: string): string =
    format(MSGNODEFINITION, basename = basename,
           namespace = self.toNamespace(filePath).join("::"))

  method otherMessage*(self: FileName; basename: string): string =
    if self.regex():
      format(MSGREGEX, basename = basename, regex = self.regex())
    else:
      format(MSGSNAKECASE, basename = basename)
  
  method isIgnoreExecutableScripts*(self: FileName): TrueClass =
    copConfig["IgnoreExecutableScripts"]

  method isExpectMatchingDefinition*(self: FileName): TrueClass =
    copConfig["ExpectMatchingDefinition"]

  method regex*(self: FileName): NilClass =
    copConfig["Regex"]

  method allowedAcronyms*(self: FileName): Array =
    copConfig["AllowedAcronyms"] or @[]

  method isFilenameGood*(self: FileName; basename: string): Integer =
    basename = basename.sub("")
    basename = basename.sub("")
    basename = basename.sub("+", "_")
    basename.=~:
      self.regex() or SNAKECASE

  method findClassOrModule*(self: FileName; node: Node; namespace: Array): TrueClass =
    ##  rubocop:disable Metrics/CyclomaticComplexity
    if not node:
      return
    var name = namespace.pop
    onNode(@["class", "module", "casgn"], node, proc (child: Node): FalseClass =
      if not 
        const = child.definedModule:
        continue
      if name != constName and self.isMatchAcronym(name, constName).!:
        continue
      if not (namespace.isEmpty or
          self.matchNamespace(child, constNamespace, namespace)):
        continue
      return node)
  
  method matchNamespace*(self: FileName; node: Node; namespace: NilClass;
                        expected: Array): void =
    var matchPartial = self.partialMatcher!(expected)
    matchPartial.call(namespace)
    node.eachAncestor("class", "module", "sclass", "casgn", proc (ancestor: Node): void =
      if ancestor.isSclassType():
        return false
      matchPartial.call(ancestor.definedModule))
    self.isMatch(expected)

  method partialMatcher!*(self: FileName; expected: Array): Proc =
    lambda(proc (namespace: Node): FalseClass =
      while namespace:
        if namespace.isCbaseType:
          return isMatch(expected)
        if name == expected.last or self.isMatchAcronym(expected.last, name):
          expected.pop
      false)

  method isMatch*(self: FileName; expected: Array): TrueClass =
    expected.isEmpty or expected == @["Object"]

  method isMatchAcronym*(self: FileName; expected: Symbol; name: Symbol): TrueClass =
    expected = expected.toS
    name = name.toS
    self.allowedAcronyms().anyIt:
      expected.gsub(it.capitalize, it) == name

  method toNamespace*(self: FileName; path: string): Array =
    var
      components = Pathname(path).eachFilename.toA
      start = @["lib", "spec", "test", "src"]
      startIndex =
    components.reverse.eachWithIndex(proc (c: string; i: Integer): NilClass =
      if start.isInclude(c):
        var startIndex = components.size - i
        break )
    if startIndex.isNil:
      @[self.toModuleName(components.last)]
    else:
      components[].mapIt:
        self.toModuleName(it)
  
  method toModuleName*(self: FileName; basename: string): Symbol =
    var words = basename.sub("").split("_")
    words.mapIt:
      it.apitalize.join.toSym

