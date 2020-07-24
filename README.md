# Purses.jl 👛

This package provides a simple and extensible type for wrapping a value that carries a small cache around with it—a purse.  The cache is stored internally as a tuple, and the function for caching the entries are saved as a type parameter.  This allows specialising on the function to retrieve the cached value using compile-time constants for indexing into the cache.

# Usage

To cache the result of calling `sum`, `inv∘sum`, and `sqrt∘sum` on a value, we can create a `Purse` as follows:
```julia
julia> using Purses

julia> value = rand(10000);

julia> purse = Purse(value, sum, inv∘sum, sqrt∘sum);

```
This will define methods for `sum`, `inv∘sum`, and `sqrt∘sum` for `AbstractPurse` types.  If the purse has a cached valued of one of the registered functions, it will retrieve the cached value instead of computing it.  The effect of this kind of caching can be quite significant, if the cached value is expensive to compute:
```julia
julia> using BenchmarkTools

julia> @btime sum($(Ref(value))[])
  901.703 ns (0 allocations: 0 bytes)
5068.117658322436

julia> @btime sum($(Ref(purse))[])
  1.248 ns (0 allocations: 0 bytes)
5068.117658322436

julia> @btime (inv∘sum)($(Ref(value))[])
  905.658 ns (0 allocations: 0 bytes)
0.00019731191487985371

julia> @btime (inv∘sum)($(Ref(purse))[])
  1.248 ns (0 allocations: 0 bytes)
0.00019731191487985371

julia> @btime (sqrt∘sum)($(Ref(value))[])
  905.684 ns (0 allocations: 0 bytes)
71.19071328707443

julia> @btime (sqrt∘sum)($(Ref(purse))[])
  1.250 ns (0 allocations: 0 bytes)
71.19071328707443
```

# Registering functions

To be able to use the cached result of a function, the function must first be registered.  In the example above, `sum`, `inv∘sum`, and `sqrt∘sum` were already registered.  However, if we want to cache the result of a custom function, `Purses` provides a `register!` function, which automatically generates an optimized cache retrieval method for `AbstractPurse`.
```julia
julia> my_inc(x) = x + 1

julia> Purses.register!(my_inc)
(my_inc,)

julia> purse = Purse(1.0, my_inc)
Purse{Float64,Tuple{typeof(my_inc)},Tuple{Float64}}(1.0, (2.0,))

julia> my_inc(purse)
2.0
```
