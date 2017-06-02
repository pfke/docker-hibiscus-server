#!/bin/bash

set -e

# See for instructions:
# http://www.willuhn.de/products/hibiscus-server/install.php

dbconfig=/hibiscus-server/cfg/de.willuhn.jameica.hbci.rmi.HBCIDBService.properties

case "$DB_DRIVER" in

# Be sure to escape a ':' in DB_ADDR
mysql)
    DB_ADDR=${DB_HOSTNAME}:${DB_PORT-3306}
    echo "Configuring MySQL db connection to $DB_ADDR"
    cat > $dbconfig <<EOF
database.driver=de.willuhn.jameica.hbci.server.DBSupportMySqlImpl
database.driver.mysql.jdbcurl=jdbc\:mysql\://${DB_ADDR/:/\\:}/${DB_NAME}?useUnicode\=Yes&characterEncoding\=ISO8859_1
database.driver.mysql.username=${DB_USERNAME}
database.driver.mysql.password=${DB_PASSWORD}
EOF
    ;;

postgres)
    DB_ADDR=${DB_HOSTNAME}:${DB_PORT-5432}
    echo "Configuring PostgreSQL db connection to $DB_ADDR"
    cat > $dbconfig <<EOF
database.driver=de.willuhn.jameica.hbci.server.DBSupportPostgreSQLImpl
database.driver.postgresql.jdbcurl=jdbc\:postgresql\://${DB_ADDR/:/\\:}/${DB_NAME}
database.driver.postgresql.username=${DB_USERNAME}
database.driver.postgresql.password=${DB_PASSWORD}
EOF
    ;;

*)
    echo "Configuring local embedded database"
    # We'll delete the mysql config for now to use the embedded db
    rm $dbconfig
    ;;

esac


# Write HTTP settings
ssl_val=false
if [ "$USE_SSL" != "" ]; then
    ssl_val=true
fi
cat > /hibiscus-server/cfg/de.willuhn.jameica.webadmin.Plugin.properties <<EOF
listener.http.address=0.0.0.0
listener.http.port=${PORT-8080}
listener.http.auth=true
listener.http.ssl=${ssl_val}
EOF


function initdb() {
    #echo "Initializing database, please wait a second ..."
    #sleep 1
    echo "Initializing ..."

    case "$DB_DRIVER" in
        postgres)
            cmd="psql -h $DB_HOSTNAME -p ${DB_PORT-5432} -U $DB_USERNAME  < /hibiscus-server/plugins/hibiscus/sql/postgresql-create.sql"
            echo $cmd
            eval PGPASSWORD=$DB_PASSWORD $cmd
            ;;

        mysql)
            cmd="mysql -u $DB_USERNAME --password=${DB_PASSWORD} -P ${DB_PORT-3306} -h $DB_HOSTNAME $DB_NAME < /hibiscus-server/plugins/hibiscus/sql/mysql-create.sql"
            echo $cmd
            eval $cmd 
                        ;;
        *)
            echo "Don't know how to initialize database for driver $DB_DRIVER"
            ;;
    esac
    echo "Initialization complete!"
    
}

if [ "$*" == "initdb" ]; then
        initdb
        exit
fi


initdb

# FILE=initialized.flag
# if [ ! -f $FILE ]; then
#    initdb
#    touch $FILE
#    exit
# else
#    echo "Already initalized!"
# fi


# Write configuration file based on desired database driver
${@-/hibiscus-server/jameicaserver.sh -p $PASSWORD -f /srv/hibiscus}