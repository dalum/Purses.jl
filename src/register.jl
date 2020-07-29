"""
    register!(fs...)

Register each `f` in `fs` as cacheable and return `fs`.  If `f` is already registered,
`register!` will not redefine it.  It is therefore safe to call `register!` with the same
functions multiple times, without the risk of method redefinitions.

!!! note
    When a `Purse` is created, it automatically registers all functions used in its cache.
    Manually calling `register!` should thus not generally be required.

!!! note
    To avoid overhead, implementations of `AbstractPurse` should use `Purses._register!(f)`
    instead of `register!` to register individual functions.

# Examples
```jldoctest
julia> purse = Purse(rand(100), Purses.register!(length)...);

julia> length(purse)
100
```
"""
function register!(fs...; force=false)
    if force
        return map(f -> invoke(_register!, Tuple{Any}, f), fs)
    else
        return map(f -> _register!(f), fs)
    end
end

function _register!(f::T) where {T}
    # Because we rely on `T` to know which function is in the cache, we cannot allow
    # registering non-singleton types, as we would not be able to know which instance of the
    # function is referred to in the cache, without incurring overhead by checking for
    # instance equality.  This would also require the purse to carry the function instance
    # around with it, which would leave a larger memory footprint.
    Base.issingletontype(T) || error("cannot register method for non-singleton type: $T")

    @eval begin
        # Overload registration of the function `f` to be a no-op.
        @inline _register!(f::$T) = f
        # Overload calling `f` with a purse for fast cache retrieval.
        @generated function (f::$T)(x::AbstractPurse)
            # Find the index of the function we have registered in the cache.  Note that
            # since this is a generated function, `x` here refers to the type of `x`.
            for (idx, t) in enumerate(cache_signature(x).parameters)
                t == $T && return quote
                    @_inline_meta
                    cache(x, $idx)
                end
            end
            # The function was not found in the cache, so we compute it instead.
            return quote
                @_inline_meta
                invoke(f, Tuple{MetaAbstractPurse}, x)
            end
        end
    end

    return f
end
