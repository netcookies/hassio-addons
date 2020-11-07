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
    bashio::log.info "Setting ${name} to ${value}..."
    if [ ! -z "${value}" ]; then
        ENVS="${name}=""'""${value}""' "${ENVS}
    fi
done

# git pull
bashio::log.info "Updating repo..."
git -C /scripts/ fetch --all
git -C /scripts/ reset --hard origin/master


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
sed -i 's/\(.*\)git.*pull.*/\1cd \/;.\/modifyCronFile.sh > \/proc\/1\/fd\/1 2> \/proc\/1\/fd\/2/g' ${CNF}

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

# Load ShareCodes
bashio::log.info "Updating *ShareCodes*.js"
FFN=/scripts/jdFruitShareCodes.js
PFN=/scripts/jdPetShareCodes.js
PBFN=/scripts/jdPlantBeanShareCodes.js
SMFN=/scripts/jdSuperMarketShareCodes.js
# FruitShareCodes
bashio::log.info "Setting Fruit Share Codes..."
sed -i "/^let.*ShareCodes = \[/,/^\]$/d" ${FFN}
sed -i "1s|^|\]\n|" ${FFN}
if [ ! -z "$(bashio::config 'sharecodes.fruit[1]')" ]; then
    value=$(bashio::config "sharecodes.fruit[1]")
else
    value=535a7bfc56e1468e8c09f2657ea04e3b
fi
sed -i "1s|^|  \'${value}\'\n|" ${FFN}
if [ ! -z "$(bashio::config 'sharecodes.fruit[0]')" ]; then
    value=$(bashio::config "sharecodes.fruit[0]")
else
    value=535a7bfc56e1468e8c09f2657ea04e3b
fi
sed -i "1s|^|  \'${value}\'\,\n|" ${FFN}
sed -i "1s|^|let FruitShareCodes = \[\n|" ${FFN}

# PetShareCodes
bashio::log.info "Setting Pet Share Codes..."
sed -i "/^let.*ShareCodes = \[/,/^\]$/d" ${PFN}
sed -i "1s|^|\]\n|" ${PFN}
if [ ! -z "$(bashio::config 'sharecodes.pet[1]')" ]; then
    value=$(bashio::config "sharecodes.pet[1]")
else
    value="MTE1NDQ5MzYwMDAwMDAwMzgyNDA5NTU="
fi
sed -i "1s|^|  \'${value}\'\n|" ${PFN}
if [ ! -z "$(bashio::config 'sharecodes.pet[0]')" ]; then
    value=$(bashio::config "sharecodes.pet[0]")
else
    value="MTE1NDQ5MzYwMDAwMDAwMzgyNDA5NTU="
fi
sed -i "1s|^|  \'${value}\'\,\n|" ${PFN}
sed -i "1s|^|let PetShareCodes = \[\n|" ${PFN}

# PlantBeanShareCodes
bashio::log.info "Setting PlantBean Share Codes..."
sed -i "/^let.*ShareCodes = \[/,/^\]$/d" ${PBFN}
sed -i "1s|^|\]\n|" ${PBFN}
if [ ! -z "$(bashio::config 'sharecodes.plantbean[1]')" ]; then
    value=$(bashio::config "sharecodes.plantbean[1]")
else
    value=7i2k65oy4qkh53m4dkp6ybeg6y
fi
sed -i "1s|^|  \'${value}\'\n|" ${PBFN}
if [ ! -z "$(bashio::config 'sharecodes.plantbean[0]')" ]; then
    value=$(bashio::config "sharecodes.plantbean[0]")
else
    value=7i2k65oy4qkh53m4dkp6ybeg6y
fi
sed -i "1s|^|  \'${value}\'\,\n|" ${PBFN}
sed -i "1s|^|let PlantBeanShareCodes = \[\n|" ${PBFN}

# SuperMarketShareCodes
bashio::log.info "Setting SuperMarket Share Codes..."
sed -i"/^let.*ShareCodes = \[/,/^\]$/d" ${SMFN}
sed -i "1s|^|\]\n|" ${SMFN}
if [ ! -z "$(bashio::config 'sharecodes.supermarket[1]')" ]; then
    value=$(bashio::config "sharecodes.supermarket[1]")
else
    value=eU9YaejjYv4g8T2EwnsVhQ
fi
sed -i "1s|^|  \'${value}\'\n|" ${SMFN}
if [ ! -z "$(bashio::config 'sharecodes.supermarket[0]')" ]; then
    value=$(bashio::config "sharecodes.supermarket[0]")
else
    value=eU9YaejjYv4g8T2EwnsVhQ
fi
sed -i "1s|^|  \'${value}\'\,\n|" ${SMFN}
sed -i "1s|^|let SuperMarketShareCodes = \[\n|" ${SMFN}

