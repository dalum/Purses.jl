module TestPurses

using Test

using Purses

@testset "Basic functionality" begin
    x = 1.5
    purse = Purse(x)
    @test Purses.value(purse) === x
    @test Purses.cache(purse) === ()
    @test Purses.cache_signature(purse) === Tuple{}

    x = 1.5
    purse = Purse(x, inv, sqrt, cbrt)
    @test Purses.value(purse) === x
    @test Purses.cache(purse) === (inv(x), sqrt(x), cbrt(x))
    @test Purses.cache_signature(purse) === Tuple{typeof(inv), typeof(sqrt), typeof(cbrt)}
    @test inv(purse) === inv(x)
    @test sqrt(purse) === sqrt(x)
    @test cbrt(purse) === cbrt(x)

    x = 1.5
    y = 2.0
    purse = Purse(x, inv, sqrt => y, cbrt)
    @test Purses.value(purse) == x
    @test sqrt(purse) != sqrt(x)
    @test sqrt(purse) == y
end

@testset "Function registration" begin
    my_inc(x) = x + 1

    @test Purses.register!(my_inc) == (my_inc,)
    @test typeof(my_inc) in Purses._REGISTERED_FUNCTIONS

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
