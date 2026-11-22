# PS6 Advanced: complete the 6 functions below: the 3 Standard functions, unmix_factors, mix_factors,
# and economic_factor.
# The supplied code in src/Model.jl calls sector_matrix to build the sector matrix B, least_squares_fit
# in fitting steps 1, 2, and 3, and compose_growth_rates to build each synthetic stock.
# It calls unmix_factors before it fits the jump hidden Markov models of the factors, mix_factors
# after it draws the factors, and economic_factor to turn each FRED series into a daily factor.
#
# How to complete a function: each TODO comment gives the exact code. Replace the error("Complete ...")
# line below the comment with that code, without the # in front, and keep the indentation. The rest of
# each function is supplied. Keep the function names, arguments, return types, and docstrings.
#
# Save your code, then run from the PS6 folder:
# julia --project=. --startup-file=no check_submission.jl
#
# The Course references at the end of each docstring name the course material that does the same
# calculation, and the companion slide with the formulas.

"""
    least_squares_fit(X::Matrix{Float64}, y::Vector{Float64}) -> Vector{Float64}

Find the `θ` that makes `X * θ` as close as possible to `y`, by solving the normal equations
`transpose(X) * X * θ = transpose(X) * y`. Fitting steps 1, 2, and 3 use this one solve, with a
different `X` and `y` in each step:

- Step 1, the baseline, market sensitivity, and economic loadings of stock `i`: `X` is the design
  matrix `[1, g_m, x_1, ..., x_K]` (days × columns), `y` is the growth rates of stock `i`, and `θ` is
  `(α_i, β_i, η_i1, ..., η_iK)`. Without the FRED series, `X` is `[1, g_m]`.
- Step 2, the sector factors on day `t`: `X` is the sector matrix `B` (stocks × sectors), `y` is the
  residual of every stock on day `t`, and `θ` is the sector factors on day `t`.
- Step 3, the sector loadings of stock `i`: `X` is the sector factors `F` (days × sectors), `y` is the
  residual of stock `i`, and `θ` is the sector loadings `δ_i`.

### Arguments

- `X`: The known matrix: one row per observation, and one column per entry of `θ`.
- `y`: The observations, one per row of `X`.

### Returns

- `θ`: The least-squares solution, one entry per column of `X`.

### Method

`transpose(X)` swaps the rows and the columns of `X`, and `*` multiplies a matrix by a matrix or by
a vector. The backslash between `(transpose(X) * X)` and `(transpose(X) * y)` solves the normal
equations for `θ`.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', fitting algorithm, steps 1, 2, and 3.
- Course example 'Estimating Single Index Models from Historical Data' (L6b), Task 1, 'Solve three
  ways': the line that solves the normal equations.
- PS6 companion: slide 6, 'One solve for fitting steps 1, 2, and 3'.
"""
function least_squares_fit(X::Matrix{Float64}, y::Vector{Float64})::Vector{Float64}

    # TODO: Solve the normal equations for θ.
    # Replace the error line below with this line:
    #     θ = (transpose(X) * X) \ (transpose(X) * y);
    θ = error("Complete least_squares_fit: solve the normal equations for θ.");

    return θ;
end

"""
    sector_matrix(sectors::Vector{String}, sector_names::Vector{String}) -> Matrix{Float64}

Build the sector matrix `B` of the general factor model: `B[i, s]` is `1.0` when stock `i` is in
sector `s`, and `0.0` otherwise.

### Arguments

- `sectors`: The GICS sector of each stock, one entry per stock.
- `sector_names`: The sectors, in the order of the columns of `B`.

### Returns

- `B`: The sector matrix, stocks × sectors. Each row holds exactly one `1.0`.

### Errors

- An `ArgumentError` when the sector of a stock is not in `sector_names`.

### Method

The supplied code starts from a matrix of zeros and visits each stock `i`. The inner loop compares
the sector of stock `i`, `sectors[i]`, with each name in `sector_names`: `==` is `true` when two
texts are the same. `B[i, s] = 1.0` sets the entry in row `i` and column `s` of `B`.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', fitting algorithm: the
  Initialize line that defines the sector matrix `B`.
- PS6 companion: slide 7, 'The sector matrix B'.
"""
function sector_matrix(sectors::Vector{String}, sector_names::Vector{String})::Matrix{Float64}

    # Start with no stock in any sector -
    number_of_stocks = length(sectors);
    number_of_sectors = length(sector_names);
    B = zeros(number_of_stocks, number_of_sectors);

    # Put each stock in its sector -
    for i ∈ 1:number_of_stocks

        # Find the column s of the stock's sector; s stays 0 when the sector is not in sector_names -
        s = 0;
        for k ∈ 1:number_of_sectors
            # TODO 1: Set s to k when sector_names[k] is the sector of stock i.
            # Replace the error line below with these three lines:
            #     if sector_names[k] == sectors[i]
            #         s = k;
            #     end
            error("Complete sector_matrix: find the column of the stock's sector.");
        end

        # A sector that is not in sector_names stops with a message -
        if s == 0
            throw(ArgumentError("Stock $(i) is in the sector $(sectors[i]), which is not in sector_names."));
        end

        # TODO 2: Set the entry of stock i in column s to 1.0.
        # Replace the error line below with this line:
        #     B[i, s] = 1.0;
        error("Complete sector_matrix: set B[i, s] to 1.0.");
    end

    return B;
