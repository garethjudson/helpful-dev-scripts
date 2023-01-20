function diffSync() { 
  local fromLocation="${1}"
  local toLocation="${2}"
  
  local toLocationType="local"
  local tempToFiles=""
  local tempFromFiles=""
  local localFromFiles="${fromLocation}"
  local localToFiles="${toLocation}"

  if [[ "$fromLocation" =~ s3://* ]]; then
    tempFromFiles="$(mktemp -d)"
    localFromFiles="${tempFromFiles}"
    aws s3 sync "${fromLocation}" "${localFromFiles}"
  fi

  if [[ "$toLocation" =~ s3://* ]]; then
    toLocationType="s3"
    tempToFiles="$(mktemp -d)"
    localToFiles="${tempToFiles}"
    aws s3 sync "${toLocation}" "${localToFiles}"
  fi    

  function _copy() {
    local from="$1"
    local to="$2"
    local locationType="$3"
    if [[ "$locationType" == "s3" ]]; then
      aws s3 cp "${from}" "${to}"
    else
      mkdir -p "$(dirname "${to}")" && cp "${from}" "${to}"
    fi
  }

  function _rm() {
    local location="$1"
    local locationType="$2"
    if [[ "$toLocation" == "s3" ]]; then
      aws s3 rm "${location}"
    else
      rm -rf "${location}"
    fi
  }

  function _removeDupeSlashes() {
    echo "$1" | sed -E 's/\/+/\//g' | sed 's/s3:\//s3:\/\//'
  }

  for i in $(sort <(find "${localFromFiles}" -type f | sed "s/${localFromFiles//\//\\/}//") <(find "${localToFiles}" -type f | sed "s/${localToFiles//\//\\/}//") | uniq); do
    localFromFile="$(_removeDupeSlashes "${localFromFiles}/${i}")"
    localToFile="$(_removeDupeSlashes "${localToFiles}/${i}")"
    actualToFile="$(_removeDupeSlashes "${toLocation}/${i}")"

    if [[ -e "${localFromFile}" ]] && [[ -e "${localToFile}" ]]; then
      if cmp --silent "${localFromFile}" "${localToFile}" &>/dev/null; then
        echo "file not changed ${actualToFile}"
      else
        echo "file changed ${actualToFile}"
        _copy "${localFromFile}" "${actualToFile}" "${toLocationType}"
      fi
    elif [[ -e "${localToFile}" ]]; then
      echo "removed file ${actualToFile}"
      _rm "${actualToFile}" "${toLocationType}"
    elif [[ -e "${localFromFile}" ]]; then
      echo "new file ${actualToFile}"
      _copy "${localFromFile}" "${actualToFile}" "${toLocationType}"
    fi
  done

  rm -rf "${tempToFiles}"
  rm -rf "${tempFromFiles}"
}

