using MetaRange
using Documenter

DocMeta.setdocmeta!(MetaRange, :DocTestSetup, :(using MetaRange); recursive=true)

makedocs(;
    modules=[MetaRange],
    authors="janablechschmidt <jana.blechschmidt@uni-wuerzburg.de, rroelz <robin.roelz@gmail.com>",
    repo="",
    sitename="MetaRange.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://janablechschmidt.github.io/MetaRange.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Functions" => "functions.md",
        "Parameters" => "parameters.md",
        "Usage" => "usage.md",
        "Instructions for Newbies" => "newbies.md",
        "Development" => "development.md",
    ],
)

deploydocs(; repo="github.com/janablechschmidt/MetaRange.jl", devbranch="main")
