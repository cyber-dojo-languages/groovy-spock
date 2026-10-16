#!/bin/bash -Eeu

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing.
add_test_framework()
{
  local -r name="${1}"
  local -r version="${2}"
  local -r entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep -q '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep -q -F "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

mkdir /groovy

# The jars are taken from the distribution by glob rather than by name. The
# base resolves the newest stable groovy when it is built, so a name here
# would be a second copy of a version this image does not choose.
cp "${GROOVY_HOME}"/lib/groovy-[0-9]*.jar   /groovy/
cp "${GROOVY_HOME}"/lib/hamcrest-core-*.jar /groovy/
cp "${GROOVY_HOME}"/lib/junit-4*.jar        /groovy/

# Spock publishes one build per groovy line, named for it, as in
# 2.4-groovy-5.0. So the newest spock is looked for among the builds for the
# groovy line this image holds. Milestones and release candidates are passed
# over, because a kata should not run on a pre-release.
readonly GROOVY_JAR="$(basename "$(ls /groovy/groovy-[0-9]*.jar | head -1)")"
readonly GROOVY_MAJOR="$(echo "${GROOVY_JAR}" | sed 's/^groovy-\([0-9]*\)\..*$/\1/')"
readonly REPO=https://repo1.maven.org/maven2/org/spockframework/spock-core
readonly SPOCK_VERSION="$(wget -q -O - "${REPO}/maven-metadata.xml" \
  | sed -n 's|.*<version>\(.*\)</version>.*|\1|p' \
  | grep "^[0-9.]*-groovy-${GROOVY_MAJOR}\.0$" \
  | sort -V | tail -1)"

if [ -z "${SPOCK_VERSION}" ]; then
  echo "Found no spock-core release for groovy ${GROOVY_MAJOR}" >&2
  exit 1
fi

readonly SPOCK_JAR="spock-core-${SPOCK_VERSION}.jar"
wget -q -O "/groovy/${SPOCK_JAR}" "${REPO}/${SPOCK_VERSION}/${SPOCK_JAR}"

add_test_framework Spock "${SPOCK_VERSION}"
cat /versions.json
