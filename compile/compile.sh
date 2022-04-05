#!/bin/bash

#SBATCH --partition=compute
#SBATCH --qos=short
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1024
#SBATCH --hint=compute_bound

module use /mnt/shared/apps/modulefiles
module load 2022r1
module load compute
module load julia
module load openmpi/4.1.1-urzuzcv


export JULIA_MPI_BINARY="/mnt/shared/apps/2022r1/compute/linux-rhel8-skylake_avx512/gcc-8.5.0/openmpi-4.1.1-urzuzcvzrdedifi3mm527t4wgiisuvld/bin"
export JULIA_PETSC_LIBRARY="/home/ocolomesgene/progs/install/petsc/3.15.4/lib"

# This script is to be executed from this folder (compile/)
# See https://juliaparallel.github.io/MPI.jl/latest/knownissues/#Julia-module-precompilation-1
# for a justification of this line

echo 'Instantiating'
julia --project=../ --color=yes -e 'using Pkg; Pkg.instantiate()'
echo 'Precompiling'
julia --project=../ --color=yes -e 'using Pkg; Pkg.precompile()'
echo 'Compiling'
julia --project=../ -O3 --check-bounds=no --color=yes compile.jl

echo 'end'
