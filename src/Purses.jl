module Purses

export Purse

const _REGISTERED_FUNCTIONS = Set()

include("purse.jl")
include("register.jl")
include("registered_functions.jl")
include("math.jl")

end # module
