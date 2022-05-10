module CylinderModel

using GridapGmsh
using Gridap.Io
to_json_file(GmshDiscreteModel("mesh.msh"),"mesh.json")

end
