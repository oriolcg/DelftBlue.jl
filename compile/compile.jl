using PackageCompiler
create_sysimage(:DelftBlue,
  sysimage_path=joinpath(@__DIR__,"..","DelftBlue.so"),
  precompile_execution_file=joinpath(@__DIR__,"warmup.jl"))
