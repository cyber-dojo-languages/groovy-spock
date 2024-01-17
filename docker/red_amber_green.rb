
lambda { |stdout,stderr,status|
  output = stdout + stderr
  pattern = Regexp.new('JUnit5 launcher: passed=(\d+), aborted=(\d+), failed=(\d+)')
  if match = pattern.match(output)
    return :red if match[3].to_i > 0
    return :green
  end
  return :amber
}
