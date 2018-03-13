#!/bin/bash

#!/bin/bash

set -e

FALCON_DIR=/root/monitor 
FALCON_MOUDLE="graph hbs judge transfer nodata aggregator gateway api alarm"
MYSQL_DATA_DIR=/root/mysql
MYSQL_USER=root

# Launch

echo "start ${FALCON_MOUDLE}"
/usr/bin/mysqld_safe --datadir=${MYSQL_DATA_DIR} --user=${MYSQL_USER} --nowatch \
&& /usr/bin/redis-server --daemonize yes \
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
