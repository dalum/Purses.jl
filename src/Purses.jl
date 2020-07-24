module Purses

export Purse

const _REGISTERED_METHODS = Set()

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
julia> value(Purse(2.0))
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

julia> cache(purse, 1)
-1.0
```
"""
@inline cache(x) = ()
@inline cache(x::Purse) = x.cache
@inline cache(x, i) = nothing
@inline cache(x::Purse, i) = last(x.cache[i])

"""
    register(fs...; max_cache=length(fs))

Register each `f` in `fs` as cacheable and return `fs`.  This works by defining methods of
the type `f(x::Purse{...})` for all `f` in `fs`, and with all permutations of the cache type
parameter, `typeof(f)`, for cache sizes up to `max_cache`.

!!! note
    If `f` is already defined for a given cache size, this method will not redefine it.  It
    is therefore safe to call this method with the same functions multiple times, without
    incurring method redefinitions.

# Examples
```jldoctest
julia> purse = Purse(rand(100), Purses.register(length)...);

julia> length(purse)
100
```
"""
register(fs...; max_cache=length(fs)) = map(f -> _register(f, max_cache), fs)

function _register(f, max_cache)
    for cache_size in 1:max_cache
        expr = _register_impl(f, cache_size)
        eval(expr)
    end
    return f
end

function _register_impl(f::T, cache_size) where {T}
    if cache_size == 0
        T in _REGISTERED_METHODS && return Expr(:block)
        push!(_REGISTERED_METHODS, T)
        return :(@inline (f::$T)(x::AbstractPurse) = f(value(x)))
    end

    defs = Expr(:block)
    for i in 1:cache_size
        parameters = let cache_size = cache_size
            ntuple(cache_size) do j
                i == j ? T : :(<:Any)
            end
        end

        parameters in _REGISTERED_METHODS && continue

        push!(_REGISTERED_METHODS, parameters)
        C = :(AbstractPurse{<:Tuple{$(parameters...)}})
        push!(defs.args, :(@inline (::$T)(x::$C) = cache(x, $i)))
    end
    return defs
end

end # module
