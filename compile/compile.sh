#!/bin/bash

module use /mnt/shared/apps/modulefiles
module load 2022r1
module load compute
module load julia
module load openmpi/4.1.1-urzuzcv
module load petsc

# This script is to be executed from this folder (compile/)
# See https://juliaparallel.github.io/MPI.jl/latest/knownissues/#Julia-module-precompilation-1
# for a justification of this line
julia --project=../ --color=yes -e 'using Pkg; Pkg.instantiate()'
julia --project=../ --color=yes -e 'using Pkg; Pkg.precompile()'
julia --project=../ -O3 --check-bounds=no --color=yes compile.jl
