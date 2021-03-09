#!/bin/bash

DATE=$(date +"%Y%m%d")
BASEPATH="${PRJDIR}/GFS"
EXECFILE="single_gfs.sh"
STATUSFILE="${PRJDIR}/status.log"

echo "$(date '+%d/%m/%Y %H:%M:%S'): Downloading GFS" > ${STATUSFILE}

for j in {1..100}
do
    X=1
    echo "Checking GFS data. Attempt: $j" >> ${STATUSFILE}
    seq ${hinit} ${hstop} | xargs -n 1 -P 8 ${BASEPATH}/${EXECFILE}
    for i in $(seq ${hinit} ${hstop})
    do 
        HOUR=$(printf %03d $i)
        CHECKFILE="${BASEPATH}/${HOUR}.check" >> ${STATUSFILE}
        if [[ ! -f $CHECKFILE || $(<$CHECKFILE) != $DATE ]]; then
            echo "${HOUR}.check should be updated"
            X=0
            break
        fi
    done

    if [ $X -eq 1 ]; then
        break
    else
        echo "Waiting for the next attempt..." >> ${STATUSFILE}
        sleep 200
    fi
done

if [ $X -eq 1 ]; then
    echo "$(date '+%d/%m/%Y %H:%M:%S'): GFS downloaded!" >> ${STATUSFILE}
    echo "***************" >> ${STATUSFILE}
else
    echo "Update Failed. Stopping..." >> ${STATUSFILE}
fi
