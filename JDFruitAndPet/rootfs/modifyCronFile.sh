#!/usr/bin/with-contenv bashio

CRONTAB_LIST_FILE=$(bashio::config 'CRONTAB_LIST_FILE')
ENABLE_JD_BEAN=$(bashio::config 'ENABLE_JD_BEAN')
CNF=/${CRONTAB_LIST_FILE}

ENVS="$(tr '\n' ' ' < /setEnv.sh)"

bashio::log.info "Loading Cron file: ${CRONTAB_LIST_FILE}"

# custom crond files
if [ -f "/${CRONTAB_LIST_FILE}" ]; then
    [ ! -d "/${CRONTAB_LIST_FILE}" ] && rm -rf /${CRONTAB_LIST_FILE}
fi
cp /scripts/docker/crontab_list.sh ${CNF}

# Redirect logs to docker stdout & stderr
sed -i 's/>> \/scripts\/logs\/.*.log 2>&1/> \/proc\/1\/fd\/1 2> \/proc\/1\/fd\/2/g' ${CNF}

# Remove crontab line
sed -i '/crontab/d' ${CNF}

# add this scripts to crontab
sed -i 's/\(.*git.*pull \).*/\1\&\& cd \/;.\/modifyCronFile.sh > \/proc\/1\/fd\/1 2> \/proc\/1\/fd\/2/g' ${CNF}

# enable JD Bean sign 
if [ ! ${ENABLE_JD_BEAN} ]; then
    sed -i '/jd_bean_sign.js/d' ${CNF}
fi

# add environment each cron task
sed -i "s|node|${ENVS} node|" ${CNF}

# cat ${CNF}
crontab ${CNF}
#crontab -l
