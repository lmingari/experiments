#!/bin/bash

DATE=$(date +"%Y%m%d")
BASEPATH="${PRJDIR}"
CMDPATH="${BASEPATH}/SCRIPTS_MN4"
PRIORITY=YES

for j in {1..100}
do
    X=1
    echo "Checking GFS data. Attempt: $j"
    for i in $(seq 0 48)
    do 
        HOUR=$(printf %03d $i)
        CHECKFILE=$BASEPATH/GFS/$HOUR.check
        if [[ ! -f $CHECKFILE || $(<$CHECKFILE) != $DATE ]]; then
            echo "$HOUR.check should be updated"
            X=0
            break
        fi
    done

    if [ $X -eq 1 ]; then
        break
    else
        echo "Waiting for the next attempt..."
        sleep 200
    fi
done

if [ "$PRIORITY" == "YES" ]; then
    sarg="--reservation=volcano"
else
    sarg="--qos=debug"
fi

if [ $X -eq 1 ]; then
    echo "GFS updated. Launching jobs..."
    msg=$(sbatch                             ${sarg} ${CMDPATH}/FALL3D_PRE.cmd) && jid11=${msg##* }
    msg=$(sbatch --dependency=afterok:$jid11 ${sarg} ${CMDPATH}/FALL3D.cmd) && jid12=${msg##* }
    msg=$(sbatch --dependency=afterok:$jid12 ${sarg} ${CMDPATH}/FALL3D_POS.cmd)
    #
    msg=$(sbatch --dependency=afterok:$jid11 ${sarg} ${CMDPATH}/FALL3D-GFS_PRE.cmd) && jid21=${msg##* }
    msg=$(sbatch --dependency=afterok:$jid21 ${sarg} ${CMDPATH}/FALL3D-GFS.cmd) && jid22=${msg##* }
    msg=$(sbatch --dependency=afterok:$jid22 ${sarg} ${CMDPATH}/FALL3D-GFS_POS.cmd)
    #
    msg=$(sbatch --dependency=afterany:$jid12:$jid22 ${sarg} ${CMDPATH}/FALL3D-ENS.cmd)
else
    echo "GFS data not found. Stopping..."
fi
