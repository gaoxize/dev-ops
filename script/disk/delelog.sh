#bin/bash
BASEDIR=/opt/push

# 日志清理的进34m~KSEDIR=/opt/push
CENTER=$BASEDIR/statcenter/node1/log/
MYSQL=$BASEDIR/Summary/store2mysql/node1/log/
THIRDPART=$BASEDIR/thirdpartypushtask/node1/log/
REPORT=$BASEDIR/Summary/UserReportServer/node1/log/
# 日志清理的进34m~K
record_log() {
  echo "1312" > /var/run/clean-up.pid
}
# 清理的文件 
# 清理日志 当前文件 日期升序排序。清理文件日志时间未1个月
clean_mysql(){
  cd $MYSQL
  FILELIST=`ls   cut -d '.' -f1 | uniq`
  for file in $FILELIST
   do
  DELE_FILE=`ls -l $file* |  cut -d ' ' -f10 | sort -t "-" | grep -v "^$" | grep -v '^[0-9]'  | grep -v '^[A-Z]'  | head -n 2 | cut -d '-' -f1-2`
  rm -rf $MYSQL/$DELE_FILE-*
  done
}
clean_thirdpart(){
  cd $THIRDPART
  DELE_FILE=`ls -l   |  cut -d ' ' -f10 | sort -t "-" | grep -v "^$" | grep -v '^[0-9]'  | grep -v '^[A-Z]'  | head -n 2 | cut -d '-' -f1-2`
  rm -rf $THIRDPART/$DELE_FILE-*

}
clean_report(){
  cd $REPORT
  DELE_FILE=`ls -l   |  cut -d ' ' -f10 | sort -t "-" | grep -v "^$" | grep -v '^[0-9]'  | grep -v '^[A-Z]'  | head -n 2 | cut -d '-' -f1-2`
  rm -rf $REPORT/$DELE_FILE-*
}
clean_center(){
  cd $CENTER
  DELE_FILE= `ls -l   |  cut -d ' ' -f10 | sort -t "-" | grep -v "^$" | grep -v '^[0-9]'  | grep -v '^[A-Z]'  | head -n 2 | cut -d '-' -f1-2`
  rm -rf $CENTER/$DELE_FILE-*
}

clean_log() {
  ROOT_SIZE=`df -h | grep VolGroup00-LogVol01 | awk '{ print $5 }' | cut -c1-3`;
  echo "`date +%Y-%m-%d`  Disk utilization before cleaning  : $ROOT_SIZE %" >> /var/log/clean-up.log
  echo " Start cleaning loggers ......"
  clean_mysql
  clean_thirdpart
  clean_report
  clean_center
  echo "Disk space cleanup complete"
}
mail () {
# 挂载点 root 占用34m~G
SIZE=`df -h | grep VolGroup00-LogVol01 | awk '{ print $5 }' | cut -c1-3`
if [ -f /var/run/clean-up.pid ]
  then
    echo "`date +%Y-%m-%d`  The program is running, please exit ..." >> /var/log/clean-up.log
    exit
fi
 if [ $SIZE -ge 90 ]
then
  echo "`date +%Y-%m-%d` Disk space utilization reached 90 %" >> /var/log/clean-up.log;
  record_log
  clean_log
  rm -rf /var/run/clean-up.pid
  echo "`date +%Y-%m-%d`   The disk space has been cleaned up. The current disk utilization is : $SIZE %" >> /var/log/clean-up.log
else
  echo "this machine is not clean"
fi
}

mail
