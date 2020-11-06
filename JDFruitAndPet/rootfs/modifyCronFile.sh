#!/usr/bin/with-contenv bashio

CRONTAB_LIST_FILE=$(bashio::config 'CRONTAB_LIST_FILE')
ENABLE_JD_BEAN=$(bashio::config 'ENABLE_JD_BEAN')
CNF=/${CRONTAB_LIST_FILE}
SC_KEY=$(bashio::config 'notify.PUSH_KEY')
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
    bashio::log.info "Setting ${name} to ${value}..."
    if [ ! -z "${value}" ]; then
        ENVS="${name}=""'""${value}""' "${ENVS}
    fi
done

# Load ShareCodes
# FruitShareCodes
bashio::log.info "Setting Fruit Share Codes..."
FRUITSHARECODES1=''
for var in $(bashio::config 'sharecodes.primary.fruit|keys'); do
    name=$(bashio::config "sharecodes.primary.fruit[${var}].name")
    value=$(bashio::config "sharecodes.primary.fruit[${var}].value")
    if [ ! -z "${value}" ]; then
        if [ -z ${FRUITSHARECODES1} ]; then
            FRUITSHARECODES1=${value}
        else
            FRUITSHARECODES1=${FRUITSHARECODES1}"@"${value}
        fi
    fi
done
FRUITSHARECODES2=''
for var in $(bashio::config 'sharecodes.secondary.fruit|keys'); do
    name=$(bashio::config "sharecodes.secondary.fruit[${var}].name")
    value=$(bashio::config "sharecodes.secondary.fruit[${var}].value")
    if [ ! -z "${value}" ]; then
        if [ -z ${FRUITSHARECODES2} ]; then
            FRUITSHARECODES2=${value}
        else
            FRUITSHARECODES2=${FRUITSHARECODES2}"@"${value}
        fi
    fi
done

# PetShareCodes
bashio::log.info "Setting Pet Share Codes..."
PETSHARECODES1=''
for var in $(bashio::config 'sharecodes.primary.pet|keys'); do
    name=$(bashio::config "sharecodes.primary.pet[${var}].name")
    value=$(bashio::config "sharecodes.primary.pet[${var}].value")
    if [ ! -z "${value}" ]; then
        if [ -z ${PETSHARECODES1} ]; then
            PETSHARECODES1=${value}
        else
            PETSHARECODES1=${PETSHARECODES1}"@"${value}
        fi
    fi
done
PETSHARECODES2=''
for var in $(bashio::config 'sharecodes.secondary.pet|keys'); do
    name=$(bashio::config "sharecodes.secondary.pet[${var}].name")
    value=$(bashio::config "sharecodes.secondary.pet[${var}].value")
    if [ ! -z "${value}" ]; then
        if [ -z ${PETSHARECODES2} ]; then
            PETSHARECODES2=${value}
        else
            PETSHARECODES2=${PETSHARECODES2}"@"${value}
        fi
    fi
done

# PlantBeanShareCodes
bashio::log.info "Setting PlantBean Share Codes..."
PlANTBEANSHARECODES1=''
for var in $(bashio::config 'sharecodes.primary.plantbean|keys'); do
    name=$(bashio::config "sharecodes.primary.plantbean[${var}].name")
    value=$(bashio::config "sharecodes.primary.plantbean[${var}].value")
    if [ ! -z "${value}" ]; then
        if [ -z ${PLANTBEANSHARECODES1} ]; then
            PLANTBEANSHARECODES1=${value}
        else
            PLANTBEANSHARECODES1=${PLANTBEANSHARECODES1}"@"${value}
        fi
    fi
done
PlANTBEANSHARECODES2=''
for var in $(bashio::config 'sharecodes.secondary.plantbean|keys'); do
    name=$(bashio::config "sharecodes.secondary.plantbean[${var}].name")
    value=$(bashio::config "sharecodes.secondary.plantbean[${var}].value")
    if [ ! -z "${value}" ]; then
        if [ -z ${PLANTBEANSHARECODES2} ]; then
            PLANTBEANSHARECODES2=${value}
        else
            PLANTBEANSHARECODES2=${PLANTBEANSHARECODES2}"@"${value}
        fi
    fi
done

# SuperMarketShareCodes
bashio::log.info "Setting SuperMarket Share Codes..."
SUPERMARKETSHARECODES1=''
for var in $(bashio::config 'sharecodes.primary.supermarket|keys'); do
    name=$(bashio::config "sharecodes.primary.supermarket[${var}].name")
    value=$(bashio::config "sharecodes.primary.supermarket[${var}].value")
    if [ ! -z "${value}" ]; then
        if [ -z ${SUPERMARKETSHARECODES1} ]; then
            SUPERMARKETSHARECODES1=${value}
        else
            SUPERMARKETSHARECODES1=${SUPERMARKETSHARECODES1}"@"${value}
        fi
    fi
