for op in (
    :(Base.:+), :(Base.:-), :(Base.:*), :(Base.:/), :(Base.:\),
    :(Base.max), :(Base.min),
)
    @eval @inline $op(x::AbstractPurse, y) = $op(promote(x, y)...)
    @eval @inline $op(x, y::AbstractPurse) = $op(promote(x, y)...)
    @eval @inline $op(x::AbstractPurse, y::AbstractPurse) = $op(promote(x, y)...)
end

for op in (
    :(Base.:+), :(Base.:*), :(Base.max), :(Base.min),
)
    @eval @inline $op(x::AbstractPurse, y, args...) = $op(promote(x, y, args...)...)
    @eval @inline $op(x, y::AbstractPurse, args...) = $op(promote(x, y, args...)...)
    @eval @inline $op(x::AbstractPurse, y::AbstractPurse, args...) = $op(promote(x, y, args...)...)
end
