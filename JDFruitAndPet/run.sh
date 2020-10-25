#!/usr/bin/with-contenv bashio

bashio::log.info "Initializing..."

cd /;./modifyCronFile.sh

crond -f

exit 0
