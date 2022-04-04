using DelftBlue
using Documenter

DocMeta.setdocmeta!(DelftBlue, :DocTestSetup, :(using DelftBlue); recursive=true)

makedocs(;
    modules=[DelftBlue],
    authors="Oriol Colomes <oriol.colomes@gmail.com>",
    repo="https://github.com/oriolcg/DelftBlue.jl/blob/{commit}{path}#{line}",
    sitename="DelftBlue.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://oriolcg.github.io/DelftBlue.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/oriolcg/DelftBlue.jl",
    devbranch="main",
)
