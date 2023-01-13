function run() {
  if [[ -e ./micronaut-cli.yml ]]; then
    if [[ -e ./gradlew ]]; then
      ./gradlew run $@
    elif [[ -e ./build.gradle ]]; then
      gradle run $@
    elif [[ -e ./mvnw ]]; then
      ./mvnw mn:run $@
    elif [[ -e ./pom.xml ]]; then
      mvn mn:run $@
    fi
  # Assume spring boot project if gradle or maven project
  elif [[ -e ./gradlew ]]; then
    ./gradlew bootrun $@
  elif [[ -e ./build.gradle ]]; then
    gradle bootrun $@
  elif [[ -e ./mvnw ]]; then
    ./mvnw spring-boot:run $@
  elif [[ -e ./pom.xml ]]; then
    mvn spring-boot:run $@
  # Assume npm project if package.json
  elif [[ -e package.json ]]; then
    npm start $@
  elif [[ -e docker-compose.yml ]]; then
    docker-compose up $@
  fi
}
