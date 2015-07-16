# auto deployment tools set
# Bruce.Lu <rikusouhou@gmail.com> 2015/07/16    initial version
#

#!/bin/sh

ROOTDIR=`pwd`
LOGFILE=$ROOTDIR/tts_log.txt
M_DST_TTSCAR=/root/auto-deploy-aliyun/tts-car/src/resources
M_SRC_TTSCAR=/root/auto-deploy-aliyun/conf/tts-car

cp -fr $M_SRC_TTSCAR/* $M_DST_TTSCAR/ 

#
echo "updating source code ..."
cd tts-car
svn up >$LOGFILE 2>&1

#
echo "building ..."
mvn clean package -DskipTests > $LOGFILE 2>&1
SUCCESS=`grep -c "BUILD SUCCESS" $LOGFILE`
echo $SUCCESS

if [ "$SUCCESS" == "1" ] 
then
echo "build success, deploying..."
rsync -v --progress -e "ssh -p 9922" target/tts-car.war root@120.55.172.117:/opt/apache-tomcat-8.0.24/webapps/
echo "done!"
else
echo "=== BUILD ERROR==="
tail -50 $LOGFILE
fi
cd $ROOTDIR
