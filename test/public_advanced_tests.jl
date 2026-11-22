# The PS6 public checks for the Advanced track: the twelve Standard checks, then four checks of
# unmix_factors, four checks of mix_factors, and four checks of economic_factor. Each check calls one
# student function, so an unfinished function does not block the checks of the others.

"""
    ps6_correlated_factors() -> Matrix{Float64}

A fixed factor matrix: 600 days of four correlated factors with nonzero means.
"""
function ps6_correlated_factors()::Matrix{Float64}

    # Mix independent draws through a fixed matrix, then shift each column -
    rng = Xoshiro(21);
    M = [1.0 0.6 0.0 -0.3; 0.0 0.8 0.5 0.2; 0.0 0.0 0.7 0.4; 0.0 0.0 0.0 0.9];
    Φ = randn(rng, 600, 4) * M;
    shift = [0.1, -0.2, 0.05, 0.3];
    for j ∈ 1:4
        Φ[:, j] = Φ[:, j] .+ shift[j];
    end
    return Φ;
end

# --- unmix_factors checks ---

"""
    check_unmix_identity_covariance() -> Bool

The columns of `Z` are uncorrelated with variance one: `cov(Z)` is the identity matrix. Mixing `Z`
back with `A` and `μ` gives the original factors.
"""
function check_unmix_identity_covariance()::Bool

    # The covariance of Z, and the factors rebuilt from Z, A, and μ -
    Φ = ps6_correlated_factors();
    (μ, A, Z) = unmix_factors(Φ);
    identity_ok = isapprox(cov(Z), Matrix{Float64}(I, 4, 4); atol = 1e-10);
    rebuild_ok = isapprox(μ' .+ Z * A', Φ; atol = 1e-10);
    return identity_ok && rebuild_ok;
end

