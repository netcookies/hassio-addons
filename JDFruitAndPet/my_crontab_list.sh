0 */1 * * * git -C /scripts/ pull > /proc/1/fd/1 2> /proc/1/fd/2; sed -i "/jd_bean_sign.jsh/d" /scripts/docker/crontab_list.sh
2 */1 * * * crontab /scripts/docker/${CRONTAB_LIST_FILE}
0 0-18/6 * * * node /scripts/jd_818.js > /proc/1/fd/1 2> /proc/1/fd/2
0,10 0 * * * node /scripts/jd_xtg.js > /proc/1/fd/1 2> /proc/1/fd/2
0 0 * * * node /scripts/jd_blueCoin.js > /proc/1/fd/1 2> /proc/1/fd/2
0 0 * * * node /scripts/jd_club_lottery.js > /proc/1/fd/1 2> /proc/1/fd/2
5 6-18/6 * * * node /scripts/jd_fruit.js > /proc/1/fd/1 2> /proc/1/fd/2
15 */2 * * * node /scripts/jd_joy.js > /proc/1/fd/1 2> /proc/1/fd/2
15 */1 * * * node /scripts/jd_joy_feedPets.js > /proc/1/fd/1 2> /proc/1/fd/2
0 0-16/8 * * * node /scripts/jd_joy_reward.js > /proc/1/fd/1 2> /proc/1/fd/2
0 0,6 * * * node /scripts/jd_joy_steal.js > /proc/1/fd/1 2> /proc/1/fd/2
0 */2 * * * node /scripts/jd_moneyTree.js > /proc/1/fd/1 2> /proc/1/fd/2
5 6-18/6 * * * node /scripts/jd_pet.js > /proc/1/fd/1 2> /proc/1/fd/2
0 7-21/2 * * * node /scripts/jd_plantBean.js > /proc/1/fd/1 2> /proc/1/fd/2
1 1 * * * node /scripts/jd_redPacket.js > /proc/1/fd/1 2> /proc/1/fd/2
10 0 * * * node /scripts/jd_shop.js > /proc/1/fd/1 2> /proc/1/fd/2
8 */3 * * * node /scripts/jd_speed.js > /proc/1/fd/1 2> /proc/1/fd/2
11 1-23/5 * * * node /scripts/jd_superMarket.js > /proc/1/fd/1 2> /proc/1/fd/2
55 23 * * * node /scripts/jd_unsubscribe.js > /proc/1/fd/1 2> /proc/1/fd/2
