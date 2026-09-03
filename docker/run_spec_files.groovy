// Compiles the kata's files, runs the specs among them, and exits 0 when they
// all pass and 1 when they do not.
//
// The files are named by the glob in cyber-dojo.sh. Nothing here knows the
// names the start-point ships; a learner writes source and spec files named for
// the exercise they are doing, and those are what arrive here.
//
// One JVM runs every spec. Handing groovy a spec class runs that one class, so
// a kata with several spec files would start a JVM for each, and starting one
// costs more than running the specs in it. One JVM also prints one summary,
// counting every spec, rather than one summary per file.

import org.codehaus.groovy.control.MultipleCompilationErrorsException
import org.junit.platform.launcher.core.LauncherDiscoveryRequestBuilder
import org.junit.platform.launcher.core.LauncherFactory
import org.junit.platform.launcher.listeners.SummaryGeneratingListener
import spock.lang.Specification

import static org.junit.platform.engine.discovery.DiscoverySelectors.selectClass

static Throwable compilerErrorIn(Throwable failure) {
  for (Throwable cause = failure; cause != null; cause = cause.cause) {
    if (cause instanceof MultipleCompilationErrorsException) {
      return cause
    }
  }
  null
}

// The kata's own directory is on the loader's classpath, so a file compiles
// here and the classes it refers to compile with it.
final loader = new GroovyClassLoader(this.class.classLoader)
loader.addClasspath('.')

def compiled
try {
  compiled = args.collect { loader.parseClass(new File(it)) }
} catch (Throwable failure) {
  // A kata that will not compile is what the compiler says it is, and its
  // message names the file, the line and the column. Compiling one file's
  // dependencies happens through a lookup that wraps that message in an
  // internal error naming this file, which says nothing about the kata, so the
  // compiler's own exception is dug out and printed on its own.
  System.err.println(compilerErrorIn(failure) ?: failure)
  System.exit(1)
}

// Every file the kata holds is compiled above, so one you are midway through
// writing shows its errors rather than being passed over in silence. The specs
// among them are the classes extending Specification, which is what spock
// itself looks for; the name of the file a spec sits in makes no difference.
final specs = compiled.findAll { Specification.isAssignableFrom(it) }

final request = LauncherDiscoveryRequestBuilder.request()
  .selectors(specs.collect { selectClass(it) })
  .build()

final listener = new SummaryGeneratingListener()
LauncherFactory.create().execute(request, listener)
final summary = listener.summary

// The wording of this line is what the start-point's red_amber_green.rb reads
// to tell a failing spec from a kata that would not compile, so it is spelled
// out here rather than left to a library to phrase.
println "JUnit5 launcher: passed=${summary.testsSucceededCount}" +
        ", aborted=${summary.testsAbortedCount}" +
        ", failed=${summary.testsFailedCount}" +
        ", skipped=${summary.testsSkippedCount}" +
        ", time=${summary.timeFinished - summary.timeStarted}ms"

final writer = new PrintWriter(System.out)
summary.printFailuresTo(writer)
writer.flush()

System.exit(summary.testsFailedCount > 0 ? 1 : 0)
