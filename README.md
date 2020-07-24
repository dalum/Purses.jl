# Purses.jl 👛

This package provides a simple and extensible type for wrapping a value that carries a small cache around with it—a purse.  The cache is stored internally as a tuple, and the function for caching the entries are saved as a type parameter.  This trick allows specialising on the function to retrieve the cached value using compile-time constants for indexing into the cache.

# Usage

To cache the result of calling `sum`, `inv∘sum`, and `sqrt∘sum` on a value, we can create a `Purse` as follows:
```julia
julia> using Purses

julia> val = rand(10000);

julia> purse = Purse(val, sum, inv∘sum, sqrt∘sum);

```
To use the cache result of a function, the function must first be registered:
```julia
julia> Purses.register(sum, inv∘sum, sqrt∘sum; max_cache=3);

```
This will define methods for `sum`, `inv∘sum`, and `sqrt∘sum` for all permutations of caches with up to 3 cached items.  The effect of this kind of caching can be quite significant, if the cached value is expensive to compute:
```julia
julia> using BenchmarkTools

julia> @btime sum($(Ref(val))[])
  913.351 ns (0 allocations: 0 bytes)
5006.181801631625

julia> @btime sum($(Ref(purse))[])
  1.240 ns (0 allocations: 0 bytes)
5006.181801631625

julia> @btime (inv∘sum)($(Ref(val))[])
  914.000 ns (0 allocations: 0 bytes)
0.00019975303327459624

julia> @btime (inv∘sum)($(Ref(purse))[])
  1.239 ns (0 allocations: 0 bytes)
0.00019975303327459624

julia> @btime (sqrt∘sum)($(Ref(val))[])
  916.853 ns (0 allocations: 0 bytes)
70.75437655461056

julia> @btime (sqrt∘sum)($(Ref(purse))[])
  1.241 ns (0 allocations: 0 bytes)
70.75437655461056
```
