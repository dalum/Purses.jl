module TestPurses

using Test

using Purses

@testset "Basic functionality" begin
    x = 1.5
    purse = Purse(x)
    @test Purses.value(purse) === Purses.value(x) === x
    @test Purses.cache(purse) === Purses.cache(x) === ()
    @test_throws BoundsError Purses.cache(purse, 1)
    @test_throws BoundsError Purses.cache(x, 1)
    @test Purses.cache_signature(purse) === Tuple{}

    x = 1.5
    purse = Purse(x, inv, sqrt, cbrt)
    @test Purses.value(purse) === x
    @test Purses.cache(purse) === (inv(x), sqrt(x), cbrt(x))
    @test Purses.cache_signature(purse) === Tuple{typeof(inv), typeof(sqrt), typeof(cbrt)}
    @test inv(purse) === inv(x)
    @test sqrt(purse) === sqrt(x)
    @test cbrt(purse) === cbrt(x)
    @test sin(purse) === sin(x)

    x = 1.5
    y = 2.0
    purse = Purse(x, inv, sqrt => y, cbrt)
    @test Purses.value(purse) == x
    @test sqrt(purse) != sqrt(x)
    @test sqrt(purse) == y
end

@testset "Conversion" begin
    x = 1.5
    y = 1.0
    purse = Purse(x)
    @test convert(typeof(purse), purse) === purse
    @test convert(Any, purse) === purse
    @test convert(Float64, purse) === x
    @test convert(Purse{Float32}, purse) === Purse(Float32(x))
    @test convert(Purse{typeof(x),Tuple{typeof(+)}}, purse) === convert(Purse{typeof(x),Tuple{typeof(+)}}, x) === Purse(x, +)

    @test Purse{Float64,Tuple{typeof(-)},Tuple{Float64}}(x) === Purse(x, -)
    @test_throws InexactError Purse{Float64,Tuple{typeof(-)},Tuple{Int64}}(x)
    @test Purses.cache(Purse{Float64,Tuple{typeof(-)},Tuple{Int64}}(y), 1) isa Int64

    purses = Purse{Float64,Tuple{typeof(-)},Tuple{Float64}}[1.0, 2.0, 8.5]
    @test purses == map(x -> Purse(x, -), [1.0, 2.0, 8.5])
end

@testset "Function registration" begin
    my_inc(x) = x + 1

    @test Purses.register!(my_inc) == (my_inc,)

    x = 1.5
    purse = Purse(x, my_inc)
    @test Purses.cache_signature(purse) === Tuple{typeof(my_inc)}
    @test my_inc(purse) === my_inc(x)

    x = 1.5
    y = 2.0
    purse = Purse(x, my_inc => y)
    @test my_inc(purse) !== my_inc(x)
    @test my_inc(purse) === y
end

@testset "Math" begin
    x = 1.5
    y = 2.0
    z = 0.5
    purse = Purse(x)

    @test purse + 1 == x + 1
    @test purse - 1 == x - 1
    @test 2*purse == 2*x
    @test purse*2im == x*2im
    @test 2/purse == 2/x
    @test purse/2 == x/2
    @test purse\2 == x\2
    @test 2\purse == 2\x
    @test purse^4 == x^4
    @test purse == x
    @test purse ≈ x
    @test purse < y
    @test purse > z
    @test min(purse, y) == purse == x == min(x, y)
    @test min(purse, y, z) == z == min(x, y, z)
    @test max(purse, z) == purse == x == max(x, z)
    @test max(purse, y, z) == y == max(x, y, z)

    @test purse + purse == x + x == 2*purse == 2*x
    @test purse + purse + purse == x + x + x == 3*purse == 3*x
end

end # module
