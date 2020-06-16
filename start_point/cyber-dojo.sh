
# There appears to be no way to pass all the Spec class names
# to groovy in one go. So I'm calling groovy once for each one.
# Groovy is so interminably ...sssssslllllllooooooowwwwwww....
# that you're likely to timeout if you use more than 2 Spec classes!
# Can you help?

SPECS=($(ls *Spec.groovy | cut -d '.' -f 1))
for SPEC in "${SPECS[@]}"
do
  groovy -cp /groovy/spock-core-2.0-M2-groovy-3.0.jar ${SPEC}
done
