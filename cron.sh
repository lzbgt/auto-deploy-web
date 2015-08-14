#!/bin/sh
#### Bruce.Lu 2015/06/06 Initial Version


#*/5 * * * * cd /home/autodeploy/src/angle-web; sh cron.sh

ROOT=`pwd`
LASTVERSION=`cat version 2>/dev/null`
LOGFILE=gulp.log
echo "updating source code.. "
svn up >$LOGFILE 2>&1

#
CURVERSION=`svn info|tail -3|head -1|cut -d" " -f2`
echo 1$LASTVERSION
echo 2$CURVERSION
if [ "$LASTVERSION" == "$CURVERSION" ]
then
exit 0
fi


rm -fr app/{views,pages,js}
#
cd master
echo "gulping..."
gulp > $LOGFILE 2>&1 &
PID=$!

FINISHED=no
while [ $FINISHED != "1" ]
do
FINISHED=`grep -c "All Done" $LOGFILE`
sleep 1
done
#
(kill -9 $PID  2>&1) > /dev/null
SUCCESS=`grep -ic "error" $LOGFILE`
echo $SUCCESS
cd $ROOT
echo $CURVERSION >version
