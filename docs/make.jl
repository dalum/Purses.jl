using Documenter
push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))
using Purses

DocMeta.setdocmeta!(Purses, :DocTestSetup, :(using Purses); recursive=true)
makedocs(
    sitename = "Purses.jl 👛",
    modules = [Purses],
    pages = [
        "index.md",
        "api.md",
    ],
)

deploydocs(
    repo = "github.com/dalum/Purses.jl.git",
)
