# The PS6 public checks for the Advanced track: the twelve Standard checks, then four checks of
# economic_factor. Each check calls one student function, so an unfinished function does not
# block the checks of the others.

# --- economic_factor checks ---

"""
    check_factor_change_by_hand() -> Bool

A rate becomes its daily change: the levels `2.0, 2.5, 2.25` give `0.5, -0.25`.
"""
function check_factor_change_by_hand()::Bool
    x = economic_factor([2.0, 2.5, 2.25], "change", 1/252);
    return isapprox(x, [0.5, -0.25]; atol = 1e-12);
end

"""
    check_factor_growth_by_hand() -> Bool

A price becomes its growth rate: the levels `100, 110, 99` give `252 log(1.1)` and `252 log(0.9)`
for one trading day, `Δt = 1/252`.
"""
function check_factor_growth_by_hand()::Bool
    x = economic_factor([100.0, 110.0, 99.0], "growth", 1/252);
    return isapprox(x, [252 * log(1.1), 252 * log(0.9)]; atol = 1e-10);
end

"""
    check_factor_constant_levels() -> Bool

Constant levels give a factor of zeros with one value fewer than the levels, for both kinds.
"""
function check_factor_constant_levels()::Bool
    levels = fill(3.5, 10);
    change = economic_factor(levels, "change", 1/252);
    growth = economic_factor(levels, "growth", 1/252);
    return change == zeros(9) && growth == zeros(9);
end

"""
    check_factor_type_and_kind() -> Bool

`economic_factor` returns a `Vector{Float64}` and leaves the levels unchanged, and a kind other
than `"change"` or `"growth"` raises an `ArgumentError`.
"""
function check_factor_type_and_kind()::Bool

    # The type of the result, and the levels after the call -
    levels = [1.0, 1.5, 1.2, 1.4];
    copy_of_levels = copy(levels);
    x = economic_factor(levels, "growth", 1/252);
    type_ok = x isa Vector{Float64} && levels == copy_of_levels;

    # An unknown kind -
    kind_ok = false;
    try
        economic_factor(levels, "level", 1/252);
    catch caught
        kind_ok = caught isa ArgumentError;
    end
    return type_ok && kind_ok;
end

"""
    advanced_public_checks() -> Vector{NamedTuple}

The sixteen Advanced public checks: the twelve Standard checks, then four for `economic_factor`.
"""
function advanced_public_checks()::Vector{NamedTuple}

    # The twelve Standard checks, then the four economic factor checks -
    checks = standard_public_checks();
    push!(checks, (name = "Economic factor: a rate becomes its daily change", test = check_factor_change_by_hand));
    push!(checks, (name = "Economic factor: a price becomes its growth rate", test = check_factor_growth_by_hand));
    push!(checks, (name = "Economic factor: constant levels give zeros, one value fewer", test = check_factor_constant_levels));
    push!(checks, (name = "Economic factor: returns a Vector{Float64}; an unknown kind raises an ArgumentError", test = check_factor_type_and_kind));
    return checks;
end
