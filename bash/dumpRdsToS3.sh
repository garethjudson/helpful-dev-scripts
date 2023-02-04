function dump_rds_to_s3() {
  function output_dump_rds_to_s3() {
    cat <<END
    dump_rds_to_s3 will dump an RDS database (postgres or mysql) to s3 via the 'dump_db' command.
    It takes the aws secrets manager secret id, and uses that to determine password, host, username etc.
    The file name put in the s3 bucket will have the form: <db_name>-<db_type>-<datestamp>.sql.gz 
      e.g.: myDatabaseName-mysql-2022-10-21T22-56-32+0000.sql.gz

    Note: 
      look at dump_db and understand how it works. Using this incorrectly could leak passwords and data. This could present a security risk.
      If you don't understand the risk of using this function, probably don't. Ask yourself what you're doing with your life :D 
      HIGHLY recommend testing this on a test DB that does not matter before you do anything silly with it.
      TODO: implement validation of inputs.

    example usage: 
      dump_rds_to_s3 -s 'secret_id' -l 's3://my-database-dump-bucket' -n "mydatabase_name"

    required options:
      -f --s3_bucket_location     an s3 location (bucket plus path, not a file/object). e.g.: "s3://my-bucket/my-suffix-path/"
      -s --secret_id              a secrets manager secret that contains the database connection details. This should be in the default aws rds secret format, which will return a json result as follows:
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
      -n --db_name                the name of the db in the database being dumped. Allows you to a different db on the same cluster/instance
      -r --use_read_replica       in the case of a database cluster, aws uses a seperate host that will connect to a read replica. 
                                  provide this argumentto to connect to the read replica for a backup, so that you do not put load on your write instance. 
                                  it derives the read replica url via a simple replacement e.g. expressed by the sed replacement: sed -E "s/.cluster-([a-zA-Z0-9\.-]+.rds.amazonaws.com)/.cluster-ro-\1/"
END
  }
  local db_name secret_id s3_bucket_location 
  local use_read_replica="false"
  
  if [[ -n "${1:-}" ]]; then
    while [[ "${1:-}" =~ ^- && ! "${1:-}" == "--" ]]; do
      case "${1}" in
      -s | --secret_id)
        shift
        secret_id="${1}"
        ;;
      -l | --s3_bucket_location)
        shift
        s3_bucket_location="${1}"
        ;;
      -n | --db_name)
        shift
        db_name="${1}"
        ;;  
      -r | --use_read_replica)
        use_read_replica="true"
        ;;
      -*)
        output_dump_rds_to_s3
        return 0
        ;;
      esac
      shift
    done
    if [[ "${1:-}" == '--' ]]; then shift; fi
  fi

  # Declare vars seperate assignment, see https://www.shellcheck.net/wiki/SC2155
  local db_type db_host db_user db_password db_port s3_location secret_json

  secret_json="$(aws secretsmanager get-secret-value --secret-id "${secret_id}" | jq .SecretString -r)"
  db_type="$(echo "${secret_json}" | jq -r .engine)"
  db_host="$(echo "${secret_json}" | jq -r .host)"
  if [[ "${use_read_replica}" == "true" ]]; then  
    db_host="$(echo "${db_host}" | sed -E 's/.cluster-([a-zA-Z0-9\.-]+.rds.amazonaws.com)/.cluster-ro-\1/')"
  fi

  db_user="$(echo "${secret_json}" | jq -r .username)"
  db_password="$(echo "${secret_json}" | jq -r .password)"
  db_port="$(echo "${secret_json}" | jq -r .port)"
  s3_location="${s3_bucket_location}/${db_name}-${db_type}-$(date +%Y-%m-%dT%H-%M-%S%z).sql.gz"

  dump_db -t "${db_type}" -h "${db_host}" -n "${db_name}" -u "${db_user}" -P "${db_password}" | aws s3 cp - "${s3_location}"
}
