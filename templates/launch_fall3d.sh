#!/bin/bash

BASEPATH="${PRJDIR}"

echo "GFS updated. Launching jobs..."
bsub < ${BASEPATH}/SCRIPTS/FALL3D.cmd
bsub < ${BASEPATH}/SCRIPTS/FALL3D_POS.cmd
