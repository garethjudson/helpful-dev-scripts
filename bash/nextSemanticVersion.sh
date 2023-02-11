function next_semantic_version() {
  local major minor patch currentVersion increment
  currentVersion="${1}"
  increment="${2}"

  major=$(echo "${currentVersion}" | cut -d'.' -f1)
  minor=$(echo "${currentVersion}" | cut -d'.' -f2)
  patch=$(echo "${currentVersion}" | cut -d'.' -f3)

  if [[ "${increment}" =~ "major" ]]; then
    major=$((major + 1))
    minor=0
    patch=0
  elif [[ "${increment}" =~ "minor" ]]; then
    minor=$((minor + 1))
    patch=0
  else
    patch=$((patch + 1))
  fi

  echo "${major:-0}.${minor:-0}.${patch:-0}"
}