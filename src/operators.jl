@inline (purse::MetaAbstractPurse)(xs...) = value(purse)(xs...)

# Unary operators
for op in [
    :(Base.complex),
    :(Base.float),
    # Elements
    :(Base.one),
    :(Base.oneunit),
    :(Base.zero),
    # Basic math operations
    :(Base.:(==)),
    :(Base.:*),
    :(Base.:+),
    :(Base.:-),
    :(Base.:/),
    :(Base.:\),
    :(Base.:^),
    :(Base.cbrt),
    :(Base.conj),
    :(Base.exp),
    :(Base.inv),
    :(Base.isapprox),
    :(Base.isless),
    :(Base.log),
    :(Base.max),
    :(Base.min),
    :(Base.sqrt),
    # Trigonomotry
    :(Base.acos),
    :(Base.acosh),
    :(Base.acot),
    :(Base.acoth),
    :(Base.acsc),
    :(Base.acsch),
    :(Base.asec),
    :(Base.asech),
    :(Base.asin),
    :(Base.asinh),
    :(Base.atan),
    :(Base.atanh),
    :(Base.cos),
    :(Base.cosh),
    :(Base.cot),
    :(Base.coth),
    :(Base.csc),
    :(Base.csch),
    :(Base.sec),
    :(Base.sech),
    :(Base.sin),
    :(Base.sinh),
    :(Base.tan),
    :(Base.tanh),
    # Iterator operations
    :(Base.broadcastable),
    :(Base.firstindex),
    :(Base.getindex),
    :(Base.iterate),
    :(Base.keys),
    :(Base.lastindex),
    :(Base.length),
    :(Base.pairs),
    :(Base.size),
    :(Base.values),
    # Linear algebra operations
    :(Base.adjoint),
    :(Base.transpose),
]
    @eval @inline $op(x::MetaAbstractPurse, ys...) = $op(value(x), map(value, ys)...)
    @eval @inline $op(x, y::MetaAbstractPurse, zs...) = $op(x, value(y), map(value, zs)...)
    @eval @inline function $op(x::MetaAbstractPurse, y::MetaAbstractPurse, zs...)
        return $op(value(x), value(y), map(value, zs)...)
    end
end

# We specifically do not define behaviour for `Base.setindex!` or other mutating functions,
# since they may invalidate the cache.
function Base.setindex!(::MetaAbstractPurse, ::Any, inds...)
    error("calling a mutating function with a purse is currently unsupported")
end
