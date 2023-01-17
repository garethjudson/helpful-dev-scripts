function diffDirs() {
  local directory1="${1}"
  local directory2="${2}"
  diff <(find "${directory1}" -type f | sed "s/${directory1}//" | sort) <(find "${directory2}" -type f | sed "s/${directory2}//" | sort)
}
