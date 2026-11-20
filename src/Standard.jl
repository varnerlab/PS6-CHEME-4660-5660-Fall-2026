# PS6 Standard: complete the 3 functions below.
# The supplied code in src/Model.jl calls sector_matrix to build the sector matrix B, least_squares_fit
# in fitting steps 1, 2, and 3, and compose_growth_rates to build each synthetic stock.
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

Solve the least-squares problem `X'X θ = X'y` for `θ`. The answer is the pseudo-inverse
solution, `θ = pinv(X) * y`. The general factor model uses this one solve in fitting steps 1, 2,
and 3, with a different `X` and `y` in each step:

- Step 1, the market and economic loadings of stock `i`: `X` is the design matrix
  `[1, g_m, x_1, ..., x_K]` (days × columns), `y` is the growth rates of stock `i`, and `θ` is
  `(α_i, β_i, η_i1, ..., η_iK)`. On the Standard track, `X` is `[1, g_m]`.
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

Form the matrix `X' * X` and the vector `X' * y`, and solve the linear system with the backslash
operator.

### Course references

- Course lecture L14a, section 'Building a General Factor Model', fitting algorithm, steps 1, 2, and 3.
- PS6 companion: slide 'One least-squares solve for fitting steps 1, 2, and 3'.
"""
function least_squares_fit(X::Matrix{Float64}, y::Vector{Float64})::Vector{Float64}

    # TODO: Solve X'X θ = X'y for θ.
    # Hint: θ = (X' * X) \ (X' * y);
    θ = error("Complete least_squares_fit: solve X'X θ = X'y for θ.");

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
- PS6 companion: slide 'The sector matrix B'.
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

- `X`: The synthetic design matrix `[1, g_m, x_1, ..., x_K]`, days × columns. On the Standard
  track, `X` is `[1, g_m]`.
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
- PS6 companion: slide 'Sampling: draw, mix, and compose'.
"""
function compose_growth_rates(X::Matrix{Float64}, θ::Vector{Float64}, F::Matrix{Float64},
    δ::Vector{Float64}, u::Vector{Float64})::Vector{Float64}

    # TODO: Add the market and economic part, the sector part, and the stock-specific part.
    # Hint: g = X * θ + F * δ + u;
    g = error("Complete compose_growth_rates: compose the growth rates.");

    return g;
end
