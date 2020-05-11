import groovy.util.GroovyTestSuite
import junit.textui.TestRunner
import junit.framework.TestResult
import static groovy.io.FileType.FILES

public class MyTestRunner {

    public static ArrayList getTestFilesPaths(String test_dir) {
        ArrayList testFilesPaths = new ArrayList();
        new File(test_dir).eachFileRecurse(FILES) {
            if (it.name.endsWith("*Spec.groovy")) {
                testFilesPaths.add(it.absolutePath)
            }
        }
        return testFilesPaths;
    }

    public static GroovyTestSuite getTestSuite(ArrayList testFilesPaths) {
        GroovyTestSuite suite = new GroovyTestSuite();
        testFilesPaths.each {
            suite.addTestSuite(suite.compile(it));
        }
        return suite;
    }

    public static void runTests(GroovyTestSuite suite) {
        TestResult result = new TestResult();
        suite.run(result);
        System.out.println(result.toString());
        if (!result.wasSuccessful()) {
            System.exit(42);
        }
    }
}

ArrayList testFilesPaths = MyTestRunner.getTestFilesPaths(".");
GroovyTestSuite suite = MyTestRunner.getTestSuite(testFilesPaths);
MyTestRunner.runTests(suite)
