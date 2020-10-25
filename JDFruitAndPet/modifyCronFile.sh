#!/usr/bin/with-contenv bashio

CRONTAB_LIST_FILE=$(bashio::config 'CRONTAB_LIST_FILE')
ENABLE_JD_BEAN=$(bashio::config 'ENABLE_JD_BEAN')
CNF=/scripts/docker/${CRONTAB_LIST_FILE}

ENVS="JD_COOKIE=$(bashio::config 'JD_COOKIE') \
DD_BOT_TOKEN=$(bashio::config 'DD_BOT_TOKEN') \
DD_BOT_SECRET=$(bashio::config 'DD_BOT_SECRET') \
PLANT_BEAN_SHARECODES=$(bashio::config 'PLANT_BEAN_SHARECODES') \
FRUITSHARECODES=$(bashio::config 'FRUITSHARECODES') \
PETSHARECODES=$(bashio::config 'PETSHARECODES') \
JOY_FEED_COUNT=$(bashio::config 'JOY_FEED_COUNT') \
SUPERMARKET_SHARECODES=$(bashio::config 'SUPERMARKET_SHARECODES') \
MARKET_COIN_TO_BEANS=$(bashio::config 'MARKET_COIN_TO_BEANS') \
JD_DEBUG=$(bashio::config 'JD_DEBUG')"

bashio::log.info "Loading Cron file: ${CRONTAB_LIST_FILE}"

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
