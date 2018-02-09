FROM  cyberdojofoundation/groovy
LABEL maintainer=jon@jaggersoft.com

ARG VERSION=2.4.12

RUN mkdir /groovy

COPY spock-core-1.0-groovy-2.4.jar /groovy/

RUN cp /groovy-${VERSION}/embeddable/groovy-all-${VERSION}.jar /groovy/
RUN cp /groovy-${VERSION}/lib/hamcrest-core-1.3.jar            /groovy/
RUN cp /groovy-${VERSION}/lib/junit-4.12.jar                   /groovy/

ENV CLASSPATH=/groovy/

COPY red_amber_green.rb /usr/local/bin