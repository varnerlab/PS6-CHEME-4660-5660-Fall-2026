# PS6 Advanced: complete the 5 functions below, the 3 Standard functions, unmix_factors, and mix_factors.
# The supplied code in src/Model.jl calls sector_matrix to build the sector matrix B, least_squares_fit
# in fitting steps 1, 2, and 3, and compose_growth_rates to build each synthetic stock.
# It calls unmix_factors before it fits the jump hidden Markov models of the factors, and
# mix_factors after it draws the factors.
# Keep the function names, arguments, return types, and docstrings.
# Replace each error("Complete ...") line with your calculation. The rest of each function is supplied.
# Save your code, then run from the PS6 folder:
# julia --project=. --startup-file=no check_submission.jl
#
# The Course references at the end of each docstring name the course material that does the same
# calculation, and the companion slide with the formulas. Copy only the lines you need, and rename
# the variables to match this file.

"""
    least_squares_fit(X::Matrix{Float64}, y::Vector{Float64}) -> Vector{Float64}

Solve the least-squares problem `X'X θ = X'y` for `θ`. When `X` has full column rank, as in every
step of the general factor model, the answer equals the pseudo-inverse solution `pinv(X) * y`.
Fitting steps 1, 2, and 3 use this one solve, with a different `X` and `y` in each step:

- Step 1, the market and economic loadings of stock `i`: `X` is the design matrix
  `[1, g_m, x_1, ..., x_K]` (days × columns), `y` is the growth rates of stock `i`, and `θ` is
  `(α_i, β_i, η_i1, ..., η_iK)`. On the Standard and Advanced tracks, `X` is `[1, g_m]`.
- Step 2, the sector factors on day `t`: `X` is the sector matrix `B` (stocks × sectors), `y` is the
  residual of every stock on day `t`, and `θ` is the sector factors on day `t`.
- Step 3, the sector loadings of stock `i`: `X` is the sector factors `F` (days × sectors), `y` is the
  residual of stock `i`, and `θ` is the sector loadings `δ_i`.

### Arguments

- `X`: The matrix of the problem, one row per observation and one column per unknown.
- `y`: The observations, one per row of `X`.

### Returns

- `θ`: The least-squares solution, one entry per column of `X`.

### Method

Form the matrix `transpose(X) * X` and the vector `transpose(X) * y`, and solve the linear system
with the backslash operator.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', fitting algorithm, steps 1, 2, and 3.
- Course example 'Estimating Single Index Models from Historical Data' (L6b), Task 1, 'Solve three
  ways': the normal-equations line `(transpose(X̂)*X̂) \\ (transpose(X̂)*y)`.
- PS6 companion: slide 6, 'One solve for fitting steps 1, 2, and 3'.
"""
function least_squares_fit(X::Matrix{Float64}, y::Vector{Float64})::Vector{Float64}

    # TODO: Solve the normal equations for θ.
    # Hint: θ = (transpose(X) * X) \ (transpose(X) * y);
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

Start from a matrix of zeros. For each stock, find the column of the stock's sector in
`sector_names`, and set the stock's entry in that column to `1.0`.

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
            # Hint: if sector_names[k] == sectors[i] ... end
            error("Complete sector_matrix: find the column of the stock's sector.");
        end

        # A sector that is not in sector_names stops with a message -
        if s == 0
            throw(ArgumentError("Stock $(i) is in the sector $(sectors[i]), which is not in sector_names."));
        end

        # TODO 2: Set the entry of stock i in column s to 1.0.
        # Hint: B[i, s] = 1.0;
        error("Complete sector_matrix: set B[i, s] to 1.0.");
    end

    return B;
end

"""
    compose_growth_rates(X::Matrix{Float64}, θ::Vector{Float64}, F::Matrix{Float64},
        δ::Vector{Float64}, u::Vector{Float64}) -> Vector{Float64}

Compose the growth rates of one synthetic stock (sampling step 3): the market and economic part
`X θ`, plus the sector part `F δ`, plus the stock-specific part `u`.

### Arguments

- `X`: The synthetic design matrix `[1, g_m, x_1, ..., x_K]`, days × columns. On the Standard and
  Advanced tracks, `X` is `[1, g_m]`.
- `θ`: The baseline, market sensitivity, and economic loadings of the stock, `(α, β, η_1, ..., η_K)`.
- `F`: The synthetic sector factors, days × sectors. `F` has zero columns when a market has no
  sector factors.
- `δ`: The sector loadings of the stock, one per column of `F`.
- `u`: The synthetic stock-specific growth rates of the stock, one per day (1/yr).

### Returns

- `g`: The synthetic growth rates of the stock, one per day (1/yr).

### Method

Multiply `X` by `θ` and `F` by `δ`. Each product holds one value per day. Add the two products
and `u`.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', sampling algorithm, step 3 (Compose).
- PS6 companion: slide 12, 'Sampling: draw, mix, and compose'.
"""
function compose_growth_rates(X::Matrix{Float64}, θ::Vector{Float64}, F::Matrix{Float64},
    δ::Vector{Float64}, u::Vector{Float64})::Vector{Float64}

    # TODO: Add the market and economic part, the sector part, and the stock-specific part.
    # Hint: g = X * θ + F * δ + u;
    g = error("Complete compose_growth_rates: compose the growth rates.");

    return g;
