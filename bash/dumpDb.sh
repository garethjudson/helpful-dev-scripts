function dump_db() {
  function output_dump_db_usage() {
    cat <<END
    dump_db is a function that wraps database dump commands and outputs the dump to stdout. 
    The command uses network compression, but manually gzip compresses the output when writing the stream. 
    You can then pipe that output to disk, the cloud or whereever you feel like.

    Note: 
      look at dump_db and understand how it works. Using this incorrectly could leak passwords and data. This could present a security risk.
      If you don't understand the risk of using this function, probably don't. Ask yourself what you're doing with your life :D 
      HIGHLY recommend testing this on a test DB that does not matter before you do anything silly with it.
      TODO: implement validation of inputs.

    example usage:
      dump_db -t "mysql" -h "myhost" -u "myuser" -p "fakepassword" > mysql_dump_file.gz
    or
      dump_db -t "mysql" -h "myhost" -u "myuser" -p "fakepassword" | special_command_to_put_the_output_somewhere 

    required options:
      -t --db_type       the database type (currently supported 'mysql' and 'postgres')
      -h --db_host       the database host
      -n --db_name       the name of the database to dump
      -u --db_user       username on the database server that is allowed to do a dump
      -P --db_password   password of the user (there is inherant security risk providing a database password through a command line. Understand the risk and use this tool with caution!!)
    
    other options:
      -p --db_port       the database port (mysql default = 3306, postgres default = 5432)
END
  }

  local db_type db_host db_port db_name db_user db_password 
  if [[ -n "${1:-}" ]]; then
    while [[ "${1:-}" =~ ^- && ! "${1:-}" == "--" ]]; do
      case "${1}" in
      -t | --db_type)
        shift
        db_type="${1}"
        ;;
      -h | --db_host)
        shift
        db_host="${1}"
        ;;
      -p | --db_port)
        shift
        db_port="${1}"
        ;;
      -n | --db_name)
        shift
        db_name="${1}"
        ;;  
      -u | --db_user)
        shift
        db_user="${1}"
        ;;
      -P | --db_password)
        shift
        db_password="${1}"
        ;;
      -*)
        output_dump_db_usage
        return 0
        ;;
      esac
      shift
    done
    if [[ "${1:-}" == '--' ]]; then shift; fi
  fi

  if [[ "${db_type}" == "mysql" ]]; then
    db_port="${db_port:-3306}"
    mysqldump -f --host="${db_host}" --port="${db_port}" --user="${db_user}" --password="${db_password}" -C --single-transaction "${db_name}" | gzip -9
  elif [[ "${db_type}" == "postgres" ]]; then
    db_port="${db_port:-5432}"
    PGPASSWORD="${db_password}" pg_dump --format=custom --no-password -Z 9 --host="${db_host}" --port="${db_port}" --username="${db_user}" "${db_name}" | gzip -9
  fi
}

