module load 2022r1 compute openmpi
export LD_LIBRARY_PATH=$HOME/progs/install/petsc/3.15.4/lib:$LD_LIBRARY_PATH
export JULIA_MPI_BINARY=system
export JULIA_MPI_PATH=/mnt/shared/apps/2022r1/compute/linux-rhel8-skylake_avx512/gcc-8.5.0/openmpi-4.1.1-urzuzcvzrdedifi3mm527t4wgiisuvld
export JULIA_MPIEXEC=srun
export JULIA_PETSC_LIBRARY=$HOME/progs/install/petsc/3.15.4/lib/libpetsc.so
export DELFTBLUE_MODELS=/scratch/ocolomesgene/tests/julia/DelftBlue.jl/models
