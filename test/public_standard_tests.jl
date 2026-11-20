# The PS6 public checks for the Standard track.
#
# Each check is a named tuple with two fields:
#   name - what the check tests, as the checker prints it
#   test - the function that runs the check; it returns true when the check passes
# run_public_check in test/Rubric.jl runs one check. Each check calls one student function, so
# an unfinished function does not block the checks of the others.

"""
    ps6_random_regression() -> Tuple{Matrix{Float64},Vector{Float64}}

A fixed regression problem: 200 days, a column of ones and three random columns in `X`, and
random values in `y`.
"""
function ps6_random_regression()::Tuple{Matrix{Float64},Vector{Float64}}

    # Draw the columns of X and the values of y from a fixed seed -
    rng = Xoshiro(5660);
    X = hcat(ones(200), randn(rng, 200, 3));
    y = randn(rng, 200);
    return (X, y);
end

# --- least_squares_fit checks ---

"""
    check_fit_matches_pinv() -> Bool

`least_squares_fit` matches the pseudo-inverse solution `pinv(X) * y` on a random problem.
"""
function check_fit_matches_pinv()::Bool
    (X, y) = ps6_random_regression();
    θ = least_squares_fit(X, y);
    return isapprox(θ, pinv(X) * y; atol = 1e-10);
end

"""
    check_fit_sector_averages() -> Bool

Fitting step 2: with the 0/1 sector matrix `B` as `X` and one day's residuals as `y`,
`least_squares_fit` returns the average residual of each sector.
"""
function check_fit_sector_averages()::Bool

    # Five stocks in two sectors: stocks 1, 2, and 4 in the first sector, stocks 3 and 5 in the second -
    B = [1.0 0.0; 1.0 0.0; 0.0 1.0; 1.0 0.0; 0.0 1.0];
    residuals = [0.3, -0.1, 0.4, 0.4, -0.2];

    # The averages of each sector: (0.3 - 0.1 + 0.4)/3 and (0.4 - 0.2)/2 -
    expected = [0.2, 0.1];
    return isapprox(least_squares_fit(B, residuals), expected; atol = 1e-12);
end

