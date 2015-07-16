# auto deployment tools set
# Bruce.Lu <rikusouhou@gmail.com> 2015/07/16    initial version
#

#!/bin/sh
PROJ=angle-web
ROOTDIR=`pwd`
LOGFILE=$ROOTDIR/$PROJ.txt
M_DST=/root/auto-deploy-aliyun/$PROJ
M_SRC=/root/auto-deploy-aliyun/conf/$PROJ

cp -fr $M_SRC/* $M_DST/

#
echo "updating source code ..."
cd $PROJ
svn up >$LOGFILE 2>&1

#
cd $ROOTDIR
echo "building ..."
cd $PROJ/master
gulp > $LOGFILE 2>&1 &
PID=$!

FINISHED=no
while [ $FINISHED != "1" ]
do
FINISHED=`grep -c "All Done" $LOGFILE`
sleep 3
done

#
(kill -9 $PID  2>&1) > /dev/null
SUCCESS=`grep -ic "error" $LOGFILE`
echo $SUCCESS

if [ "$SUCCESS" == "0" ] 
then
echo "build success, deploying..."
cd $ROOTDIR/$PROJ/
tar czf $ROOTDIR/tmp.tgz angular_conf.ini cron.conf index.html server vendor app favicon.ico main.go start.sh
cd $ROOTDIR
rsync -v --progress -e "ssh -p 9922" tmp.tgz root@121.43.71.84:/opt/gocode/src
ssh -p 9922 root@121.43.71.84 tar -xzf /opt/gocode/src/tmp.tgz -C /opt/gocode/src/angle-web
echo "done!"
else
echo "=== BUILD ERROR==="
grep -i error -A10 -B10 $LOGFILE
fi
cd $ROOTDIR
