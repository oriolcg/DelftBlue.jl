module DelftBlue

using Gridap
using GridapDistributed
using PartitionedArrays
using Gridap.FESpaces: zero_free_values, interpolate!
using Gridap.Fields: meas
using LineSearches: BackTracking

function main(n::Int,order::Int,np::Int)
  prun(mpi,(np,np,np)) do parts
    run_TGV(parts,n,order)
  end
end

function run_TGV(parts,n::Int,order::Int)

  # Parameters
  L = 2π
  Re = 100.0
  ν = 1/Re

  # TGV initial solution
  u₀(x) = VectorValue(cos(x[1])*sin(x[2])*sin(x[3]),-sin(x[1])*cos(x[2])*sin(x[3]),0.0)
  p₀(x) = 1/16*(cos(2*x[1])+cos(2*x[2]))*(cos(2*x[3])+2)

  # Discretization
  domain = (0,L,0,L,0,L)
  cells = (n,n,n)
  𝒯 = CartesianDiscreteModel(parts,domain,cells;isperiodic=(true,true,true))

  # Triangulation and Integration measure
  Ω = Interior(𝒯)
  dΩ = Measure(Ω,2*order)

  # FE spaces
  refFEᵤ = ReferenceFE(lagrangian,VectorValue{3,Float64},order)
  refFEₚ = ReferenceFE(lagrangian,Float64,order-1)
  V = TestFESpace(𝒯,refFEᵤ)
  Q = TestFESpace(𝒯,refFEₚ)
  U = TransientTrialFESpace(V)
  P = TrialFESpace(Q)
  Y = MultiFieldFESpace([V,Q])
  X = TransientMultiFieldFESpace([U,P])

  # Explicit FE functions
  global ηₙₕ = interpolate(VectorValue(0.0,0.0,0.0),U(0.0))
  global uₙₕ = interpolate(u₀,U(0.0))
  global fv_u = zero_free_values(U(0.0))

  # Stabilization Parameters
  c₁ = 12.0
  c₂ = 2.0
  cc = 4.0
  h = L/(n*order)
  τₘ = 1/(c₁*ν/h^2 + c₂*(meas∘uₙₕ)/h)
  τc = cc *(h^2/(c₁*τₘ))

  # Weak form
  c(a,u,v) = 0.5*((∇(u)'⋅a)⋅v - u⋅(∇(v)'⋅a))
  res(t,(u,p),(v,q)) = ∫( ∂t(u)⋅v  + c(u,u,v) + ν*(∇(u)⊙∇(v)) - p*(∇⋅v) + (∇⋅u)*q +
                          τₘ*((∇(u)'⋅u - ηₙₕ)⋅(∇(v)'⋅u)) + τc*((∇⋅u)*(∇⋅v)) )dΩ
  jac(t,(u,p),(du,dp),(v,q)) = ∫( c(du,u,v) + c(u,du,v) + ν*(∇(du)⊙∇(v)) - dp*(∇⋅v) + (∇⋅du)*q +
                                  τₘ*((∇(u)'⋅u - ηₙₕ)⋅(∇(v)'⋅du) + (∇(du)'⋅u + ∇(u)'⋅du)⋅(∇(v)'⋅u)) +
                                  τc*((∇⋅du)*(∇⋅v)) )dΩ
  jac_t(t,(u,p),(dut,dpt),(v,q)) = ∫( dut⋅v )dΩ
  op = TransientFEOperator(res,jac,jac_t,X,Y)

  # Orthogonal projection
  a(η,κ) = ∫( τₘ*(η⋅κ) )dΩ
  b(κ) = ∫( τₘ*((∇(uₙₕ)'⋅uₙₕ)⋅κ) )dΩ
  op_proj = AffineFEOperator(a,b,U,V)

  # Transient solver
  xₕ₀ = interpolate([u₀,p₀],X(0.0))
  nls = NLSolver(show_trace=true,method=:newton,iterations=10)
  ode_solver = ThetaMethod(nls,0.001,0.5)

  # Solution (lazy)
  xₕₜ = solve(ode_solver,op,xₕ₀,0,0.002)

  K = Float64[]
  E = Float64[]
  T = Float64[]

  # Iterate over steps
  createpvd(parts,"results/TGV") do pvd
    for (xₕ,t) in xₕₜ
      println("Time: $t")
      uₕ,pₕ=xₕ
      ωₕ = ∇×uₕ
      push!(K,0.5*(∑(∫(uₕ⋅uₕ)dΩ))/(2π^3))
      push!(E,ν*(∑(∫(ωₕ⋅ωₕ)dΩ))/(2π^3))
      push!(T,t)
      uₙₕ = interpolate!(uₕ,fv_u,U(t))
      ηₙₕ = solve(op_proj)
      pvd[t] = createvtk(Ω,"results/TGV_$t";cellfields=["u"=>uₕ,"p"=>pₕ,"eta"=>ηₙₕ,"w"=>ωₕ],nsubcells=10)
    end
 end

 return (T,K,E)
end

end
