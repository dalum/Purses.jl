# Unary operators
for op in [
    :(Base.identity),
    :(Base.zero),
    :(Base.one),
    :(Base.oneunit),
    # Basic math operations
    :(Base.:+),
    :(Base.:-),
    :(Base.inv),
    :(Base.sqrt),
    :(Base.cbrt),
    :(Base.log),
    :(Base.exp),
    :(Base.conj),
    # Trigonomotry
    :(Base.cos),
    :(Base.sin),
    :(Base.tan),
    :(Base.cot),
    :(Base.sec),
    :(Base.csc),
    :(Base.cosh),
    :(Base.sinh),
    :(Base.tanh),
    :(Base.coth),
    :(Base.sech),
    :(Base.csch),
    :(Base.acos),
    :(Base.asin),
    :(Base.atan),
    :(Base.acot),
    :(Base.asec),
    :(Base.acsc),
    :(Base.acosh),
    :(Base.asinh),
    :(Base.atanh),
    :(Base.acoth),
    :(Base.asech),
    :(Base.acsch),
    # Iterator operations
    :(Base.sum),
    :(Base.prod),
    :(Base.length),
    :(Base.size),
    :(Base.iterate),
    :(Base.keys),
    :(Base.values),
    :(Base.pairs),
    :(Base.broadcastable),
    :(Base.maximum),
    :(Base.minimum),
    # Linear algebra operations
    :(Base.adjoint),
    :(Base.transpose),
]
    @eval @inline $op(x::MetaAbstractPurse) = $op(value(x))
end

# Binary operators
for op in [
    :(Base.:+),
    :(Base.:*),
    :(Base.:-),
    :(Base.:/),
    :(Base.:\),
    :(Base.:^),
    :(Base.:(==)),
    :(Base.isapprox),
    :(Base.isless),
    :(Base.max),
    :(Base.min),
]
    @eval @inline $op(x::MetaAbstractPurse, y) = $op(value(x), y)
    @eval @inline $op(x, y::MetaAbstractPurse) = $op(x, value(y))
    @eval @inline $op(x::MetaAbstractPurse, y::MetaAbstractPurse) = $op(value(x), value(y))
end

## Extra iteration and indexing

Base.iterate(x::MetaAbstractPurse, i) = Base.iterate(value(x), i)
Base.getindex(x::MetaAbstractPurse, inds...) = Base.getindex(value(x), inds...)
# We specifically do not define behaviour for `Base.setindex!` or other mutating functions,
# since they may invalidate the cache.
function Base.setindex!(::MetaAbstractPurse, ::Any, inds...)
    error("calling a mutating function with a purse is currently unsupported")
end
