#!/bin/bash

# Vars
PING_HOST_1="facebook.com"
PING_HOST_2="yahoo.com"
PING_HOST_3="google.com"

PING_HOST_4="10.192.202.58"
PING_HOST_5="10.198.127.190"
PING_HOST_6="10.200.125.16"

TMP_DIR="/tmp/memodata/"
HOSTNAME=`hostname`
COLLECTOR_URI="http://yourserver.com/collector.php"

echo Start!

# Setup

mkdir $TMP_DIR

# Run

TIME_START=`date +%s`

echo Latency test..
ping -c 20 -w 30 $PING_HOST_1 > ${TMP_DIR}ping1.out
sleep 2
ping -c 20 -w 30 $PING_HOST_2 > ${TMP_DIR}ping2.out
sleep 2
ping -c 20 -w 30 $PING_HOST_3 > ${TMP_DIR}ping3.out
sleep 2
ping -c 20 -w 30 $PING_HOST_4 > ${TMP_DIR}ping4.out
sleep 2
ping -c 20 -w 30 $PING_HOST_5 > ${TMP_DIR}ping5.out
sleep 2
ping -c 20 -w 30 $PING_HOST_6 > ${TMP_DIR}ping6.out
sleep 2

TIME_END=`date +%s`


# Parsing (can be improved)
PING_MIN1=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping1.out | cut -d ' ' -f 4 | cut -d '/' -f 1`
PING_AVG1=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping1.out | cut -d ' ' -f 4 | cut -d '/' -f 2`
PING_MAX1=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping1.out | cut -d ' ' -f 4 | cut -d '/' -f 3`
PING_MDEV1=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping1.out | cut -d ' ' -f 4 | cut -d '/' -f 4`

PING_MIN2=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping2.out | cut -d ' ' -f 4 | cut -d '/' -f 1`
PING_AVG2=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping2.out | cut -d ' ' -f 4 | cut -d '/' -f 2`
PING_MAX2=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping2.out | cut -d ' ' -f 4 | cut -d '/' -f 3`
PING_MDEV2=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping2.out | cut -d ' ' -f 4 | cut -d '/' -f 4`

PING_MIN3=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping3.out | cut -d ' ' -f 4 | cut -d '/' -f 1`
PING_AVG3=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping3.out | cut -d ' ' -f 4 | cut -d '/' -f 2`
PING_MAX3=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping3.out | cut -d ' ' -f 4 | cut -d '/' -f 3`
PING_MDEV3=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping3.out | cut -d ' ' -f 4 | cut -d '/' -f 4`

PING_MIN4=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping4.out | cut -d ' ' -f 4 | cut -d '/' -f 1`
PING_AVG4=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping4.out | cut -d ' ' -f 4 | cut -d '/' -f 2`
PING_MAX4=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping4.out | cut -d ' ' -f 4 | cut -d '/' -f 3`
PING_MDEV4=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping4.out | cut -d ' ' -f 4 | cut -d '/' -f 4`

PING_MIN5=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping5.out | cut -d ' ' -f 4 | cut -d '/' -f 1`
PING_AVG5=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping5.out | cut -d ' ' -f 4 | cut -d '/' -f 2`
PING_MAX5=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping5.out | cut -d ' ' -f 4 | cut -d '/' -f 3`
PING_MDEV5=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping5.out | cut -d ' ' -f 4 | cut -d '/' -f 4`

PING_MIN6=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping6.out | cut -d ' ' -f 4 | cut -d '/' -f 1`
PING_AVG6=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping6.out | cut -d ' ' -f 4 | cut -d '/' -f 2`
PING_MAX6=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping6.out | cut -d ' ' -f 4 | cut -d '/' -f 3`
PING_MDEV6=`grep "rtt min/avg/max/mdev" ${TMP_DIR}ping6.out | cut -d ' ' -f 4 | cut -d '/' -f 4`

JSON="{ \"hostname\": \"${HOSTNAME}\",
	\"time_start\": \"${TIME_START}\",
	\"time_end\": \"${TIME_END}\",
	\"ping_data_1\": { \"min\": \"${PING_MIN1}\", \"max\": \"${PING_MAX1}\", \"avg\": \"${PING_AVG1}\", \"mdev\": \"${PING_MDEV1}\" },
	\"ping_data_2\": { \"min\": \"${PING_MIN2}\", \"max\": \"${PING_MAX2}\", \"avg\": \"${PING_AVG2}\", \"mdev\": \"${PING_MDEV2}\" },
	\"ping_data_3\": { \"min\": \"${PING_MIN3}\", \"max\": \"${PING_MAX3}\", \"avg\": \"${PING_AVG3}\", \"mdev\": \"${PING_MDEV3}\" },
	\"ping_data_4\": { \"min\": \"${PING_MIN4}\", \"max\": \"${PING_MAX4}\", \"avg\": \"${PING_AVG4}\", \"mdev\": \"${PING_MDEV4}\" },
	\"ping_data_5\": { \"min\": \"${PING_MIN5}\", \"max\": \"${PING_MAX5}\", \"avg\": \"${PING_AVG5}\", \"mdev\": \"${PING_MDEV5}\" },
	\"ping_data_6\": { \"min\": \"${PING_MIN6}\", \"max\": \"${PING_MAX6}\", \"avg\": \"${PING_AVG6}\", \"mdev\": \"${PING_MDEV6}\" }
}"

echo $JSON > ${TMP_DIR}json

echo Sending data..
curl -v -d @${TMP_DIR}json -X POST ${COLLECTOR_URI}

# Cleanup
rm -rf ${TMP_DIR}

echo End.

echo $JSON
