using MetaRange
using Documenter

DocMeta.setdocmeta!(MetaRange, :DocTestSetup, :(using MetaRange); recursive=true)

makedocs(;
    modules=[MetaRange],
    authors="janablechschmidt <jana.blechschmidt@uni-wuerzburg.de, rroelz <robin.roelz@gmail.com>",
    repo="https://github.com/janablechschmidt/MetaRange.jl/blob/{commit}{path}#{line}",
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
        "Usage" => "usage.md"
    ],
)

deploydocs(;
    repo="github.com/janablechschmidt/MetaRange.jl",
    devbranch="main",
)