end

"""
    compose_growth_rates(X::Matrix{Float64}, θ::Vector{Float64}, F::Matrix{Float64},
        δ::Vector{Float64}, u::Vector{Float64}) -> Vector{Float64}

Compose the growth rates of one synthetic stock (sampling step 3). `X * θ` gives the baseline, the
market part, and the economic part, `F * δ` gives the sector part, and `u` is the stock-specific part.

### Arguments

- `X`: The synthetic design matrix `[1, g_m, x_1, ..., x_K]`, days × columns. Without the FRED
  series, `X` is `[1, g_m]`.
- `θ`: The baseline, market sensitivity, and economic loadings of the stock, `(α, β, η_1, ..., η_K)`.
- `F`: The synthetic sector factors, days × sectors. `F` has zero columns when the model has no
  sector factors, as in the single index model.
- `δ`: The sector loadings of the stock, one per column of `F`.
- `u`: The synthetic stock-specific part of the stock, one value per day (1/yr).

### Returns

- `g`: The synthetic growth rates of the stock, one per day (1/yr).

### Method

`X * θ` and `F * δ` each multiply a matrix by a vector, and each gives one value per day. `+` adds
the two products and `u`, day by day. When `F` has zero columns, `F * δ` is a vector of zeros.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', sampling algorithm, step 3 (Compose).
- PS6 companion: slide 12, 'Sampling: draw, mix, and compose'.
"""
function compose_growth_rates(X::Matrix{Float64}, θ::Vector{Float64}, F::Matrix{Float64},
    δ::Vector{Float64}, u::Vector{Float64})::Vector{Float64}

    # TODO: Add the parts X * θ, F * δ, and u.
    # Replace the error line below with this line:
    #     g = X * θ + F * δ + u;
    g = error("Complete compose_growth_rates: compose the growth rates.");

    return g;
end

"""
    unmix_factors(Φ::Matrix{Float64}) -> Tuple{Vector{Float64},Matrix{Float64},Matrix{Float64}}

Unmix the factors (fitting step 4): turn the correlated factors in `Φ` into uncorrelated factors
`Z`, so that a jump hidden Markov model can draw each column of `Z` on its own.

### Arguments

- `Φ`: The factor matrix `[g_m, x_1, ..., x_K, F]`, days × factors: the market, the economic
  factors, and the sector factors. A model without economic factors or without sector factors
  leaves those columns out.

### Returns

- `μ`: The average of each column of `Φ`.
- `A`: The lower-triangular Cholesky factor of the covariance matrix of `Φ`, so that
  `A * transpose(A)` equals the covariance matrix.
- `Z`: The uncorrelated factors, days × factors. Each column has an average of `0` and a variance
  of `1`, and the correlation of any two columns is `0`.

### Method

`mean(Φ, dims = 1)` averages each column of `Φ` and returns one row, and `vec` turns that row into
a vector. The supplied line `Σ = Symmetric(cov(Φ))` computes the covariance matrix of `Φ`.
`cholesky(Σ).L` is the lower Cholesky factor of `Σ`, and `|> Matrix` passes that factor to `Matrix`,
which stores it as an ordinary matrix. In `Φ .- transpose(μ)`, the dot subtracts `μ` from every row
of `Φ`. Dividing on the right by `transpose(A)` with `/` multiplies by the inverse of `transpose(A)`,
without computing the inverse.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', fitting algorithm, step 4 (Unmix
  the factors), and the note 'Why unmix the factors?'.
- Course example 'Simulating a Portfolio with Multiple Asset Geometric Brownian Motion' (L6a),
  Task 1, 'Construct the price model': the line that computes `A` with `cholesky`.
- PS6 companion: slide 10, 'Fitting step 4: unmix the factors'.
"""
function unmix_factors(Φ::Matrix{Float64})::Tuple{Vector{Float64},Matrix{Float64},Matrix{Float64}}

    # TODO 1: The average of each column of Φ, as a vector.
    # Replace the error line below with this line:
    #     μ = vec(mean(Φ, dims = 1));
    μ = error("Complete unmix_factors: the column averages of Φ.");

    # The covariance matrix of Φ; Symmetric tells cholesky that the matrix is symmetric -
    Σ = Symmetric(cov(Φ));

    # TODO 2: The lower Cholesky factor of Σ, as an ordinary matrix.
    # Replace the error line below with this line:
    #     A = cholesky(Σ).L |> Matrix;
    A = error("Complete unmix_factors: the lower Cholesky factor of Σ.");

    # TODO 3: Subtract the averages from each row of Φ, then divide on the right by transpose(A).
    # Replace the error line below with this line:
    #     Z = (Φ .- transpose(μ)) / transpose(A);
    Z = error("Complete unmix_factors: compute Z.");

    return (μ, A, Z);
