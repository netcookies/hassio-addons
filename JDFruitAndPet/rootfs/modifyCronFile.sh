#!/usr/bin/with-contenv bashio

CRONTAB_LIST_FILE=$(bashio::config 'CRONTAB_LIST_FILE')
ENABLE_JD_BEAN=$(bashio::config 'ENABLE_JD_BEAN')
CNF=/${CRONTAB_LIST_FILE}
SCKEY=$(bashio::config 'notify.PUSH_KEY')
BARK_PUSH=$(bashio::config 'notify.BARK_PUSH')
BARK_SOUND=$(bashio::config 'notify.BARK_SOUND')
TG_BOT_TOKEN=$(bashio::config 'notify.TG_BOT_TOKEN')
TG_USER_ID=$(bashio::config 'notify.TG_USER_ID')
DD_BOT_TOKEN=$(bashio::config 'notify.DD_BOT_TOKEN')
DD_BOT_SECRET=$(bashio::config 'notify.DD_BOT_SECRET')
IGOT_PUSH_KEY=$(bashio::config 'notify.IGOT_PUSH_KEY')

# Load custom environment variables
#ENVS="$(tr '\n' ' ' < /setEnv.sh)"
ENVS=''
for var in $(bashio::config 'env_vars|keys'); do
    name=$(bashio::config "env_vars[${var}].name")
    value=$(bashio::config "env_vars[${var}].value")
    if [ ! -z "${value}" ]; then
        bashio::log.info "Setting ${name} to ${value}..."
        ENVS="${name}=""'""${value}""' "${ENVS}
    fi
done

# git pull
bashio::log.info "Updating repo..."
git -C /scripts/ fetch --all
git -C /scripts/ reset --hard origin/master
git -C /scripts/ checkout master


# custom crond files
bashio::log.info "Loading Cron file: ${CRONTAB_LIST_FILE}..."
if [ -f "/${CRONTAB_LIST_FILE}" ]; then
    [ ! -d "/${CRONTAB_LIST_FILE}" ] && rm -rf /${CRONTAB_LIST_FILE}
fi
cp /scripts/docker/crontab_list.sh ${CNF}

# Force timezone to CST-8
sed -i "1s|^|CRON_TZ\=\'CST\-8\'\n|" ${CNF}

# Redirect logs to docker stdout & stderr
sed -i 's/>> \/scripts\/logs\/.*.log 2>&1/> \/proc\/1\/fd\/1 2> \/proc\/1\/fd\/2/g' ${CNF}

# Remove crontab line
sed -i '/crontab/d' ${CNF}

# add this scripts to crontab
sed -i 's/\(.*\)git.*pull.*/30 \*\/1 \* \* \* cd \/;.\/modifyCronFile.sh > \/proc\/1\/fd\/1 2> \/proc\/1\/fd\/2/g' ${CNF}

# enable JD Bean sign 
if [ ! ${ENABLE_JD_BEAN} ]; then
    sed -i '/jd_bean_sign.js/d' ${CNF}
fi

# add environment each cron task
sed -i "s|node|cd /scripts; ${ENVS} node|" ${CNF}

# cat ${CNF}
crontab ${CNF}
#crontab -l

bashio::log.info "Updating SendNotify.js"
NOTIFYFN=/scripts/sendNotify.js

function setNotify() {
    FN=$1
    NOTIFYKEY=$2
    NOTIFYVAL=$3
    if [ ! -z "${NOTIFYVAL}" ] && [ "null" != "${NOTIFYVAL}" ]; then
        sed -i "s|^let ${NOTIFYKEY}.*|let ${NOTIFYKEY} = \'${NOTIFYVAL}\';|" ${FN}
    fi
}

setNotify "$NOTIFYFN" "SCKEY" "${SCKEY}"
setNotify "$NOTIFYFN" "BARK_PUSH" "${BARK_PUSH}"
setNotify "$NOTIFYFN" "BARK_SOUND" "${BARK_SOUND}"
setNotify "$NOTIFYFN" "TG_BOT_TOKEN" "${TG_BOT_TOKEN}"
setNotify "$NOTIFYFN" "TG_USER_ID" "${TG_USER_ID}"
setNotify "$NOTIFYFN" "DD_BOT_TOKEN" "${DD_BOT_TOKEN}"
setNotify "$NOTIFYFN" "DD_BOT_SECRET" "${DD_BOT_SECRET}"
setNotify "$NOTIFYFN" "IGOT_PUSH_KEY" "${IGOT_PUSH_KEY}"

