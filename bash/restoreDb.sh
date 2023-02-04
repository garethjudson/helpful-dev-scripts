function restore_db() {
  function output_restore_db_usage() {
    cat <<END
    restore_db is a function that wraps database restore commands and restores a gziped dump to the appropriate database.
    It reads the dump from stdin, so you can supply it from the command line from whereever you choose. 
    Supports mysql and postgres via the mysql cli and pg_restore tool.
    
     Note: 
      Understand how this works. Using this incorrectly could result in data loss. Passwords are passed around and this could present a security risk.
      If you don't understand the risk of using this function, probably don't. Ask yourself what you're doing with your life :D 
      HIGHLY recommend testing this on a test DB that you can afford to overwrite before you do anything silly with it.
      TODO: implement validation of inputs.

    example usage: 
      cat mysql_dump_file.gz | restore_db -t "mysql" -h "myhost" -u "myuser" -p "fakepassword"
    or 
      restore_db -t "mysql" -h "myhost" -u "myuser" -p "fakepassword" < mysql_dump_file.gz

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
    gzip -d | mysql --host="${db_host}" --port="${db_port}" --user="${db_user}" --password="${db_password}" "${db_name}"
  elif [[ "${db_type}" == "postgres" ]]; then
    db_port="${db_port:-5432}"
    gzip -d | PGPASSWORD="${db_password}" pg_restore --clean --no-password --host="${db_host}" --port="${db_port}" --username="${db_user}" --dbname="${db_name}"
  fi
}