set -x

groovyc -cp ${SPOCK_JAR} *.groovy
if [ $? -eq 0 ]; then
  groovy -cp ${SPOCK_JAR} HikerSpec
fi
