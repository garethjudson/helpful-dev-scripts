function test() {
  if [[ -e ./gradlew ]]; then
    ./gradlew test $@
  elif [[ -e ./build.gradle ]]; then
    gradle test $@
  elif [[ -e ./mvnw ]]; then
    ./mvnw test $@
  elif [[ -e ./pom.xml ]]; then
    mvn test $@
  elif [[ -e package.json ]]; then
    npm test $@
  fi
}
