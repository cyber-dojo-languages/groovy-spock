// The spec half of the workload the AOT cache is recorded from. It passes,
// because a JVM writes a cache when it exits of its own accord and a green run
// is the simplest way to be sure of that.
import spock.lang.Specification

class GreeterSpec extends Specification {

  def "answers its greeting"() {
    expect:
    new Greeter().greeting() == 'hello'
  }
}
