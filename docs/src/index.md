Welcome to the documentation for Purses.jl!

This document is intended to help you get started with using the package. If you have any suggestions, please open an issue or pull request on GitHub.

## Introduction

Purses.jl provides a type for wrapping a value that carries a small pre-computed cache around with it.  This kind of wrapped value is here referred to as a purse, and Purses.jl exports a single implementation of it called `Purse`.  A purse effectively functions as a named tuple or a struct, except field access is automatically tied to a specific function call.  That is, a purse of a number with a cached value of the square root of that number will automatically retrieve the cached value, when `sqrt` is called with the purse as argument.  In addition, basic arithmetic operations have been overloaded to automatically unwrap purses which allows them to be used in equations.

The cache in `Purse` is stored as a tuple, and the function for caching the entries are saved as a type parameter.  This allows specialising on the function to retrieve the cached value using compile-time constants for indexing into the cache.  To achieve this functionality, `@generated` methods are used for cacheable functions.  This can put a lot of pressure on the compiler, if many types of purses are used, since it has to compile a new method for every type.  In most usage, however, this should not be an issue.
