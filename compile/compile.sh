#!/bin/bash

module use /mnt/shared/apps/modulefiles
module load 2022r1
module load compute
module load openmpi/gcc/64/1.10.7

export JULIA_MPI_BINARY="system"
export JULIA_MPI_PATH="/cm/shared/apps/openmpi/gcc/64/1.10.7"
export JULIA_MPIEXEC="srun"
export JULIA_PETSC_LIBRARY="/home/ocolomesgene/progs/install/petsc/3.15.4/lib"

# This script is to be executed from this folder (compile/)
# See https://juliaparallel.github.io/MPI.jl/latest/knownissues/#Julia-module-precompilation-1
# for a justification of this line

echo 'Resolving versions'
$HOME/progs/install/julia/1.7.2/bin/julia --project=../ --color=yes -e 'using Pkg; Pkg.resolve()'
echo 'Instantiating'
$HOME/progs/install/julia/1.7.2/bin/julia --project=../ --color=yes -e 'using Pkg; Pkg.instantiate()'
echo 'Building MPI'
$HOME/progs/install/julia/1.7.2/bin/julia --project=../ --color=yes -e 'using Pkg; Pkg.build("MPI")'
echo 'Precompiling'
$HOME/progs/install/julia/1.7.2/bin/julia --project=../ --color=yes -e 'using Pkg; Pkg.precompile()'
echo 'Compiling'
$HOME/progs/install/julia/1.7.2/bin/julia --project=../ -O3 --check-bounds=no --color=yes compile.jl

echo 'end'
