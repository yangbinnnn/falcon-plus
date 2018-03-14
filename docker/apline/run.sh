#!/bin/bash

#!/bin/bash

set -e

FALCON_DIR=/root/monitor 
FALCON_MOUDLE="graph hbs judge transfer nodata aggregator gateway api alarm"
MYSQL_DATA_DIR=/root/mysql
MYSQL_USER=root
MYSQL_SCHEMA_DIR=${FALCON_DIR}/schema

# Launch

echo "start ${FALCON_MOUDLE}" \
&& /usr/bin/redis-server --daemonize yes \
&& /usr/bin/mysqld_safe --user=${MYSQL_USER} --datadir=${MYSQL_DATA_DIR} --nowatch \
&& cd ${MYSQL_SCHEMA_DIR} \
&& mysql -h 127.0.0.1 -u ${MYSQL_USER} < 1_uic-db-schema.sql \
&& mysql -h 127.0.0.1 -u ${MYSQL_USER} < 2_portal-db-schema.sql \
&& mysql -h 127.0.0.1 -u ${MYSQL_USER} < 3_dashboard-db-schema.sql \
&& mysql -h 127.0.0.1 -u ${MYSQL_USER} < 4_graph-db-schema.sql \
&& mysql -h 127.0.0.1 -u ${MYSQL_USER} < 5_alarms-db-schema.sql
&& cd ${FALCON_DIR}/dashboard \
&& ./control start \
&& cd ${FALCON_DIR} \
&& ./open-falcon start ${FALCON_MOUDLE}
errno=$?
if [ $errno -ne 0 ] ; then
  echo "Failed to start"
  exit 1
fi
./open-falcon check
./open-falcon monitor hbs
