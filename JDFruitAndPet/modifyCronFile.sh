#!/usr/bin/with-contenv bashio

echo ${CRONTAB_LIST_FILE}
echo ${ENABLE_JD_BEAN}

bashio::log.info "Loading Cron file: ${CRONTAB_LIST_FILE}"

# Redirect logs to docker stdout & stderr
sed -i 's/>> \/scripts\/logs\/.*.log 2>&1/> \/proc\/1\/fd\/1 2> \/proc\/1\/fd\/2/g' /scripts/docker/${CRONTAB_LIST_FILE}

# Remove crontab line
sed -i '/crontab/d' /scripts/docker/${CRONTAB_LIST_FILE}

# add this scripts to crontab
sed -i 's/\(.*git.*\).>>.*/\1 && cd /;./modifyCronFile.sh > \/proc\/1\/fd\/1 2> \/proc\/1\/fd\/2/g' /scripts/docker/${CRONTAB_LIST_FILE}

# enable JD Bean sign 
if [ ! ${ENABLE_JD_BEAN} ]; then
    sed -i '/jd_bean_sign.js/d' /scripts/docker/${CRONTAB_LIST_FILE}
fi

cat /scripts/docker/${CRONTAB_LIST_FILE}
# crontab /scripts/docker/${CRONTAB_LIST_FILE}
