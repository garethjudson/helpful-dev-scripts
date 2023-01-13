function jsonToCsv() {
  jq -r 'to_entries as $row | ( ( map(keys_unsorted ) | add | unique ) as $cols | ( [$cols] | flatten) , ( $row | .[] as $onerow | $onerow | ( [ ( $cols |  map ($onerow.value[.] as $v | if $v == null then "" else $v end )  ) ] | flatten ) ) ) | @csv '
}