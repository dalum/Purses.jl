# Binary operators
for op in (
    :(Base.:+), :(Base.:*), :(Base.:-), :(Base.:/), :(Base.:\ ), :(Base.:^),
    :(Base.:(==)), :(Base.isapprox), :(Base.isless),
    :(Base.max), :(Base.min),
)
    @eval @inline $op(x::AbstractPurse, y) = $op(value(x), y)
    @eval @inline $op(x, y::AbstractPurse) = $op(x, value(y))
    @eval @inline $op(x::AbstractPurse, y::AbstractPurse) = $op(value(x), value(y))
end