done
SUPERMARKETSHARECODES2=''
for var in $(bashio::config 'sharecodes.secondary.supermarket|keys'); do
    name=$(bashio::config "sharecodes.secondary.supermarket[${var}].name")
    value=$(bashio::config "sharecodes.secondary.supermarket[${var}].value")
    if [ ! -z "${value}" ]; then
        if [ -z ${SUPERMARKETSHARECODES2} ]; then
            SUPERMARKETSHARECODES2=${value}
        else
            SUPERMARKETSHARECODES2=${SUPERMARKETSHARECODES2}"@"${value}
        fi
    fi
done

# git pull
bashio::log.info "Updating repo..."
git fetch --all
git reset --hard origin/master


# custom crond files
bashio::log.info "Loading Cron file: ${CRONTAB_LIST_FILE}..."
if [ -f "/${CRONTAB_LIST_FILE}" ]; then
    [ ! -d "/${CRONTAB_LIST_FILE}" ] && rm -rf /${CRONTAB_LIST_FILE}
fi
cp /scripts/docker/crontab_list.sh ${CNF}

# Redirect logs to docker stdout & stderr
sed -i 's/>> \/scripts\/logs\/.*.log 2>&1/> \/proc\/1\/fd\/1 2> \/proc\/1\/fd\/2/g' ${CNF}

# Remove crontab line
sed -i '/crontab/d' ${CNF}

# add this scripts to crontab
sed -i 's/\(.*git.*pull \).*/cd \/;.\/modifyCronFile.sh > \/proc\/1\/fd\/1 2> \/proc\/1\/fd\/2/g' ${CNF}

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
if [ ! -z "${SCKEY}" ]; then
    sed -i "s|^let SCKEY.*|let SCKEY = ${SCKEY};|" ${NOTIFYFN}
fi
if [ ! -z "${BARK_PUSH}" ]; then
    sed -i "s|^let BARK_PUSH.*|let BARK_PUSH = ${BARK_PUSH};|" ${NOTIFYFN}
fi
if [ ! -z "${BARK_SOUND}" ]; then
    sed -i "s|^let BARK_SOUND.*|let BARK_SOUND = ${BARK_SOUND};|" ${NOTIFYFN}
fi
if [ ! -z "${TG_BOT_TOKEN}" ]; then
    sed -i "s|^let TG_BOT_TOKEN.*|let TG_BOT_TOKEN = ${TG_BOT_TOKEN};|" ${NOTIFYFN}
fi
if [ ! -z "${TG_USER_ID}" ]; then
    sed -i "s|^let TG_USER_ID.*|let TG_USER_ID = ${TG_USER_ID};|" ${NOTIFYFN}
fi
if [ ! -z "${DD_BOT_TOKEN}" ]; then
    sed -i "s|^let DD_BOT_TOKEN.*|let DD_BOT_TOKEN = ${DD_BOT_TOKEN};|" ${NOTIFYFN}
fi
if [ ! -z "${DD_BOT_SECRET}" ]; then
    sed -i "s|^let DD_BOT_SECRET.*|let DD_BOT_SECRET = ${DD_BOT_SECRET};|" ${NOTIFYFN}
fi
if [ ! -z "${IGOT_PUSH_KEY}" ]; then
    sed -i "s|^let IGOT_PUSH_KEY.*|let IGOT_PUSH_KEY = ${IGOT_PUSH_KEY};|" ${NOTIFYFN}
fi

bashio::log.info "Updating *ShareCodes*.js"
FFN=/scripts/jdFruitShareCodes.js
PFN=/scripts/jdPetShareCodes.js
PBFN=/scripts/jdPlantBeanShareCodes.js
SMFN=/scripts/jdSuperMarketShareCodes.js

if [ ! -z "${FRUITSHARECODES1}" ]; then
    sed -i "s|.*shareCode[\,，].*|  \'${FRUITSHARECODES1}\'\,|1" ${FFN}
fi
if [ ! -z "${FRUITSHARECODES2}" ]; then
    sed -i "s|.*shareCode[\,，].*|  \'${FRUITSHARECODES2}\'\,|1" ${FFN}
fi
if [ ! -z "${PETSHARECODES1}" ]; then
    sed -i "s|.*shareCode[\,，].*|  \'${PETSHARECODES1}\'\,|1" ${PFN}
fi
if [ ! -z "${PETSHARECODES2}" ]; then
    sed -i "s|.*shareCode[\,，].*|  \'${PETSHARECODES2}\'\,|1" ${PFN}
fi
if [ ! -z "${PLANTBEANSHARECODES1}" ]; then
    sed -i "s|.*shareCode[\,，].*|  \'${PLANTBEANSHARECODES1}\'\,|1" ${PBFN}
fi
if [ ! -z "${PLANTBEANSHARECODES2}" ]; then
    sed -i "s|.*shareCode[\,，].*|  \'${PLANTBEANSHARECODES2}\'\,|1" ${PBFN}
fi
if [ ! -z "${SUPERMARKETSHARECODES1}" ]; then
    sed -i "s|.*shareCode[\,，].*|  \'${SUPERMARKETSHARECODES1}\'\,|1" ${SMFN}
fi
if [ ! -z "${SUPERMARKETSHARECODES2}" ]; then
    sed -i "s|.*shareCode[\,，].*|  \'${SUPERMARKETSHARECODES2}\'\,|1" ${SMFN}
fi

