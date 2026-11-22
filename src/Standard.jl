# PS6 Standard: complete the 3 functions below.
# The supplied code in src/Model.jl calls sector_matrix to build the sector matrix B, least_squares_fit
# in fitting steps 1, 2, and 3, and compose_growth_rates to build each synthetic stock.
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

- Step 1, the baseline and market sensitivity of stock `i`: `X` is the design matrix `[1, g_m]`
  (days × 2), `y` is the growth rates of stock `i`, and `θ` is `(α_i, β_i)`.
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

Compose the growth rates of one synthetic stock (sampling step 3). `X * θ` gives the baseline and the
market part, `F * δ` gives the sector part, and `u` is the stock-specific part.

### Arguments

- `X`: The synthetic design matrix `[1, g_m]`, days × 2.
- `θ`: The baseline and market sensitivity of the stock, `(α, β)`.
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