# Load ShareCodes
bashio::log.info "Updating *ShareCodes*.js"
FFN=/scripts/jdFruitShareCodes.js
PFN=/scripts/jdPetShareCodes.js
PBFN=/scripts/jdPlantBeanShareCodes.js
SMFN=/scripts/jdSuperMarketShareCodes.js
JXSFN=/scripts/jdJxStoryShareCodes.js
DDFFN=/scripts/jdFactoryShareCodes.js
DFFN=/scripts/jdDreamFactoryShareCodes.js

function setShareCodes () {
    FN=$1 # file name
    SHARETYPE=$2 # ex: Fruit
    BACKUPVAR=$3 # ex: 535a7bfc56e1468e8c09f2657ea04e3b
    CODES=""
    LENGTH=$(bashio::config "sharecodes.${SHARETYPE,,}|length")
    [ ${LENGTH} -lt 2 ] && LENGTH=2
    let LENGTH-=1
    bashio::log.info "Setting ${SHARETYPE} Share Codes..."
    sed -i "/^let.*ShareCodes = \[/,/^\]$/d" ${FN}
    sed -i "1s|^|\]\n|" ${FN}
    for var in $(seq 0 ${LENGTH}); do
        value=$(bashio::config "sharecodes.${SHARETYPE,,}[${var}]")
        [ "${value}" == "null" ] && value="${BACKUPVAR}"
        CODES=${CODES}"  '"${value}"',\n"
    done
    sed -i "1s|^|${CODES}|" ${FN}
    sed -i "1s|^|let ${SHARETYPE}ShareCodes = \[\n|" ${FN}
}

function setShareCodesV2 () {
    FN=$1 # file name
    SHARETYPE=$2 # ex: Fruit
    BACKUPVAR=$3 # ex: 535a7bfc56e1468e8c09f2657ea04e3b
    CODES=""
    LENGTH=$(bashio::config "sharecodes.${SHARETYPE,,}|length")
    [ ${LENGTH} -lt 2 ] && LENGTH=2
    let LENGTH-=1
    bashio::log.info "Setting ${SHARETYPE} Share Codes..."
    sed -i "/^let shareCodes = \[/,/^\]$/d" ${FN}
    sed -i "1s|^|\]\n|" ${FN}
    for var in $(seq 0 ${LENGTH}); do
        value=$(bashio::config "sharecodes.${SHARETYPE,,}[${var}]")
        [ "${value}" == "null" ] && value="${BACKUPVAR}"
        CODES=${CODES}"  '"${value}"',\n"
    done
    sed -i "1s|^|${CODES}|" ${FN}
    sed -i "1s|^|let shareCodes = \[\n|" ${FN}
}

# FruitShareCodes
setShareCodes "${FFN}" "Fruit" "535a7bfc56e1468e8c09f2657ea04e3b"
# PetShareCodes
setShareCodes "${PFN}" "Pet" "MTE1NDQ5MzYwMDAwMDAwMzgyNDA5NTU="
# PlantBeanShareCodes
setShareCodes "${PBFN}" "PlantBean" "7i2k65oy4qkh53m4dkp6ybeg6y"
# SuperMarketShareCodes
setShareCodes "${SMFN}" "SuperMarket" "eU9YaejjYv4g8T2EwnsVhQ"
# JxStoryShareCodes
setShareCodesV2 "${JXSFN}" "JxStory" "WBeLvJj4gUCdXo2PmMSHXQ=="
# FactoryShareCodes
setShareCodesV2 "${DDFFN}" "Factory" "P04z54XCjVWnYaS5mtdTDOngicTwC4"
# DreamFactoryShareCodes
setShareCodesV2 "${DFFN}" "DreamFactory" "WBeLvJj4gUCdXo2PmMSHXQ=="
