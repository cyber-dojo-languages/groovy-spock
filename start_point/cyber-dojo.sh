
groovyc -cp /groovy/spock-core-2.0-M2-groovy-3.0.jar *.groovy
if [ $? -eq 0 ]; then
  # run test classes even if they are inner classes
  java -cp .:$(ls /groovy/*.jar | xargs | sed -e 's/ /:/g') \
      org.junit.runner.JUnitCore \
        `ls -1 *Spec*.class | sed 's/\(.*\)\..*/\1/'`
fi
