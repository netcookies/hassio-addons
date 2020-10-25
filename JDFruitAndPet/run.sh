#!/usr/bin/with-contenv bashio

export JD_COOKIE=$(bashio::config "JD_COOKIE")
export DD_BOT_TOKEN=$(bashio::config "DD_BOT_TOKEN")
export DD_BOT_SECRET=$(bashio::config "DD_BOT_SECRET")
export PLANT_BEAN_SHARECODES=$(bashio::config "PLANT_BEAN_SHARECODES")
export FRUITSHARECODES=$(bashio::config "FRUITSHARECODES")
export PETSHARECODES=$(bashio::config "PETSHARECODES")
export JOY_FEED_COUNT=$(bashio::config "JOY_FEED_COUNT")
export SUPERMARKET_SHARECODES=$(bashio::config "SUPERMARKET_SHARECODES")
export MARKET_COIN_TO_BEANS=$(bashio::config "MARKET_COIN_TO_BEANS")
export JD_DEBUG=$(bashio::config "JD_DEBUG")
export CRONTAB_LIST_FILE=$(bashio::config "CRONTAB_LIST_FILE")
export ENABLE_JD_BEAN=$(bashio::config "ENABLE_JD_BEAN")

bashio::log.info "Initializing..."

cd /;./modifyCronFile.sh

cron -f

exit 0
