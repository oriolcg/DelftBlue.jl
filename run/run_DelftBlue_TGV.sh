#!/bin/sh
#
#SBATCH --job-name="TGV"
#SBATCH --partition=compute
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G

module use /mnt/shared/apps/modulefiles
module load 2022r1
module load compute
module load openmpi/gcc/64/1.10.7

export JULIA_MPI_BINARY="system"
export JULIA_MPI_PATH="/cm/shared/apps/openmpi/gcc/64/1.10.7"
export JULIA_MPIEXEC="srun"

$HOME/progs/install/julia/1.7.2/bin/julia --project=../ -e 'using Pkg; Pkg.instantiate();'
$HOME/progs/install/julia/1.7.2/bin/julia --project=../ -e 'using Pkg; Pkg.precompile();'
$HOME/progs/install/julia/1.7.2/bin/julia --project=../ -e 'using Pkg; Pkg.build("MPI");'

srun -n 8 $HOME/progs/install/julia/1.7.2/bin/julia --project=../ -J ../DelftBlue.so -O3 --check-bounds=no\
     -e 'using DelftBlue; DelftBlue.main(16,2,2)'
