module Purses

export Purse

const _REGISTERED_FUNCTIONS = Set()

"""
    AbstractPurse{F<:Tuple}

Supertype for purses (or purse-like types) with caches of function types `F`.  To create a
subtype which conforms to the AbstractPurse interface, [`value`](@ref) and [`cache`](@ref)
must be implemented.
"""
abstract type AbstractPurse{F<:Tuple} end

struct Purse{T,F,S<:Tuple} <: AbstractPurse{F}
    value::T
    cache::S
end

"""
    Purse(value, fs...)

Return `value` wrapped in a `Purse`.  Each `f` in `fs` can be either a callable or a pair a
callable and a value.  If `f` is a callable, the cache will automatically be calculated by
applying each `f` to `value`.  If `f` is a pair, the cache for the first element of the pair
is set to the value of the second element.  If no `fs` are provided, the cache will be set
to an empty tuple.

# Examples
```jldoctest
julia> Purse(1.0)
Purse{Float64,Tuple{},Tuple{}}(1.0, ())

julia> Purse(2, inv)
Purse{Int64,Tuple{typeof(inv)},Tuple{Float64}}(2, (0.5,))
```
"""
function Purse(value, fs...)
    Fs = map(f -> f isa Pair ? first(f) : f, fs)
    cache = map(f -> f isa Pair ? last(f) : f(value), fs)
    return Purse(value, Fs, cache)
end

Purse(value::T, ::F, cache::S) where {T,F<:Tuple,S<:Tuple} = Purse{T,F,S}(value, cache)

"""
    value(x)

If `x` is a `Purse`, return its value field, otherwise return x itself.

# Examples
```jldoctest
julia> Purses.value(Purse(2.0))
2.0
```
"""
@inline value(x) = x
@inline value(x::Purse) = x.value

"""
    cache(x[, i])

If `x` is a `Purse`, return its cache field, otherwise return an empty tuple.  If the
optional argument `i` is supplied, return the `i`th stored cache item.

# Examples
```jldoctest
julia> purse = Purse(1.0, -);

julia> Purses.cache(purse, 1)
-1.0
```
"""
@inline cache(x) = ()
@inline cache(x::Purse) = x.cache
@inline cache(x, i) = nothing
@inline cache(x::Purse, i) = last(x.cache[i])

"""
    register(fs...)

Register each `f` in `fs` as cacheable and return `fs`.

!!! note
    If `f` is already registered, `register` will not redefine it.  It is therefore safe to
    call `register` with the same functions multiple times, without the risk of method
    redefinitions.  However, the methods for `f` are `@generated` functions.  If several
    different types of purses are used, the method table will grow significantly.  This may
    incur a significant performance impact on the compiler.

# Examples
```jldoctest
julia> purse = Purse(rand(100), Purses.register(length)...);

julia> length(purse)
100
```
"""
register(fs...) = map(_register, fs)

function _register(f)
    expr = _register_impl(f)
    eval(expr)
    return f
end

function _register_impl(::T) where {T}
    T in _REGISTERED_FUNCTIONS && return Expr(:block)
    push!(_REGISTERED_FUNCTIONS, T)
    return quote
        function (f::$T)(x::AbstractPurse{F}) where {F}
            if @generated
                for (idx, t) in enumerate(F.parameters)
                    t == $T && return :(cache(x, $idx))
                end
                return :(f(value(x)))
            else
                for (idx, t) in enumerate(F.parameters)
                    t == $T && return cache(x, idx)
                end
                return f(value(x))
            end
        end
    end
end

# Guard against nonsensical registrations.
function _register_impl(::T) where {T<:Union{Type,DataType,UnionAll}}
    return error("cannot register method for $T")
end

end # module
