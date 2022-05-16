function run_Cylinder(parts,order::Int,dt::Real,tf::Real,mesh_file::String)

  # Parameters
  D = 0.1
  Re = 100
  ν = D/Re
  Uₘ = 1.5
  H = 0.41

  # TGV initial solution
  uin((x,y,z),t) = VectorValue(4*Uₘ*y*(H-y)/(H^2),0,0)
  u₀((x,y,z),t) = VectorValue(0,0,0)
  uin(t) = x->uin(x,t)
  u₀(t) = x->u₀(x,t)

  # Discretization
  models_path=ENV["DELFTBLUE_MODELS"]
  meshfile = joinpath(models_path,mesh_file)
  𝒯 = GmshDiscreteModel(parts,meshfile)

  # Triangulation and Integration measure
  Ω = Interior(𝒯)
  dΩ = Measure(Ω,2*order)
  Γ = Boundary(𝒯,tags=["sides"])
  dΓ = Measure(Γ,2*order)
  nΓ = get_normal_vector(Γ)

  # FE spaces
  refFEᵤ = ReferenceFE(lagrangian,VectorValue{3,Float64},order)
  refFEₚ = ReferenceFE(lagrangian,Float64,order-1)
  V = TestFESpace(𝒯,refFEᵤ,dirichlet_tags=["inlet","cylinder"])
  Q = TestFESpace(𝒯,refFEₚ)
  U = TransientTrialFESpace(V,[uin,u₀])
  P = TrialFESpace(Q)
  Y = MultiFieldFESpace([V,Q])
  X = TransientMultiFieldFESpace([U,P])

  # Explicit FE functions
  global ηₙₕ = interpolate_everywhere(VectorValue(0.0,0.0,0.0),U(0.0))
  global uₙₕ = interpolate_everywhere(u₀(0.0),U(0.0))
  global fv_u = zero_free_values(U(0.0))

  # Stabilization Parameters
  c₁ = 12.0
  c₂ = 2.0
  cc = 4.0

  # h = map_parts(Ω.trians) do trian
  #   lazy_map(h->h^(1/3),get_cell_measure(trian))
  # end
  h = 0.01
  τₘ = 1/(c₁*ν/h^2 + c₂*(meas∘uₙₕ)/h)
  τc = cc *(h^2/(c₁*τₘ))
  κ = 10.0*order*(order-1)/h

  # Weak form
  c(a,u,v) = 0.5*((∇(u)'⋅a)⋅v - u⋅(∇(v)'⋅a))
  res(t,(u,p),(v,q)) = ∫( ∂t(u)⋅v  + c(u,u,v) + ν*(∇(u)⊙∇(v)) - p*(∇⋅v) + (∇⋅u)*q +
                          τₘ*((∇(u)'⋅u - ηₙₕ)⋅(∇(v)'⋅u)) + τc*((∇⋅u)*(∇⋅v)) )dΩ +
                       ∫( - ((ν*(∇(u)⋅nΓ) - p*nΓ)⋅nΓ) ⋅ (v⋅nΓ) - ((ν*(∇(v)⋅nΓ) - q*nΓ)⋅nΓ) ⋅ (u⋅nΓ) + κ*(u⋅nΓ)*(v⋅nΓ) )dΓ
  jac(t,(u,p),(du,dp),(v,q)) = ∫( c(du,u,v) + c(u,du,v) + ν*(∇(du)⊙∇(v)) - dp*(∇⋅v) + (∇⋅du)*q +
                                  τₘ*((∇(u)'⋅u - ηₙₕ)⋅(∇(v)'⋅du) + (∇(du)'⋅u + ∇(u)'⋅du)⋅(∇(v)'⋅u)) +
                                  τc*((∇⋅du)*(∇⋅v)) )dΩ+
                               ∫( - ((ν*(∇(du)⋅nΓ) - dp*nΓ)⋅nΓ) ⋅ (v⋅nΓ) - ((ν*(∇(v)⋅nΓ) - q*nΓ)⋅nΓ) ⋅ (du⋅nΓ) + κ*(du⋅nΓ)*(v⋅nΓ) )dΓ
  jac_t(t,(u,p),(dut,dpt),(v,q)) = ∫( dut⋅v )dΩ
  op = TransientFEOperator(res,jac,jac_t,X,Y)

  # Stokes Weake form
  a₀((u,p),(v,q)) = ∫( ν*(∇(u)⊙∇(v)) - p*(∇⋅v) + (∇⋅u)*q )dΩ +
                    ∫( - ((ν*(∇(u)⋅nΓ) - p*nΓ)⋅nΓ) ⋅ (v⋅nΓ) - ((ν*(∇(v)⋅nΓ) - q*nΓ)⋅nΓ) ⋅ (u⋅nΓ) + κ*(u⋅nΓ)*(v⋅nΓ) )dΓ
  l₀((v,q)) =  ∫( 0.0*q )dΩ
  op₀ = AffineFEOperator(a₀,l₀,X(0.0),Y)

  # Orthogonal projection
  a(η,κ) = ∫( τₘ*(η⋅κ) )dΩ
  b(κ) = ∫( τₘ*((∇(uₙₕ)'⋅uₙₕ)⋅κ) )dΩ
  op_proj(t) = AffineFEOperator(a,b,U(t),V)

  # Linear Solver
  ls = LUSolver()#PETScLinearSolver()

  # Nonlinear Solver
  nls = NLSolver(ls,show_trace=true,method=:newton,iterations=10)
  #nls = PETScNonlinearSolver()

  # Transient solver
  ode_solver = GeneralizedAlpha(nls,dt,0.0)

  # Initial solution
  xₕ₀ = solve(ls,op₀)
  #vₕ₀ = interpolate_everywhere([VectorValue(0.0,0.0,0.0),0.0],X(0.0))
  du₀ = interpolate_everywhere(VectorValue(0.0,0.0,0.0),U(0.0))
  dp₀ = interpolate_everywhere(0.0,P)
  vₕ₀ = interpolate_everywhere([du₀,dp₀],X(0.0))

  # Solution (lazy)
  xₕₜ = solve(ode_solver,op,(xₕ₀,vₕ₀),0,tf)

  # Iterate over steps
  createpvd(parts,"results/Cylinter") do pvd
    for (xₕ,t) in xₕₜ
      println("--------------------")
      println("Start of time: $t")
      uₕ,pₕ=xₕ
      println("updating global variables")
      uₙₕ = interpolate!(uₕ,fv_u,U(t))
      ηₙₕ = solve(ls,op_proj(t))
      pvd[t] = createvtk(Ω,"results/Cylinder_$t";cellfields=["u"=>uₕ,"p"=>pₕ,"eta"=>ηₙₕ],nsubcells=10)
      println("End of time: $t")
    end
 end

end