end

"""
    mix_factors(Z::Matrix{Float64}, μ::Vector{Float64}, A::Matrix{Float64}) -> Matrix{Float64}

Mix draws of the uncorrelated factors back into correlated factors (sampling step 1): multiply `Z`
by `transpose(A)`, and add the averages `μ` to each row.

### Arguments

- `Z`: Draws of the uncorrelated factors, days × factors: one column per jump hidden Markov model.
- `μ`: The column averages from `unmix_factors`.
- `A`: The Cholesky factor from `unmix_factors`.

### Returns

- `Φ`: The synthetic factors, days × factors: the market, the economic factors, and the sector
  factors, in the order of the columns of `Φ` in `unmix_factors`.

### Method

Multiplying by `transpose(A)` undoes the division by `transpose(A)` in `unmix_factors`: it mixes
the columns of `Z` back into correlated factors. In `transpose(μ) .+ Z * transpose(A)`, the dot adds
`μ` to every row of the product.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', sampling algorithm, step 1
  (Factor draws).
- Course example 'Simulating a Portfolio with Multiple Asset Geometric Brownian Motion' (L6a),
  Task 1, 'Simulate correlated price paths': the step that correlates independent draws with `A`.
- PS6 companion: slide 12, 'Sampling: draw, mix, and compose'.
"""
function mix_factors(Z::Matrix{Float64}, μ::Vector{Float64}, A::Matrix{Float64})::Matrix{Float64}

    # TODO: Multiply Z by transpose(A), then add transpose(μ) to each row.
    # Replace the error line below with this line:
    #     Φ = transpose(μ) .+ Z * transpose(A);
    Φ = error("Complete mix_factors: mix the draws.");

    return Φ;
end

"""
    economic_factor(levels::Vector{Float64}, kind::String, Δt::Float64) -> Vector{Float64}

Turn a FRED series, one level per trading day, into a daily economic factor. A rate becomes its
daily change, and a price or an index becomes its growth rate, like the growth rates of the stocks.

### Arguments

- `levels`: The level of the series on each trading day, such as the 10-year Treasury yield
  (percent) or the Brent oil price (USD/barrel).
- `kind`: `"change"` for a rate, or `"growth"` for a price or an index, such as the Brent oil
  price or the US dollar index.
- `Δt`: One trading day, in years (`1/252`).

### Returns

- `x`: The factor, `length(levels) - 1` values: one for each day after the first.

### Errors

- An `ArgumentError` when `kind` is not `"change"` or `"growth"`.

### Method

`levels[t+1]` is the level on the day after day `t`, and `log` is the natural logarithm. For
`"change"`, `x[t]` is the change in the level from day `t` to day `t + 1`, in the units of the
level. For `"growth"`, `x[t]` is the growth rate from day `t` to day `t + 1` (1/yr): the log of the
ratio of the two levels, divided by one trading day `Δt`.

### Course references

- Course lecture L14a, section 'Building a General Factor Model': each economic factor must be a
  daily series, such as the daily change in the 10-year Treasury yield.
- Course example 'A Synthetic Market of Many Stocks' (L14a), Constants cell: the growth rates
  from `JumpHMM.excess_growth_rates` with `rf = 0.0`.
- PS6 companion: slide 9, 'Economic factors from FRED'.
"""
function economic_factor(levels::Vector{Float64}, kind::String, Δt::Float64)::Vector{Float64}

    # Check the kind of the series -
    if kind != "change" && kind != "growth"
        throw(ArgumentError("The kind must be \"change\" or \"growth\", not \"$(kind)\"."));
    end

    # One value for each day after the first -
    number_of_days = length(levels) - 1;
    x = zeros(number_of_days);
    for t ∈ 1:number_of_days
        if kind == "change"
            # TODO 1: The change in the level from day t to day t + 1.
            # Replace the error line below with this line:
            #     x[t] = levels[t+1] - levels[t];
            error("Complete economic_factor: the daily change of a rate.");
        else
            # TODO 2: The growth rate of the level from day t to day t + 1.
            # Replace the error line below with this line:
            #     x[t] = log(levels[t+1] / levels[t]) / Δt;
            error("Complete economic_factor: the growth rate of a price or an index.");
        end
    end

    return x;
end
