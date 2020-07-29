module TestPursesOperators

using Test

using Purses: Purse, value

@testset "Unary operators" begin
    x = Purse(1.0)

    for op in [
        Base.identity,
        Base.zero,
        Base.one,
        Base.oneunit,
        # Basic math operations
        Base.:+,
        Base.:-,
        Base.inv,
        Base.sqrt,
        Base.cbrt,
        Base.log,
        Base.exp,
        Base.conj,
        # Trigonomotry
        Base.cos,
        Base.sin,
        Base.tan,
        Base.cot,
        Base.sec,
        Base.csc,
        Base.cosh,
        Base.sinh,
        Base.tanh,
        Base.coth,
        Base.sech,
        Base.csch,
        Base.acos,
        Base.asin,
        Base.atan,
        Base.acot,
        Base.asec,
        Base.acsc,
        Base.acosh,
        Base.asinh,
        Base.atanh,
        Base.acoth,
        Base.asech,
        Base.acsch,
        # Iterator operations
        Base.sum,
        Base.prod,
        Base.length,
        Base.size,
        Base.iterate,
        Base.keys,
        Base.values,
        Base.pairs,
        Base.broadcastable,
        Base.maximum,
        Base.minimum,
        # Linear algebra operations
        Base.adjoint,
        Base.transpose,
    ]
        @test op(x) == op(value(x))
    end
end

@testset "Binary operators" begin
    x = Purse(1.0)

    for op in [
        Base.:+,
        Base.:*,
        Base.:-,
        Base.:/,
        Base.:\,
        Base.:^,
        Base.:(==),
        Base.isapprox,
        Base.isless,
        Base.max,
        Base.min,
    ]
        @test op(x, x) == op(x, value(x)) == op(value(x), x) == op(value(x), value(x))
    end
end

@testset "Iteration protocol" begin
    purse = Purse(1:5, sum)
    @test map(x -> x^2, purse) == map(x -> x^2, value(purse))

    @test iterate(purse) === (1, 1)
    @test iterate(purse, 1) === (2, 2)
    @test iterate(purse, 5) === nothing

    for idx in eachindex(purse)
        @test purse[idx] == value(purse)[idx]
    end

    for (x1, x2) in zip(purse, value(purse))
        @test x1 == x2
    end

    collected_purse = Purse(collect(purse), sum)
    @test_throws ErrorException purse[1] = 2
end

end # module
