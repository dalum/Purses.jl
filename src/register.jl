"""
    register!(fs...)

Register each `f` in `fs` as cacheable and return `fs`.

!!! note
    If `f` is already registered, `register` will not redefine it.  It is therefore safe to
    call `register` with the same functions multiple times, without the risk of method
    redefinitions.

# Examples
```jldoctest
julia> purse = Purse(rand(100), Purses.register!(length)...);

julia> length(purse)
100
```
"""
register!(fs...; force=false) = map(f -> _register!(f; force=force), fs)

function _register!(f; force=false)
    expr = _register_impl!(f; force=force)
    eval(expr)
    return f
end

function _register_impl!(::T; force=false) where {T}
    # Because we rely on `T` to know which function is in the cache, we cannot allow
    # registering non-singleton types, as we would not be able to know which instance of the
    # function is referred to in the cache, without incurring overhead by checking for
    # instance equality.  This would also require the purse to carry the function instance
    # around with it, which would leave a larger memory footprint.
    Base.issingletontype(T) || error("cannot register method for non-singleton type: $T")
    # Return an empty code block to be evaluated, if the function is already registered,
    # unless force is set.
    T in _REGISTERED_FUNCTIONS && (force || return Expr(:block))
    # Register the function, and return a code block with an optimized generated function
    # for cache retrieval.
    push!(_REGISTERED_FUNCTIONS, T)
    return quote
        function (f::$T)(x::AbstractPurse)
            if @generated
                # Find the index of the function we have registered in the cache.
                for (idx, t) in enumerate(cache_signature(x).parameters)
                    t == $T && return :(cache(x, $idx))
                end
                # The function was not found in the cache, so we compute it instead.
                return :(f(value(x)))
            else
                for (idx, t) in enumerate(cache_signature(x).parameters)
                    t == $T && return cache(x, idx)
                end
                return f(value(x))
            end
        end
    end
end
