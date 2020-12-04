#!/bin/bash -e

. ./mysql_settings.conf
problem="problem $0"
log "start script $0"

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

log "backup scheme"
mysqldump ${MYSQL_OPTIONS} --no-data \
  | gzip \
  | aws s3 cp - s3://${AWS_S3_BUCKET}/${MYSQL_DB}/scheme_${MYSQL_DAY}.sql.gz \
  || problem "can't upload scheme"

log "backup data"
mysqldump ${MYSQL_OPTIONS} --no-create-info \
  | gzip \
  | aws s3 cp - s3://${AWS_S3_BUCKET}/${MYSQL_DB}/data_${MYSQL_DAY}.sql.gz \
  || problem "can't upload data"

log "cleaning"
rm -f ${MYSQL_FILE}
