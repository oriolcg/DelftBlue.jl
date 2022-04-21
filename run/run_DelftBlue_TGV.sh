#!/bin/sh
#
#SBATCH --job-name="TGV"
#SBATCH --partition=compute
#SBATCH --time=10:00:00
#SBATCH --ntasks=64
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G

source ../compile/modules.sh

mpiexecjl --project=../ -n 64 $HOME/progs/install/julia/1.7.2/bin/julia -J ../DelftBlue.so -O3 --check-bounds=no -e 'using DelftBlue; DelftBlue.main(16,2,4,0.05,10.0)'