"""
    check_fit_residual_orthogonal() -> Bool

The residual `y - X θ` of a least-squares fit is orthogonal to every column of `X`.
"""
function check_fit_residual_orthogonal()::Bool
    (X, y) = ps6_random_regression();
    residual = y - X * least_squares_fit(X, y);
    return maximum(abs.(X' * residual)) < 1e-8;
end

"""
    check_fit_type_and_inputs() -> Bool

`least_squares_fit` returns a `Vector{Float64}` with one entry per column of `X`, and leaves
`X` and `y` unchanged.
"""
function check_fit_type_and_inputs()::Bool
    (X, y) = ps6_random_regression();
    copy_of_X = copy(X);
    copy_of_y = copy(y);
    θ = least_squares_fit(X, y);
    return θ isa Vector{Float64} && length(θ) == size(X, 2) && X == copy_of_X && y == copy_of_y;
end

# --- sector_matrix checks ---

"""
    check_sector_matrix_by_hand() -> Bool

A hand case: three stocks, two sectors, and the sectors listed in a different order from the stocks.
"""
function check_sector_matrix_by_hand()::Bool
    sectors = ["Energy", "Utilities", "Energy"];
    sector_names = ["Utilities", "Energy"];
    expected = [0.0 1.0; 1.0 0.0; 0.0 1.0];
    return sector_matrix(sectors, sector_names) == expected;
end

"""
    check_sector_matrix_counts() -> Bool

Each row of `B` holds exactly one `1`, and each column adds up to the number of stocks in its sector.
"""
function check_sector_matrix_counts()::Bool

    # Twelve stocks spread over four sectors -
    sector_names = ["Energy", "Financials", "Materials", "Utilities"];
    sectors = ["Energy", "Utilities", "Energy", "Materials", "Financials", "Energy",
        "Utilities", "Materials", "Energy", "Financials", "Energy", "Utilities"];
    B = sector_matrix(sectors, sector_names);

    # One 1 in each row, and the sector sizes 5, 2, 2, and 3 as the column sums -
    return vec(sum(B, dims = 2)) == ones(12) && vec(sum(B, dims = 1)) == [5.0, 2.0, 2.0, 3.0];
end

"""
    check_sector_matrix_unknown() -> Bool

A stock whose sector is not in `sector_names` raises an `ArgumentError`.
"""
function check_sector_matrix_unknown()::Bool

    # An ArgumentError passes; any other error goes to the checker, so that its message is shown -
    try
        sector_matrix(["Energy", "Bananas"], ["Energy", "Utilities"]);
    catch caught
        if caught isa ArgumentError
            return true;
        end
        rethrow(caught);
    end
    return false;
end

"""
    check_sector_matrix_type_and_inputs() -> Bool

`sector_matrix` returns a `Matrix{Float64}` of size stocks × sectors, and leaves its inputs unchanged.
"""
function check_sector_matrix_type_and_inputs()::Bool
    sectors = ["Energy", "Utilities", "Energy", "Materials"];
    sector_names = ["Energy", "Materials", "Utilities"];
    copy_of_sectors = copy(sectors);
    copy_of_names = copy(sector_names);
    B = sector_matrix(sectors, sector_names);
    return B isa Matrix{Float64} && size(B) == (4, 3) && sectors == copy_of_sectors && sector_names == copy_of_names;
end

# --- compose_growth_rates checks ---

"""
    check_compose_by_hand() -> Bool

A hand case with two days, a market column, and two sector factors.
"""
function check_compose_by_hand()::Bool

    # Day 1: 0.5 + 2.0 * 2.0 + 3.0 * 1.0 + 0.1; day 2: 0.5 + 2.0 * 3.0 + 4.0 * 1.0 + 0.2 -
    X = [1.0 2.0; 1.0 3.0];
    θ = [0.5, 2.0];
    F = [1.0 0.0; 0.0 1.0];
    δ = [3.0, 4.0];
    u = [0.1, 0.2];
    return isapprox(compose_growth_rates(X, θ, F, δ, u), [7.6, 10.7]; atol = 1e-12);
end

"""
    check_compose_rebuilds_stock() -> Bool

The fitted pieces of a stock rebuild its growth rates exactly: `X θ + F δ + u` equals `y` when
`θ`, `δ`, and `u` come from fitting steps 1 and 3.
"""
function check_compose_rebuilds_stock()::Bool

    # A stock, its market and economic columns X, and three sector factors F -
    rng = Xoshiro(14);
    X = hcat(ones(300), randn(rng, 300, 2));
    F = randn(rng, 300, 3);
    y = randn(rng, 300);

    # Fitting step 1, then fitting step 3, solved here without the student functions -
    θ = (X' * X) \ (X' * y);
    ε = y - X * θ;
    δ = (F' * F) \ (F' * ε);
    u = ε - F * δ;
    return isapprox(compose_growth_rates(X, θ, F, δ, u), y; atol = 1e-10);
end

"""
    check_compose_no_sectors() -> Bool

With no sector factors (`F` with zero columns, `δ` empty), the growth rates are `X θ + u`. The
single index model row of the report composes the stocks this way.
"""
function check_compose_no_sectors()::Bool
    X = [1.0 0.5; 1.0 -0.5; 1.0 1.5];
    θ = [0.1, 1.2];
    u = [0.01, 0.02, 0.03];
    expected = X * θ + u;
    return isapprox(compose_growth_rates(X, θ, zeros(3, 0), Float64[], u), expected; atol = 1e-12);
end

"""
    check_compose_type_and_inputs() -> Bool

`compose_growth_rates` returns a `Vector{Float64}` with one growth rate per day, and leaves its
inputs unchanged.
"""
function check_compose_type_and_inputs()::Bool

    # Random pieces for 50 days, and copies of each -
    rng = Xoshiro(3);
    X = hcat(ones(50), randn(rng, 50));
    θ = [0.2, 1.1];
    F = randn(rng, 50, 2);
    δ = [0.7, -0.3];
    u = randn(rng, 50);
    copies = (copy(X), copy(θ), copy(F), copy(δ), copy(u));

    # The result must be a vector of 50 growth rates, and every input unchanged -
    g = compose_growth_rates(X, θ, F, δ, u);
    return g isa Vector{Float64} && length(g) == 50 && (X, θ, F, δ, u) == copies;
end

"""
    standard_public_checks() -> Vector{NamedTuple}

The twelve Standard public checks: four for each of `least_squares_fit`, `sector_matrix`, and
`compose_growth_rates`.
"""
function standard_public_checks()::Vector{NamedTuple}

    # The name the checker prints, and the function that runs each check -
    return NamedTuple[
        (name = "Least-squares fit: matches pinv(X) * y", test = check_fit_matches_pinv),
        (name = "Least-squares fit: with X = B, returns the average of each sector", test = check_fit_sector_averages),
        (name = "Least-squares fit: the residual is orthogonal to every column of X", test = check_fit_residual_orthogonal),
        (name = "Least-squares fit: returns a Vector{Float64} and leaves the inputs unchanged", test = check_fit_type_and_inputs),
        (name = "Sector matrix: hand case with three stocks and two sectors", test = check_sector_matrix_by_hand),
        (name = "Sector matrix: one 1 in each row, and the sector sizes as column sums", test = check_sector_matrix_counts),
        (name = "Sector matrix: an unknown sector raises an ArgumentError", test = check_sector_matrix_unknown),
        (name = "Sector matrix: returns a Matrix{Float64} of size stocks × sectors", test = check_sector_matrix_type_and_inputs),
        (name = "Compose growth rates: hand case with two days", test = check_compose_by_hand),
        (name = "Compose growth rates: the fitted pieces rebuild a stock exactly", test = check_compose_rebuilds_stock),
        (name = "Compose growth rates: works with no sector factors", test = check_compose_no_sectors),
        (name = "Compose growth rates: returns a Vector{Float64} and leaves the inputs unchanged", test = check_compose_type_and_inputs),
    ]
end
