# PS6 Standard: complete the 3 functions below.
# The simulator calls three_state_rule for every trader at every step, and the report calls
# excess_kurtosis and volatility_clustering on the growth rates of each market.
# Keep the function names, arguments, return types, and docstrings.
# Replace each error("Complete ...") expression with your calculation.
# Each TODO asks for a few lines; the rest of each function is supplied.
# Save your code, then run from the PS6 folder:
# julia --project=. --startup-file=no check_submission.jl
#
# Each docstring ends with Course references: the part of the course material that does the
# same calculation, and the matching slide in the PS6 mathematical companion. Copy only the
# lines you need and rename variables to match this file.

"""
    three_state_rule(state::Int, z::Float64, T::Float64, τ::Float64) -> Int

Give a trader's next state in the three-state Farmer–Joshi rule.

### Arguments

- `state`: The trader's current state: `-1` (short), `0` (flat), or `1` (long).
- `z`: The trader's signal (dimensionless). A positive `z` favors a long position.
- `T`: The trader's entry threshold (dimensionless, positive).
- `τ`: The trader's exit threshold (dimensionless, below `T`).

### Returns

- The trader's next state: `-1`, `0`, or `1`.

### Method

All comparisons are strict.

- From state `0`, the trader enters a long position (state `1`) when `z` is above `T`, and enters a
  short position (state `-1`) when `z` is below `-T`. Otherwise the trader stays in state `0`.
- From state `1`, the trader exits to state `0` when `z` is below `τ`. Otherwise the trader stays in state `1`.
- From state `-1`, the trader exits to state `0` when `z` is above `-τ`. Otherwise the trader stays in state `-1`.

### Course references

- Course lecture L12a, section 'The Farmer–Joshi algorithm'.
- PS6 companion: slide 6, 'The three-state rule'.
"""
function three_state_rule(state::Int, z::Float64, T::Float64, τ::Float64)::Int

    # From state 0 (flat), the trader enters on a strong signal, and otherwise stays flat -
    if state == 0
        # TODO 1: Return 1 when z is above T, and return -1 when z is below -T.
        # Hint: write one if-block for each entry.
        error("Complete three_state_rule: the entry rule from state 0.");
        return 0;
    end

    # From state 1 (long), the trader exits when the signal falls below τ, and otherwise stays long -
    if state == 1
        # TODO 2: Return 0 when z is below τ.
        error("Complete three_state_rule: the exit rule from state 1.");
        return 1;
    end

    # From state -1 (short), the trader exits when the signal rises above -τ, and otherwise stays short -
    # TODO 3: Return 0 when z is above -τ.
    error("Complete three_state_rule: the exit rule from state -1.");
    return -1;
end

"""
    excess_kurtosis(g::Vector{Float64}) -> Float64

Compute the excess kurtosis of the growth rates `g`, from population moments.

### Arguments

- `g`: The growth rates of one market (1/yr).

### Returns

- `κ`: The excess kurtosis of `g` (dimensionless). A Normal distribution has `κ = 0`.

### Method

Compute the mean of `g` and the population standard deviation of `g` (divide by `N`, not by `N - 1`).
Standardize each growth rate, raise each standardized value to the fourth power, and average
these values over the `N` growth rates. Subtract `3.0`.

### Course references

- Course example 'The Farmer–Joshi Market', Task 2: the line that defines `excess_kurtosis`.
- PS6 companion: slide 7, 'Fat tails: excess kurtosis'.
"""
function excess_kurtosis(g::Vector{Float64})::Float64

    # The mean and the population standard deviation of g -
    center = mean(g);
    spread = std(g, corrected = false);

    # Add up the fourth power of each standardized growth rate -
    total = 0.0;
    for value ∈ g
        # TODO 1: Add the fourth power of the standardized growth rate to total.
        # Hint: total += ((value - center) / spread)^4;
        error("Complete excess_kurtosis: add the fourth power of each standardized growth rate.");
    end

    # TODO 2: Divide total by the number of growth rates, then subtract 3.0.
    # Hint: length(g) is the number of growth rates.
    κ = error("Complete excess_kurtosis: compute the excess kurtosis.");

    return κ;
end

"""
    volatility_clustering(g::Vector{Float64}, lags::Vector{Int}) -> Float64

Compute the volatility clustering of the growth rates `g`: the mean autocorrelation of `abs.(g)`
over `lags`.

### Arguments

- `g`: The growth rates of one market (1/yr).
- `lags`: The lags at which to compute the autocorrelation (steps, positive integers).

### Returns

- `ρ`: The mean of the autocorrelations of `abs.(g)` at the lags in `lags` (dimensionless).

### Method

Take the absolute value of each growth rate. Compute the autocorrelation of these absolute
values at each lag in `lags` with the course `sample_autocorrelation` function, which takes the
data and the vector of lags, and returns one autocorrelation for each lag. Average these
autocorrelations.

### Course references

- Course example 'The Farmer–Joshi Market', Task 2: the plot cell that calls `sample_autocorrelation`
  on `abs.(g)`.
- PS6 companion: slide 8, 'Volatility clustering'.
"""
function volatility_clustering(g::Vector{Float64}, lags::Vector{Int})::Float64

    # TODO 1: Compute the autocorrelation of abs.(g) at each lag in lags.
    # Hint: sample_autocorrelation(abs.(g), lags).
    autocorrelations = error("Complete volatility_clustering: compute the autocorrelations of abs.(g).");

    # TODO 2: Average the autocorrelations over the lags.
    # Hint: mean(autocorrelations).
    ρ = error("Complete volatility_clustering: average the autocorrelations.");

    return ρ;
end
