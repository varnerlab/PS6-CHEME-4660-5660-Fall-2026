# PS6 Expert: complete the 6 functions below: the 4 Advanced functions and 2 for hesitant traders.
# The simulator calls three_state_rule for every trader at every step of the first table and
# conviction_rule for every trader at every step of the second table. In the Expert table, it
# calls hesitant_rule only when p is below 1. The report calls excess_kurtosis and
# volatility_clustering on the growth rates of each market and transition_matrix for the
# expected number of steps to a long position.
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
    for value in g
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
    values = error("Complete volatility_clustering: compute the autocorrelations of abs.(g).");

    # TODO 2: Average the autocorrelations over the lags.
    # Hint: mean(values).
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
- In state `K`, the trader exits to the lean-long state `K - 1` when `z` is below `τ`. Otherwise the trader
  stays in state `K`.
- In state `-K`, the trader exits to the lean-short state `-(K - 1)` when `z` is above `-τ`. Otherwise the
  trader stays in state `-K`.

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

"""
    hesitant_rule(state::Int, proposed::Int, p::Float64, u::Float64) -> Int

Give a hesitant trader's next state: the trader moves to the proposed state only with probability `p`.

### Arguments

- `state`: The trader's current state.
- `proposed`: The state that `conviction_rule` proposes for the trader.
- `p`: The probability that the trader moves to the proposed state (between `0` and `1`).
- `u`: A random number drawn uniformly on [0, 1). The simulator draws one `u` for every trader at every step.

### Returns

- The trader's next state: `proposed` or `state`.

### Method

The trader moves to the proposed state when the proposed state differs from the current state and `u < p`.
Otherwise the trader stays in the current state. Entries and exits are both hesitant.

### Course references

- Course lecture L13a, section 'Markov Chains and Hidden Markov Models'.
- PS6 companion: slide 11, 'Hesitant traders'.
"""
function hesitant_rule(state::Int, proposed::Int, p::Float64, u::Float64)::Int

    # TODO 1: Return proposed when proposed differs from state and u is below p.
    # Hint: use one if-block with both conditions joined by &&.
    error("Complete hesitant_rule: the hesitant move.");

    # Otherwise the trader stays in the current state -
    return state;
end

"""
    transition_matrix(z::Float64, T::Float64, τ::Float64, K::Int, p::Float64) -> Matrix{Float64}

Give the one-step transition matrix of one trader's state at a fixed signal `z`.

### Arguments

- `z`: The trader's signal (dimensionless), held fixed.
- `T`: The trader's entry threshold (dimensionless, positive).
- `τ`: The trader's exit threshold (dimensionless, below `T`).
- `K`: The top state (positive integer). The trader has `2K + 1` states.
- `p`: The probability that the trader moves to the proposed state (between `0` and `1`).

### Returns

- `P`: The `(2K + 1) × (2K + 1)` transition matrix. Row and column `i` hold state `i - K - 1`, so `P[i, j]`
  is the probability of moving from state `i - K - 1` to state `j - K - 1`.

### Method

Each row puts probability `p` in the state that `conviction_rule` proposes and probability `1 - p` on
staying in the current state. When the proposed state equals the current state, the row puts probability `1`
on staying.

### Course references

- Course lecture L13a, section 'Markov Chains and Hidden Markov Models'.
- PS6 companion: slide 12, 'The transition matrix of one trader'.
"""
function transition_matrix(z::Float64, T::Float64, τ::Float64, K::Int, p::Float64)::Matrix{Float64}

    # A (2K + 1) × (2K + 1) matrix of zeros -
    number_of_states = 2 * K + 1;
    P = zeros(number_of_states, number_of_states);

    # Fill one row for each state -
    for i in 1:number_of_states

        # The state of row i, and the state that conviction_rule proposes -
        state = i - K - 1;
        proposed = conviction_rule(state, z, T, τ, K);

        # TODO 1: When proposed equals state, put 1.0 in column i. Otherwise put p in the column of
        # the proposed state and 1.0 - p in column i.
        # Hint: the column of state r is r + K + 1.
        error("Complete transition_matrix: fill row $(i).");
    end

    return P;
end
