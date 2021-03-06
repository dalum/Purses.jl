"""
    MetaAbstractPurse{T}

Supertype for abstract purses.  This type should be used when defining fallback methods of
functions for purses that unwrap the value and does not make use of the cache.
"""
abstract type MetaAbstractPurse{T} end

"""
    AbstractPurse{T,F<:Tuple}

Supertype for purses (or purse-like types) wrapping a value of type `T` and caching
functions of types `F`.  To create a subtype which conforms to the AbstractPurse interface,
[`value`](@ref) and [`cache`](@ref) must be implemented.
"""
abstract type AbstractPurse{T,F<:Tuple} <: MetaAbstractPurse{T} end

Base.convert(::Type{Any}, x::T) where {T<:AbstractPurse} = x
Base.convert(::Type{T}, x::T) where {T<:AbstractPurse} = x
Base.convert(::Type{T}, x::AbstractPurse) where {T} = convert(T, value(x))
Base.convert(::Type{T}, x) where {T<:AbstractPurse} = T(x)
Base.convert(::Type{T}, x::AbstractPurse) where {T<:AbstractPurse} = T(value(x))

cache_signature(::Type{<:AbstractPurse{<:Any,F}}) where {F} = F

"""
    Purse{T,F<:Tuple,S<:Tuple}

Purse with a value and cache.

# Fields
- `value::T`: the value stored in the purse
- `cache::S`: the cached values stored as a tuple in the same order as `F`
"""
struct Purse{T,F<:Tuple,S<:Tuple} <: AbstractPurse{T,F}
    value::T
    cache::S
end

"""
    Purse(value, fs...)

Return `value` wrapped in a `Purse`.  Each `f` in `fs` can be either a callable or a pair a
callable and a value.  If `f` is a callable, the cache will automatically be calculated by
applying each `f` to `value`.  If `f` is a pair, the cache for the first element of the pair
is set to the value of the second element.

# Examples
```jldoctest
julia> Purse(1.0)
Purse{Float64,Tuple{},Tuple{}}(1.0, ())

julia> Purse(2, inv)
Purse{Int64,Tuple{typeof(inv)},Tuple{Float64}}(2, (0.5,))

julia> Purse(2, inv => 0.2)
Purse{Int64,Tuple{typeof(inv)},Tuple{Float64}}(2, (0.2,))
```
"""
function Purse(value, fs...)
    Fs = map(f -> _register!(f isa Pair ? first(f) : f), fs)
    cache = map(f -> f isa Pair ? last(f) : f(value), fs)
    return Purse(value, Fs, cache)
end

Purse{T,F}(value) where {T,F<:Tuple} = Purse{T}(value, map(f -> _register!(f.instance), F.parameters)...)
Purse{T}(value, fs...) where {T} = Purse(convert(T, value), fs...)
Purse(value::T, ::F, cache::S) where {T,F<:Tuple,S<:Tuple} = Purse{T,F,S}(value, cache)

function Purse{T,F,S}(value) where {T,F<:Tuple,S<:Tuple}
    self = Purse{T}(value, map(f -> _register!(f.instance), F.parameters)...)
    return Purse{T,F,S}(self.value, convert(S, self.cache))
end

"""
    value(x)

If `x` is a purse, return its stored value, otherwise return x itself.

# Examples
```jldoctest
julia> Purses.value(Purse(2.0))
2.0
```
"""
@inline value(x) = x
@inline value(x::Purse) = x.value

"""
    cache(x[, idx])

Return the cache associated with the purse `x`.  If the optional argument `idx` is supplied,
return the cache item stored at index `idx`.

# Examples
```jldoctest
julia> purse = Purse(1.0, -);

julia> Purses.cache(purse, 1)
-1.0
```
"""
@inline cache(x::Purse) = x.cache
@inline cache(x, idx) = cache(x)[idx]
