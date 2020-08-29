var documenterSearchIndex = {"docs":
[{"location":"api/#API-Reference","page":"API Reference","title":"API Reference","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"Modules = [Purses]\nOrder = [:function, :type]","category":"page"},{"location":"api/#Purses.cache-Tuple{Purse}","page":"API Reference","title":"Purses.cache","text":"cache(x[, idx])\n\nReturn the cache associated with the purse x.  If the optional argument idx is supplied, return the cache item stored at index idx.\n\nExamples\n\njulia> purse = Purse(1.0, -);\n\njulia> Purses.cache(purse, 1)\n-1.0\n\n\n\n\n\n","category":"method"},{"location":"api/#Purses.register!-Tuple","page":"API Reference","title":"Purses.register!","text":"register!(fs...)\n\nRegister each f in fs as cacheable and return fs.  If f is already registered, register! will not redefine it.  It is therefore safe to call register! with the same functions multiple times, without the risk of method redefinitions.\n\nnote: Note\nWhen a Purse is created, it automatically registers all functions used in its cache. Manually calling register! should thus not generally be required.\n\nnote: Note\nTo avoid overhead, implementations of AbstractPurse should use Purses._register!(f) instead of register! to register individual functions.\n\nExamples\n\njulia> purse = Purse(rand(100), Purses.register!(length)...);\n\njulia> length(purse)\n100\n\n\n\n\n\n","category":"method"},{"location":"api/#Purses.value-Tuple{Any}","page":"API Reference","title":"Purses.value","text":"value(x)\n\nIf x is a purse, return its stored value, otherwise return x itself.\n\nExamples\n\njulia> Purses.value(Purse(2.0))\n2.0\n\n\n\n\n\n","category":"method"},{"location":"api/#Purses.AbstractPurse","page":"API Reference","title":"Purses.AbstractPurse","text":"AbstractPurse{T,F<:Tuple}\n\nSupertype for purses (or purse-like types) wrapping a value of type T and caching functions of types F.  To create a subtype which conforms to the AbstractPurse interface, value and cache must be implemented.\n\n\n\n\n\n","category":"type"},{"location":"api/#Purses.MetaAbstractPurse","page":"API Reference","title":"Purses.MetaAbstractPurse","text":"MetaAbstractPurse{T}\n\nSupertype for abstract purses.  This type should be used when defining fallback methods of functions for purses that unwrap the value and does not make use of the cache.\n\n\n\n\n\n","category":"type"},{"location":"api/#Purses.Purse","page":"API Reference","title":"Purses.Purse","text":"Purse{T,F<:Tuple,S<:Tuple}\n\nPurse with a value and cache.\n\nFields\n\nvalue::T: the value stored in the purse\ncache::S: the cached values stored as a tuple in the same order as F\n\n\n\n\n\n","category":"type"},{"location":"api/#Purses.Purse-Tuple{Any,Vararg{Any,N} where N}","page":"API Reference","title":"Purses.Purse","text":"Purse(value, fs...)\n\nReturn value wrapped in a Purse.  Each f in fs can be either a callable or a pair a callable and a value.  If f is a callable, the cache will automatically be calculated by applying each f to value.  If f is a pair, the cache for the first element of the pair is set to the value of the second element.\n\nExamples\n\njulia> Purse(1.0)\nPurse{Float64,Tuple{},Tuple{}}(1.0, ())\n\njulia> Purse(2, inv)\nPurse{Int64,Tuple{typeof(inv)},Tuple{Float64}}(2, (0.5,))\n\njulia> Purse(2, inv => 0.2)\nPurse{Int64,Tuple{typeof(inv)},Tuple{Float64}}(2, (0.2,))\n\n\n\n\n\n","category":"method"},{"location":"introduction/#Introduction","page":"Introduction","title":"Introduction","text":"","category":"section"},{"location":"introduction/","page":"Introduction","title":"Introduction","text":"Purses.jl provides a type for wrapping a value that carries a small pre-computed cache around with it.  This kind of wrapped value is here referred to as a purse, and Purses.jl exports a single implementation of it called Purse.  A purse effectively functions as a named tuple or a struct, except field access is automatically tied to a specific function call.  That is, a purse of a number with a cached value of the square root of that number will automatically retrieve the cached value, when sqrt is called with the purse as argument.  In addition, a large number of base functions have been overloaded to automatically unwrap purses which allows them to seamlessly replace values in many cases.  If you encounter a function that is unsupported, please open an issue or a pull request in the GitHub repository.","category":"page"},{"location":"introduction/","page":"Introduction","title":"Introduction","text":"The cache in Purse is stored as a tuple, and the functions used for caching the entries are saved as a type parameter.  This allows specialising on the function to retrieve the cached value using compile-time constants for indexing into the cache.  Such cache retrieval results in native code that is equivalent to field access of a struct, and thus has minimal overhead.  To achieve this functionality, @generated methods are used for cacheable functions.  It is worth noting that this can put a lot of pressure on the compiler, since it will have to compile a new method for each type of purse in use.","category":"page"},{"location":"introduction/","page":"Introduction","title":"Introduction","text":"If the compiler does not know the type of the purse at compile-time, it will not be able to generate effective code.  Instead, it will fall back to run-time method table lookups to retrieve the cache value, which can be significantly slower than the computation itself.  However, this issue is no worse than for field access of a struct or named tuple, where type stability has equal importance for performance.","category":"page"},{"location":"#Purses.jl","page":"Index","title":"Purses.jl","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"Welcome to the documentation for Purses.jl!","category":"page"},{"location":"","page":"Index","title":"Index","text":"This document is intended to help you get started with using the package. If you have any suggestions, please open an issue or pull request on GitHub.","category":"page"}]
}
