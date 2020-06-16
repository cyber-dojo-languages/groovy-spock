
lambda { |stdout,stderr,status|
  output = stdout + stderr
  green_pattern = Regexp.new('^OK \((\d+) test')
  if match = green_pattern.match(output)
    return :green if match[1] != '0'
    return :red # treat zero passes as a fail
  end
 amber_patterns = [
    'groovyc: command not found',
    'groovy\.lang',
    'MultipleCompilationErrorsException'
  ]
  return :amber if amber_patterns.any? { |pattern| Regexp.new(pattern).match(output) }
  return :red
}