"""
    check_unmix_cholesky() -> Bool

`A` is lower triangular with a positive diagonal, as the Cholesky factor is, and `A A'` equals the
covariance matrix of `Φ`.
"""
function check_unmix_cholesky()::Bool

    # The shape and the diagonal of A, and the product A A' -
    Φ = ps6_correlated_factors();
    A = unmix_factors(Φ)[2];
    return istril(A) && all(diag(A) .> 0) && isapprox(A * A', cov(Φ); atol = 1e-10);
end

"""
    check_unmix_means() -> Bool

`μ` holds the column averages of `Φ`, and every column of `Z` has an average of zero.
"""
function check_unmix_means()::Bool

    # The averages μ, and the column averages of Z -
    Φ = ps6_correlated_factors();
    result = unmix_factors(Φ);
    μ = result[1];
    Z = result[3];
    return isapprox(μ, vec(mean(Φ, dims = 1)); atol = 1e-12) && maximum(abs.(mean(Z, dims = 1))) < 1e-10;
end

"""
    check_unmix_type_and_inputs() -> Bool

`unmix_factors` returns a `Vector{Float64}` and two `Matrix{Float64}` of the right sizes, and
leaves `Φ` unchanged.
"""
function check_unmix_type_and_inputs()::Bool

    # Unmix Φ, then check the types, the sizes, and Φ after the call -
    Φ = ps6_correlated_factors();
    copy_of_Φ = copy(Φ);
    (μ, A, Z) = unmix_factors(Φ);
    types_ok = μ isa Vector{Float64} && A isa Matrix{Float64} && Z isa Matrix{Float64};
    sizes_ok = length(μ) == 4 && size(A) == (4, 4) && size(Z) == (600, 4);
    return types_ok && sizes_ok && Φ == copy_of_Φ;
end

# --- mix_factors checks ---

"""
    check_mix_by_hand() -> Bool

A hand case: `Z` is the 2 × 2 identity, so each row of the result is `μ` plus a column of `A`.
"""
function check_mix_by_hand()::Bool

    # Row 1 is μ plus the first column of A; row 2 is μ plus the second column of A -
    Z = [1.0 0.0; 0.0 1.0];
    μ = [1.0, 2.0];
    A = [2.0 0.0; 1.0 3.0];
    return isapprox(mix_factors(Z, μ, A), [3.0 3.0; 1.0 5.0]; atol = 1e-12);
end

"""
    check_mix_undoes_unmix() -> Bool

Mixing the uncorrelated factors back gives the original factors. The unmixing is done here,
without the student function.
"""
function check_mix_undoes_unmix()::Bool

    # Fitting step 4, solved here: the column averages, the Cholesky factor, and Z -
    Φ = ps6_correlated_factors();
    μ = vec(mean(Φ, dims = 1));
    A = Matrix(cholesky(Symmetric(cov(Φ))).L);
    Z = (Φ .- μ') / A';
    return isapprox(mix_factors(Z, μ, A), Φ; atol = 1e-10);
end

"""
    check_mix_independent_draws() -> Bool

Independent draws, mixed through `A`, get the covariance `A A'`: mixing is how the synthetic
factors move together.
"""
function check_mix_independent_draws()::Bool

    # Fifty thousand days of five independent draws with variance one -
    rng = Xoshiro(8);
    Z = randn(rng, 50_000, 5);
    A = [1.0 0.0 0.0 0.0 0.0; 0.6 0.8 0.0 0.0 0.0; -0.4 0.3 0.5 0.0 0.0; 0.2 -0.1 0.3 0.9 0.0;
        0.1 0.2 -0.2 0.3 0.7];
    Φ = mix_factors(Z, zeros(5), A);
    return isapprox(cov(Φ), A * A'; atol = 0.03);
end

"""
    check_mix_type_and_inputs() -> Bool

`mix_factors` returns a `Matrix{Float64}` of the size of `Z`, and leaves its inputs unchanged.
"""
function check_mix_type_and_inputs()::Bool

    # Mix random draws, then check the type, the size, and the inputs after the call -
    rng = Xoshiro(2);
    Z = randn(rng, 30, 2);
    μ = [0.1, 0.2];
    A = [1.0 0.0; 0.5 2.0];
    copies = (copy(Z), copy(μ), copy(A));
    Φ = mix_factors(Z, μ, A);
    return Φ isa Matrix{Float64} && size(Φ) == (30, 2) && (Z, μ, A) == copies;
end

# --- economic_factor checks ---

"""
    check_factor_change_by_hand() -> Bool

A rate becomes its daily change: the levels `2.0, 2.5, 2.25` give `0.5, -0.25`.
"""
function check_factor_change_by_hand()::Bool

    # The change from each day to the next -
    x = economic_factor([2.0, 2.5, 2.25], "change", 1/252);
    return isapprox(x, [0.5, -0.25]; atol = 1e-12);
end

"""
    check_factor_growth_by_hand() -> Bool

A price becomes its growth rate: the levels `100, 110, 99` give `252 log(1.1)` and `252 log(0.9)`
for one trading day, `Δt = 1/252`, and `12 log(1.1)` and `12 log(0.9)` for one month, `Δt = 1/12`.
"""
function check_factor_growth_by_hand()::Bool

    # The same levels with a time step of one trading day and of one month -
    daily = economic_factor([100.0, 110.0, 99.0], "growth", 1/252);
    monthly = economic_factor([100.0, 110.0, 99.0], "growth", 1/12);
    daily_ok = isapprox(daily, [252 * log(1.1), 252 * log(0.9)]; atol = 1e-10);
    monthly_ok = isapprox(monthly, [12 * log(1.1), 12 * log(0.9)]; atol = 1e-10);
    return daily_ok && monthly_ok;
end

"""
    check_factor_constant_levels() -> Bool

Constant levels give a factor of zeros with one value fewer than the levels, for both kinds.
"""
function check_factor_constant_levels()::Bool

    # Ten equal levels give nine zeros for each kind -
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

The twenty-four Advanced public checks: the twelve Standard checks, then four for `unmix_factors`,
four for `mix_factors`, and four for `economic_factor`.
"""
function advanced_public_checks()::Vector{NamedTuple}

    # The twelve Standard checks, the eight checks of the Cholesky step, and the four economic factor checks -
    checks = standard_public_checks();
    push!(checks, (name = "Unmix factors: the columns of Z are uncorrelated with variance one, and mix back to Φ", test = check_unmix_identity_covariance));
    push!(checks, (name = "Unmix factors: A is lower triangular with a positive diagonal, and A A' is the covariance of Φ", test = check_unmix_cholesky));
    push!(checks, (name = "Unmix factors: μ holds the column averages, and Z has averages of zero", test = check_unmix_means));
    push!(checks, (name = "Unmix factors: returns (μ, A, Z) of the right types and sizes", test = check_unmix_type_and_inputs));
    push!(checks, (name = "Mix factors: hand case with Z equal to the identity", test = check_mix_by_hand));
    push!(checks, (name = "Mix factors: mixing undoes the unmixing", test = check_mix_undoes_unmix));
    push!(checks, (name = "Mix factors: independent draws get the covariance A A'", test = check_mix_independent_draws));
    push!(checks, (name = "Mix factors: returns a Matrix{Float64} and leaves the inputs unchanged", test = check_mix_type_and_inputs));
    push!(checks, (name = "Economic factor: a rate becomes its daily change", test = check_factor_change_by_hand));
    push!(checks, (name = "Economic factor: a price becomes its growth rate", test = check_factor_growth_by_hand));
    push!(checks, (name = "Economic factor: constant levels give zeros, one value fewer", test = check_factor_constant_levels));
    push!(checks, (name = "Economic factor: returns a Vector{Float64}; an unknown kind throws an ArgumentError", test = check_factor_type_and_kind));
    return checks;
end