end

"""
    unmix_factors(Φ::Matrix{Float64}) -> Tuple{Vector{Float64},Matrix{Float64},Matrix{Float64}}

Unmix the factors (fitting step 4): turn the correlated factors in `Φ` into uncorrelated factors
`Z`, so that a jump hidden Markov model can draw each column of `Z` on its own.

### Arguments

- `Φ`: The factor matrix `[g_m, x_1, ..., x_K, F]`, days × factors: the market, the economic
  factors (Expert only), and the sector factors.

### Returns

- `μ`: The average of each column of `Φ`.
- `A`: The lower-triangular Cholesky factor of the covariance matrix of `Φ`, so that
  `A * transpose(A)` equals the covariance matrix.
- `Z`: The uncorrelated factors, days × factors. Each column has an average of 0 and a variance of 1.

### Method

Compute the average of each column of `Φ`, and the covariance matrix of `Φ`. Factor the covariance
matrix with `cholesky`, and keep its lower factor as an ordinary matrix with `|> Matrix`. Subtract
`transpose(μ)` from each row of `Φ`, then divide on the right by `transpose(A)` with the `/` operator.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', fitting algorithm, step 4 (Unmix
  the factors), and the note 'Why unmix the factors?'.
- Course example 'Simulating a Portfolio with Multiple Asset Geometric Brownian Motion' (L6a),
  Task 1, 'Construct the price model': the line that computes `A` with `cholesky`.
- PS6 companion: slide 10, 'Fitting step 4: unmix the factors'.
"""
function unmix_factors(Φ::Matrix{Float64})::Tuple{Vector{Float64},Matrix{Float64},Matrix{Float64}}

    # TODO 1: The average of each column of Φ, as a vector.
    # Hint: μ = vec(mean(Φ, dims = 1));
    μ = error("Complete unmix_factors: the column averages of Φ.");

    # The covariance matrix of Φ; Symmetric tells cholesky that the matrix is symmetric -
    Σ = Symmetric(cov(Φ));

    # TODO 2: The lower Cholesky factor of Σ, as an ordinary matrix.
    # Hint: A = cholesky(Σ).L |> Matrix;
    A = error("Complete unmix_factors: the lower Cholesky factor of Σ.");

    # TODO 3: Subtract the averages from each row of Φ, then divide on the right by transpose(A).
    # Hint: Z = (Φ .- transpose(μ)) / transpose(A);
    Z = error("Complete unmix_factors: compute Z.");

    return (μ, A, Z);
end

"""
    mix_factors(Z::Matrix{Float64}, μ::Vector{Float64}, A::Matrix{Float64}) -> Matrix{Float64}

Mix draws of the uncorrelated factors back into correlated factors (sampling step 1): multiply `Z`
by `transpose(A)`, and add the averages `transpose(μ)` to each row.

### Arguments

- `Z`: Draws of the uncorrelated factors, days × factors: one column per jump hidden Markov model.
- `μ`: The column averages from `unmix_factors`.
- `A`: The Cholesky factor from `unmix_factors`.

### Returns

- `Φ`: The synthetic factors, days × factors: the market, the economic factors (Expert only), and
  the sector factors, in the order of the columns of `Φ` in `unmix_factors`.

### Method

Multiply `Z` by `transpose(A)`. Add `transpose(μ)` to each row of the product.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', sampling algorithm, step 1
  (Factor draws).
- Course example 'Simulating a Portfolio with Multiple Asset Geometric Brownian Motion' (L6a),
  Task 1, 'Simulate correlated price paths': the step that correlates independent draws with `A`.
- PS6 companion: slide 12, 'Sampling: draw, mix, and compose'.
"""
function mix_factors(Z::Matrix{Float64}, μ::Vector{Float64}, A::Matrix{Float64})::Matrix{Float64}

    # TODO: Multiply Z by transpose(A), then add transpose(μ) to each row.
    # Hint: Φ = transpose(μ) .+ Z * transpose(A);
    Φ = error("Complete mix_factors: mix the draws.");

    return Φ;
end
