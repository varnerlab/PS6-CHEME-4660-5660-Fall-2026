# PS6 Advanced: complete the 4 functions below, the 3 Standard functions and conviction_rule.
# The simulator calls three_state_rule for every trader at every step of the first table, and
# conviction_rule for every trader at every step of the second table. The report calls
# excess_kurtosis and volatility_clustering on the growth rates of each market.
# Keep the function names, arguments, return types, and docstrings.
# Replace each error("Complete ...") line with your calculation. The rest of each function is supplied.
# Save your code, then run from the PS6 folder:
# julia --project=. --startup-file=no check_submission.jl
#
# The Course references at the end of each docstring name the course material that does the same
# calculation, and the companion slide with the formulas. Copy only the lines you need, and rename
# the variables to match this file.

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

"""
    conviction_rule(state::Int, z::Float64, T::Float64, τ::Float64, K::Int) -> Int

Give a trader's next state under the conviction rule, with states from `-K` to `K`.

### Arguments

- `state`: The trader's current state, from `-K` to `K`. The trader holds a long position only in state `K`,
  a short position only in state `-K`, and no position in every other state.
- `z`: The trader's signal (dimensionless). A positive `z` favors a long position.
- `T`: The trader's entry threshold (dimensionless, positive).
- `τ`: The trader's exit threshold (dimensionless, below `T`).
- `K`: The top state (positive integer). The trader has `2K + 1` states.

### Returns

- The trader's next state, from `-K` to `K`.

### Method

All comparisons are strict.

- In a flat state (`-K < state < K`), the trader moves up one state when `z` is above `T`, and down one state
  when `z` is below `-T`. Otherwise conviction fades: the trader moves one state toward state `0`, and stays
  in state `0` if the trader is already there.
- In state `K`, the trader exits to state `K - 1` when `z` is below `τ`. Otherwise the trader stays in
  state `K`.
- In state `-K`, the trader exits to state `-(K - 1)` when `z` is above `-τ`. Otherwise the trader stays in
  state `-K`.

With `K = 1`, this rule gives the Standard three-state rule for every input.

### Course references

- Course lecture L12a, section 'The Farmer–Joshi algorithm'.
- PS6 companion: slide 10, 'The conviction rule'.
"""
function conviction_rule(state::Int, z::Float64, T::Float64, τ::Float64, K::Int)::Int

    # In the top state (long), the trader exits to state K - 1 when the signal falls below τ -
    if state == K
        # TODO 1: Return K - 1 when z is below τ.
        error("Complete conviction_rule: the exit rule from state K.");
        return K;
    end

    # In the bottom state (short), the trader exits to state -(K - 1) when the signal rises above -τ -
    if state == -K
        # TODO 2: Return -(K - 1) when z is above -τ.
        error("Complete conviction_rule: the exit rule from state -K.");
        return -K;
    end

    # In a flat state, a strong signal moves the trader one state toward the signal's side -
    # TODO 3: Return state + 1 when z is above T, and return state - 1 when z is below -T.
    error("Complete conviction_rule: the entry rule in a flat state.");

    # Otherwise the trader's conviction fades one state toward state 0 -
    if state > 0
        return state - 1;
    end
    if state < 0
        return state + 1;
    end
    return 0;
end
