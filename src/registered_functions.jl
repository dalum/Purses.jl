# This file contains all default registered functions.  Additional functions may be
# registered by the user or by other modules.
register!(
    # Basic math group elements
    identity,
    zero,
    one,
    oneunit,
    # Basic math operations
    +,
    -,
    inv,
    sqrt,
    cbrt,
    log,
    exp,
    conj,
    # Trigonomotry
    cos, sin, tan, cot, sec, csc,
    cosh, sinh, tanh, coth, sech, csch,
    acos, asin, atan, acot, asec, acsc,
    acosh, asinh, atanh, acoth, asech, acsch,
    # Iterator operations
    sum,
    prod,
    length,
    size,
    # Linear algebra operations
    adjoint,
    transpose,
)
