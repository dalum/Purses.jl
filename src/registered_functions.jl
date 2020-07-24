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
    # Combined math operations
    (-) ∘ inv,
    (-) ∘ sqrt,
    (-) ∘ cbrt,
    (-) ∘ log,
    (-) ∘ exp,
    inv ∘ sqrt,
    inv ∘ cbrt,
    inv ∘ exp,
    inv ∘ log,
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
    # Combined math + iterator operations
    inv ∘ sum,
    inv ∘ prod,
    sqrt ∘ sum,
    sqrt ∘ prod,
    cbrt ∘ sum,
    cbrt ∘ prod,
    inv ∘ sqrt ∘ sum,
    inv ∘ sqrt ∘ prod,
    inv ∘ cbrt ∘ sum,
    inv ∘ cbrt ∘ prod,
    # Linear algebra operations
    adjoint,
    transpose,
)
