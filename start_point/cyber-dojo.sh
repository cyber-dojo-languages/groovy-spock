set -x

groovyc *.groovy
if [ $? -eq 0 ]; then
  groovy HikerSpec
fi
