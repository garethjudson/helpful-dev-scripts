function restore_rds_from_s3() {
  function output_restore_rds_from_s3() {
    cat <<END
    restore_rds_from_s3 will restore an RDS database (postgres or mysql) from a dump stored in s3 via the 'dump_rds_to_s3' command.
    It takes the aws secrets manager secret id, and uses that to determine password, host, username etc.

    Note: 
      look at restore db and understand how it works. Using this incorrectly could result in data loss. Passwords are passed around and this could present a security risk.
      If you don't understand the risk of using this function, probably don't. Ask yourself what you're doing with your life :D 
      HIGHLY recommend testing this on a test DB that you can afford to overwrite before you do anything silly with it.
      TODO: implement validation of inputs.

    This really expected to be run within aws (possibly on a node that has db cluster access). 
    This is typically because you would be advised against exposing your database to the world in this way.

    example usage: 
      restore_rds_from_s3 -s 'secret_id' -f 's3://my-database-dump-bucket/s3-backup-file.gz' -n "mydatabase_name"

    required options:
      -f --s3_backup_file    a gziped backup file in the format appropriate for you database (e.g. backed up using the complimenatry db_dump function)
      -s --secret_id         a secrets manager secret that contains the database connection details. This should be in the default aws rds secret format, which will return a json result as follows:
                             {
                               "dbClusterIdentifier": " ",
                               "password":" ",
                               "dbname":" ",
                               "engine":" ",
                               "port": 3306,
                               "host":" ",
                               "username":" "
                             }
                             This should be relatively self explanitary. 
    optional:
      -h --host              in case you want to run locally (e.g. port forward/ssm tunnel) you can override the host
      -p --port              in case you want to run locally (e.g. port forward/ssm tunnel) you can override the port
      -u --user              to override the user
      -P --password          to override the password
      -n --db_name           the name of the db in the database being restored. Allows you to restore to a different db name on the same cluster/instance
END
  }

  local s3_backup_file secret_id db_name db_host db_user db_password db_port

  if [[ -n "${1:-}" ]]; then
    while [[ "${1:-}" =~ ^- && ! "${1:-}" == "--" ]]; do
      case "${1}" in
      -f | --s3_backup_file)
        shift
        s3_backup_file="${1}"
        ;;
      -s | --secret_id)
        shift
        secret_id="${1}"
        ;;
      -n | --db_name)
        shift
        db_name="${1}"
        ;;
      -h | --host)
        shift
        db_host="${1}"
        ;;
      -p | --port)
        shift
        db_port="${1}"
        ;;
      -u | --user)
        shift
        db_user="${1}"
        ;;
      -P | --password)
        shift
        db_password="${1}"
        ;;
      -*)
        output_restore_rds_from_s3
        return 0
        ;;
      esac
      shift
    done
    if [[ "${1:-}" == '--' ]]; then shift; fi
  fi

  # Declare vars seperate assignment, see https://www.shellcheck.net/wiki/SC2155
  local db_type secret_json

  secret_json="$(aws secretsmanager get-secret-value --secret-id "${secret_id}" | jq .SecretString -r)"
  db_type="$(echo "${secret_json}" | jq -r .engine)"
  
  db_host="${db_host:-$(echo "${secret_json}" | jq -r .host)}"
  db_port="${db_port:-$(echo "${secret_json}" | jq -r .port)}"
  db_name="${db_name:-$(echo "${secret_json}" | jq -r .dbname)}"

  db_user="${db_user:-$(echo "${secret_json}" | jq -r .username)}"
  db_password="${db_password:-$(echo "${secret_json}" | jq -r .password)}"
 
  aws s3 cp "${s3_backup_file}" - | restore_db -t "${db_type}" -h "${db_host}" -p "${db_port}" -u "${db_user}" -P "${db_password}"
}