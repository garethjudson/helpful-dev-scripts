function build() {
  if [[ -e ./gradlew ]]; then
    ./gradlew clean build $@
  elif [[ -e ./build.gradle ]]; then
    gradle clean build $@
  elif [[ -e ./mvnw ]]; then
    ./mvnw clean install $@
  elif [[ -e ./pom.xml ]]; then
    mvn clean install $@
  fi
}
