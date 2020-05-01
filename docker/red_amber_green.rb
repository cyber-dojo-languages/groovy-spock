
lambda { |stdout,stderr,status|
  output = stdout + stderr
  junit5_pattern = Regexp.new('JUnit5 launcher: passed=(\d+), failed=(\d+), skipped=0')
  if match = junit5_pattern.match(output)
    return :red if match[2] != '0'
    return :red if match[1] == '0'
    return :green
  end
  return :amber
}
