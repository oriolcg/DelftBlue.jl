module DelftBlue

using Gridap
using GridapDistributed
using GridapGmsh
using PartitionedArrays
using Gridap.FESpaces: zero_free_values, interpolate!
using Gridap.Fields: meas
using LineSearches: BackTracking
using GridapPETSc
using GridapPETSc: PETSC

include("TGV.jl")
include("Cylinder.jl")

function main(n::Int,order::Int,np::Int,dt::Real,tf::Real;test="TGV",mesh_file="mesh.msh")
  prun(mpi,(np,np,np)) do parts
    options = "-snes_type newtonls -snes_linesearch_type basic  -snes_linesearch_damping 1.0 -snes_rtol 1.0e-12 -snes_atol 0.0 -snes_monitor -ksp_error_if_not_converged true -ksp_converged_reason -ksp_type preonly -pc_type lu -pc_factor_mat_solver_type mumps"
    if test=="TGV"
      GridapPETSc.with(args=split(options)) do
        run_TGV(parts,n,order,dt,tf)
      end
    elseif test=="Cylinder"
      GridapPETSc.with(args=split(options)) do
        run_Cylinder(parts,order,dt,tf,mesh_file)
      end
    end
  end
end


end
