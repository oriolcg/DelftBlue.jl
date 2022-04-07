module use /mnt/shared/apps/modulefiles
module load 2022r1
module load compute
module load cmake
module load openmpi/gcc/64/1.10.7
module load blas/gcc/64/3.8.0
module load lapack/gcc/64/3.9.0

CURR_DIR=$(pwd)
PACKAGE=petsc
VERSION=3.15.4
INSTALL_ROOT=$HOME/progs/install
PETSC_INSTALL=$INSTALL_ROOT/$PACKAGE/$VERSION
TAR_FILE=$PACKAGE-$VERSION.tar.gz
URL="https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/"
ROOT_DIR=$HOME/progs
SOURCES_DIR=$ROOT_DIR/$PACKAGE-$VERSION
BUILD_DIR=$SOURCES_DIR/build
wget -q $URL/$TAR_FILE -O $ROOT_DIR/$TAR_FILE
mkdir -p $SOURCES_DIR
tar xzf $ROOT_DIR/$TAR_FILE -C $SOURCES_DIR --strip-components=1
cd $SOURCES_DIR
./configure --prefix=$PETSC_INSTALL --with-cc=mpicc --with-cxx=mpicxx --with-fc=mpif90 \
            --download-mumps --download-scalapack --download-parmetis --download-metis \
            --download-ptscotch --with-debugging --with-x=0 --with-shared=1 \
            --with-mpi=1 --with-64-bit-indices --with-shared-libraries=0
make
make install
