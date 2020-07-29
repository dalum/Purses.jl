# Purses.jl 👛

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://dalum.github.io/Purses.jl/dev)
[![Build Status](https://travis-ci.org/dalum/Purses.jl.svg?branch=master)](https://travis-ci.org/dalum/Purses.jl)
[![codecov](https://codecov.io/gh/dalum/Purses.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/dalum/Purses.jl)

This package provides a simple and extensible type for wrapping a value that carries a small cache around with it—a purse.  The cache is stored internally as a tuple, and the functions used for caching the entries are saved as a type parameter.  This allows specialising on the function to retrieve the cached value using compile-time constants for indexing into the cache.  Note that the default implementation, `Purse`, is assumed to be immutable.  Mutations of a wrapped mutable object is explicitly unsupported at this moment.

# Usage

To cache the result of calling `sum`, `inv∘sum`, and `sqrt∘sum` on a value, we can create a `Purse` as follows:
```julia
julia> using Purses

julia> value = rand(10000);

julia> purse = Purse(value, sum, inv∘sum, sqrt∘sum);

```
This will define methods for `sum`, `inv∘sum`, and `sqrt∘sum` for `AbstractPurse` types.  If the purse has a cached value of one of the registered functions, it will retrieve this result instead of computing it.  The effect of this kind of caching can be quite significant, if the cached value is expensive to compute:
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
Note, however, in order to take advantage of this, the type of the purse must be inferable at the call site.  In other words, the type of the purse must be known at compile time, otherwise Julia will have to use dynamic dispatch to retrieve the value.  This can often lead to orders of magnitudes in loss of performance.
