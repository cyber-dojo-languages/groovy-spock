#!/bin/bash
# Invoked as [bash record_aot_cache.sh], and that ignores the shebang line, so
# the shell options have to be set here to have any effect. Set on the shebang
# alone they are silently absent, and a spec that failed to pass leaves an image
# the build then reports as a success.
set -Eeu -o pipefail

# Records the AOT cache the JVM running the specs replays on every [test] press.
#
# A kata runs in a container thrown away afterwards, so every press pays a full
# JVM startup, and that JVM loads groovy's compiler, spock's runtime and the
# test launcher from the jars before a single spec runs. That is not a component
# of the wait, it is most of it. An AOT cache holds the classes that JVM loads,
# in the form the JVM wants them, and reading one back costs a fraction of
# loading them again.
#
# A learner's own classes never enter the cache, which is what makes it keep
# working as the learner edits. What it holds is groovy's classes and spock's,
# and recording it from the throwaway kata below is what keeps any kata's out.

readonly WORK_DIR=/tmp/record_aot_cache
readonly CACHE_DIR=/aot
readonly SPOCK_CACHE="${CACHE_DIR}/spock.aot"

# Named by pattern rather than by version, because a version written in here
# would go stale the first time a new spock was published.
readonly SPOCK_JAR="$(ls /groovy/spock-core-*.jar)"

mkdir -p "${WORK_DIR}" "${CACHE_DIR}"
cp /tmp/throwaway_kata/*.groovy "${WORK_DIR}"
cd "${WORK_DIR}"

# Recorded from the same command line cyber-dojo.sh runs, so that the classes
# held are the ones a kata actually loads.
JAVA_OPTS="-XX:AOTCacheOutput=${SPOCK_CACHE}" \
  groovy -cp "${SPOCK_JAR}" /run_spec_files.groovy GreeterSpec.groovy

# The sandbox user reads it at run time and owns nothing here.
chmod 0644 "${SPOCK_CACHE}"

cd /
rm -rf "${WORK_DIR}"

ls --format=long "${SPOCK_CACHE}"
