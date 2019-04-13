
import
  redundant_exception, test_tools

suite "RedundantException":
  var cop = RedundantException()
  sharedExamples("common behavior", proc (keyword: string): void =
    test """reports an offense for a (lvar :keyword) with RuntimeError""":
      var src = """(lvar :keyword) RuntimeError, msg"""
      inspectSource(src)
      expect(cop().highlights).to(eq(@[src]))
      expect(cop().messages).to(eq(@["Redundant `RuntimeError` argument can be removed."]))
    test """reports an offense for a (lvar :keyword) with RuntimeError.new""":
      var src = """(lvar :keyword) RuntimeError.new(msg)"""
      inspectSource(src)
      expect(cop().highlights).to(eq(@[src]))
      expect(cop().messages).to(eq(@["""Redundant `RuntimeError.new` call can be replaced with just the message."""]))
    test """accepts a (lvar :keyword) with RuntimeError if it does not have 2 args""":
      expectNoOffenses("""(lvar :keyword) RuntimeError, msg, caller""")
    test """auto-corrects a (lvar :keyword) RuntimeError by removing RuntimeError""":
      var
        src = """(lvar :keyword) RuntimeError, msg"""
        resultSrc = """(lvar :keyword) msg"""
        newSrc = autocorrectSource(src)
      expect(newSrc).to(eq(resultSrc))
    test """auto-corrects a (lvar :keyword) RuntimeError and leaves parentheses""":
      var
        src = """(lvar :keyword)(RuntimeError, msg)"""
        resultSrc = """(lvar :keyword)(msg)"""
        newSrc = autocorrectSource(src)
      expect(newSrc).to(eq(resultSrc))
    test """(str "auto-corrects a ")removing RuntimeError.new""":
      var
        src = """(lvar :keyword) RuntimeError.new(msg)"""
        resultSrc = """(lvar :keyword) msg"""
        newSrc = autocorrectSource(src)
      expect(newSrc).to(eq(resultSrc))
    test """(str "auto-corrects a ")removing RuntimeError.new""":
      var
        src = """(lvar :keyword) RuntimeError.new msg"""
        resultSrc = """(lvar :keyword) msg"""
        newSrc = autocorrectSource(src)
      expect(newSrc).to(eq(resultSrc))
    test """(str "does not modify ")args""":
      var
        src = """(lvar :keyword) runtimeError, msg, caller"""
        newSrc = autocorrectSource(src)
      expect(newSrc).to(eq(src))
    test "does not modify rescue w/ non redundant error":
      var
        src = """(lvar :keyword) OtherError, msg"""
        newSrc = autocorrectSource(src)
      expect(newSrc).to(eq(src)))
  includeExamples("common behavior", "raise")
  includeExamples("common behavior", "fail")
