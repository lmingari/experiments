#!/bin/bash

module purge
module load intel/2017.4
module load impi/2017.4
module load MKL/2017.4

export BASEDIR=/gpfs/projects/bsc21/bsc21908
export DIRLIB=${BASEDIR}/libraries-nd3
export WRFDIR=${BASEDIR}/WRF/4.2-nd3
export F3DIR=/gpfs/scratch/bsc21/bsc21908/development/bin
export EXPDIR=/gpfs/scratch/bsc21/bsc21908/experiments

export H5DIR=$DIRLIB/hdf5-1.10.4
export ZDIR=$DIRLIB/zlib-1.2.11
export PNGDIR=$DIRLIB/libpng-1.6.36
export NCDIR=$DIRLIB/netcdf-4.5.0
export NFDIR=$DIRLIB/netcdf-4.5.0
export JASPERDIR=$DIRLIB/jasper-1.900.2

export LD_LIBRARY_PATH=$H5DIR/lib:$ZDIR/lib:$NCDIR/lib:${JASPERDIR}/lib:${PNGDIR}/lib:$LD_LIBRARY_PATH
export PATH=$NCDIR/bin:$PATH

export NCARG_RANGS=/gpfs/scratch/bsc21/bsc21908/experiments/rangs
