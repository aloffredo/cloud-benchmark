#!/bin/bash

# Vars
PING_HOST="123.123.123.123" 
WEB_RESOURCE="http://123.123.123.123/file.txt"
TMP_DIR="/tmp/memodata/"
HOSTNAME=`hostname`
COLLECTOR_URI="http://yourserver.com/collector.php"


echo Start!

# Setup

mkdir $TMP_DIR
sysbench --test=fileio --file-total-size=400M --file-test-mode=rndrw prepare


# Run

TIME_START=`date +%s`

echo Cpu test..
sysbench --test=cpu run > ${TMP_DIR}cpu.out

echo Memory test..
sysbench --test=memory --memory-total-size=5G run > ${TMP_DIR}memory.out

echo IO test..
sysbench --test=fileio --file-total-size=400M --file-test-mode=rndrw run > ${TMP_DIR}io.out

echo Latency test..
ping -c 10 -w 10 $PING_HOST > ${TMP_DIR}ping.out

echo Web test..
curl $WEB_RESOURCE -o /dev/null -w stats\ %{speed_download}\ %{time_connect} > ${TMP_DIR}web.out

TIME_END=`date +%s`


# Parsing (can be improved)

CPU_TOTAL=`grep "total time:" ${TMP_DIR}cpu.out | tr -s ' ' | cut -d ' ' -f 4`
CPU_MIN=`grep "min:" ${TMP_DIR}cpu.out | tr -s ' ' | cut -d ' ' -f 3`
CPU_MAX=`grep "max:" ${TMP_DIR}cpu.out | tr -s ' ' | cut -d ' ' -f 3`
CPU_AVG=`grep "avg:" ${TMP_DIR}cpu.out | tr -s ' ' | cut -d ' ' -f 3`
CPU_95P=`grep "approx." ${TMP_DIR}cpu.out | tr -s ' ' | cut -d ' ' -f 5`

MEMORY_TOTAL=`grep "total time:" ${TMP_DIR}memory.out | tr -s ' ' | cut -d ' ' -f 4`
MEMORY_MIN=`grep "min:" ${TMP_DIR}memory.out | tr -s ' ' | cut -d ' ' -f 3`
MEMORY_MAX=`grep "max:" ${TMP_DIR}memory.out | tr -s ' ' | cut -d ' ' -f 3`
MEMORY_AVG=`grep "avg:" ${TMP_DIR}memory.out | tr -s ' ' | cut -d ' ' -f 3`
MEMORY_95P=`grep "approx." ${TMP_DIR}memory.out | tr -s ' ' | cut -d ' ' -f 5`

IO_TOTAL=`grep "total time:" ${TMP_DIR}io.out | tr -s " " | cut -d ' ' -f 4`
IO_MIN=`grep "min:" ${TMP_DIR}io.out | tr -s " " | cut -d ' ' -f 3`
IO_MAX=`grep "max:" ${TMP_DIR}io.out | tr -s " " | cut -d ' ' -f 3`
IO_AVG=`grep "avg:" ${TMP_DIR}io.out | tr -s " " | cut -d ' ' -f 3`
IO_95P=`grep "approx." ${TMP_DIR}io.out | tr -s " " | cut -d ' ' -f 5`

PING_MIN=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping.out | cut -d ' ' -f 4 | cut -d '/' -f 1`
PING_AVG=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping.out | cut -d ' ' -f 4 | cut -d '/' -f 2`
PING_MAX=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping.out | cut -d ' ' -f 4 | cut -d '/' -f 3`
PING_MDEV=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping.out | cut -d ' ' -f 4 | cut -d '/' -f 4`

WEB_SPEED=`grep stats ${TMP_DIR}web.out | cut -d ' ' -f 2`
WEB_TCP_TIME_START=`grep stats ${TMP_DIR}web.out | cut -d ' ' -f 3`


# Print
echo total times $CPU_TOTAL $MEMORY_TOTAL $IO_TOTAL
echo cpu         $CPU_MIN $CPU_MAX $CPU_AVG $CPU_95P
echo memory      $MEMORY_MIN $MEMORY_MAX $MEMORY_AVG $MEMORY_95P
echo io          $IO_MIN $IO_MAX $IO_AVG $IO_95P
echo ping        $PING_MIN $PING_MAX $PING_AVG $PING_MDEV
echo web $WEB_SPEED $WEB_TCP_TIME_START

JSON="{ \"hostname\": \"${HOSTNAME}\",
	\"time_start\": \"${TIME_START}\",
	\"time_end\": \"${TIME_END}\",
	\"cpu_data\": { \"total\": \"${CPU_TOTAL}\", \"min\": \"${CPU_MIN}\",\"max\": \"${CPU_MAX}\",\"avg\": \"${CPU_AVG}\",\"95p\": \"${CPU_95P}\" },
	\"memory_data\": { \"total\": \"${MEMORY_TOTAL}\", \"min\": \"${MEMORY_MIN}\",\"max\": \"${MEMORY_MAX}\",\"avg\": \"${MEMORY_AVG}\",\"95p\": \"${MEMORY_95P}\" },
	\"io_data\": { \"total\": \"${IO_TOTAL}\", \"min\": \"${IO_MIN}\",\"max\": \"${IO_MAX}\",\"avg\": \"${IO_AVG}\",\"95p\": \"${IO_95P}\" },
	\"ping_data\": { \"min\": \"${PING_MIN}\", \"max\": \"${PING_MAX}\", \"avg\": \"${PING_AVG}\", \"mdev\": \"${PING_MDEV}\" },
	\"web_data\": {\"avg_speed\": \"${WEB_SPEED}\", \"tcp_startup_time\": \"${WEB_TCP_TIME_START}\" }
}"

echo $JSON > ${TMP_DIR}json

echo Sending data..
curl -v -d @${TMP_DIR}json -X POST ${COLLECTOR_URI}

# Cleanup
rm -rf ${TMP_DIR}
sysbench --test=fileio --file-total-size=400M --file-test-mode=rndrw cleanup

echo End.

