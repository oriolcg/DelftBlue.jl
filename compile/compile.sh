#!/bin/bash

#SBATCH --job-name="gridapdist"
#SBATCH --partition=compute
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=180G

source modules.sh

julia --project=../ -O3 --check-bounds=no --color=yes compile.jl

