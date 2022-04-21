module use /mnt/shared/apps/modulefiles
module load 2022r1
module load compute
module load cmake
module load openmpi
# module load mumps
# module load parmetis
# module load metis
# module load scotch
# module load blas/gcc/64/3.8.0
# module load lapack/gcc/64/3.9.0

CURR_DIR=$(pwd)
PACKAGE=petsc
VERSION=3.15.4
INSTALL_ROOT=$HOME/progs/install
PETSC_INSTALL=$INSTALL_ROOT/$PACKAGE/$VERSION
TAR_FILE=$PACKAGE-$VERSION.tar.gz
URL="https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/"
ROOT_DIR=$HOME/progs/src
SOURCES_DIR=$ROOT_DIR/$PACKAGE-$VERSION
BUILD_DIR=$SOURCES_DIR/build

# LIBRARY DIRS
# MUMPS_DIR=/mnt/shared/apps/2022r1/compute/linux-rhel8-skylake_avx512/gcc-8.5.0/mumps-5.4.0-acgbqim4xexmzh4ctbwuasyaopei7d36
# PARMETIS_DIR=/mnt/shared/apps/2022r1/compute/linux-rhel8-skylake_avx512/gcc-8.5.0/parmetis-4.0.3-atxliywzunzugb7rlnxl4jnq4mjhvq5u
# METIS_DIR=/mnt/shared/apps/2022r1/compute/linux-rhel8-skylake_avx512/gcc-8.5.0/metis-5.1.0-gn7fgt42l45tb242f46ttymhhh2agptl
# PTSCOTCH_DIR=/mnt/shared/apps/2022r1/compute/linux-rhel8-skylake_avx512/gcc-8.5.0/scotch-6.1.1-yyk4taq7exhp37o3ke7h4ziu3fkbd65y

curl -OL $URL/$TAR_FILE -O $ROOT_DIR/$TAR_FILE
mkdir -p $SOURCES_DIR
tar xzf $ROOT_DIR/$TAR_FILE -C $SOURCES_DIR
cd $SOURCES_DIR
#./configure --prefix=$PETSC_INSTALL --with-cc=mpicc --with-cxx=mpicxx --with-fc=mpif90 \
#            --download-mumps- --download-scalapack --download-parmetis --download-metis \
#            --download-ptscotch --download-fblaslapack --with-debugging --with-x=0 --with-shared=1 \
#            --with-mpi=1 --with-64-bit-indices

./configure --prefix=$PETSC_INSTALL --with-cc=mpicc --with-cxx=mpicxx --with-fc=mpif90 \
            --with-debugging --with-x=0 --with-shared=1 \
            --with-mpi=1 --with-64-bit-indices
make
make install
