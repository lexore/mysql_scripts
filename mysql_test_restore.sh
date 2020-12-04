#!/bin/bash -e

. ./mysql_settings.conf
problem="problem $0"
log "start script $0"

[ -n "$1" ] && MYSQL_DAY=$1

echo "
[client]
host=${MYSQL_HOST}
user=${MYSQL_USER}
password=${MYSQL_PASS}
" > ${MYSQL_FILE}

log "check connection to mysql"
echo '' \
  | mysql --defaults-extra-file=${MYSQL_FILE} > /dev/null \
  || problem "can't connect to mysql"

log "check connection to s3"
aws s3api head-bucket --bucket ${AWS_S3_BUCKET} \
  || problem "can't connect to bucket"

log "create test database"
echo "create database $MYSQL_RESTORE_DB" \
  | mysql --defaults-extra-file=${MYSQL_FILE} > /dev/null \
  || problem "can't create test db"

log "restore scheme"
aws s3 cp s3://${AWS_S3_BUCKET}/${MYSQL_DB}/scheme_${MYSQL_DAY}.sql.gz - \
  | gzip -d \
  | mysql --defaults-extra-file=${MYSQL_FILE} ${MYSQL_RESTORE_DB} \
  || problem "can't restore schema"

log "restore data"
aws s3 cp s3://${AWS_S3_BUCKET}/${MYSQL_DB}/data_${MYSQL_DAY}.sql.gz - \
  | gzip -d \
  | mysql --defaults-extra-file=${MYSQL_FILE} ${MYSQL_RESTORE_DB} \
  || problem "can't restore data"

log "drop test database"
echo "drop database $MYSQL_RESTORE_DB" \
  | mysql --defaults-extra-file=${MYSQL_FILE} > /dev/null \
  || problem "can't drop test db"

log "cleaning"
rm -f ${MYSQL_FILE}
