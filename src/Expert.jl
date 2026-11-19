# PS6 Expert: complete the 6 functions below: the 4 Advanced functions and 2 for hesitant traders.
# The simulator calls conviction_rung and hesitant_rung for every trader at every step, and the
# report calls excess_kurtosis and volatility_clustering on the growth rates of each market and
# transition_matrix for the expected number of steps to a long position.
# Keep the function names, arguments, return types, and docstrings.
# Replace each error("Complete ...") expression with your calculation.
# The return statements are supplied.
# Save your code, then run from the PS6 folder:
# julia --project=. --startup-file=no check_submission.jl
#
# Each docstring ends with Course references: the part of the course material that does the
# same calculation, and the matching slide in the PS6 mathematical companion. Copy only the
# lines you need and rename variables to match this file.

"""
    three_state_rung(rung::Int, z::Float64, T::Float64, τ::Float64) -> Int

Give a trader's next rung in the three-state Farmer–Joshi rule.

### Arguments

- `rung`: The trader's current rung: `-1` (short), `0` (flat), or `1` (long).
- `z`: The trader's signal (dimensionless). A positive `z` favors a long position.
- `T`: The trader's entry threshold (dimensionless, positive).
- `τ`: The trader's exit threshold (dimensionless, below `T`).

### Returns

- The trader's next rung: `-1`, `0`, or `1`.

### Method

All comparisons are strict.

- From rung `0`, the trader enters a long position (rung `1`) when `z` is above `T`, and enters a
  short position (rung `-1`) when `z` is below `-T`. Otherwise the trader stays on rung `0`.
- From rung `1`, the trader exits to rung `0` when `z` is below `τ`. Otherwise the trader stays on rung `1`.
- From rung `-1`, the trader exits to rung `0` when `z` is above `-τ`. Otherwise the trader stays on rung `-1`.

### Course references

- Course lecture L12a, section 'The Farmer–Joshi algorithm'.
- PS6 companion: slide [SLIDE], 'The three-state rule'.
"""
function three_state_rung(rung::Int, z::Float64, T::Float64, τ::Float64)::Int

    # TODO 1: From rung 0, return 1 when z is above T, return -1 when z is below -T, and
    # otherwise return 0.
    # Hint: use an if-block on rung == 0, with one if-block inside it for each entry.
    error("Complete three_state_rung: the entry rule from rung 0.");

    # TODO 2: From rung 1, return 0 when z is below τ, and otherwise return 1.
    error("Complete three_state_rung: the exit rule from rung 1.");

    # TODO 3: From rung -1, return 0 when z is above -τ, and otherwise return -1.
    error("Complete three_state_rung: the exit rule from rung -1.");
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
- PS6 companion: slide [SLIDE], 'Fat tails: excess kurtosis'.
"""
function excess_kurtosis(g::Vector{Float64})::Float64

    # TODO 1: Compute the mean and the population standard deviation of g.
    # Hint: mean(g) and std(g, corrected = false).
    center = error("Complete excess_kurtosis: compute the mean of g.");
    spread = error("Complete excess_kurtosis: compute the population standard deviation of g.");

    # TODO 2: Average the fourth power of each standardized growth rate over g, then subtract 3.0.
    # Hint: use a for loop that adds ((value - center) / spread)^4 to a running total.
    κ = error("Complete excess_kurtosis: compute the fourth standardized moment minus 3.");

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
- PS6 companion: slide [SLIDE], 'Volatility clustering'.
"""
function volatility_clustering(g::Vector{Float64}, lags::Vector{Int})::Float64

    # TODO 1: Compute the autocorrelation of abs.(g) at each lag in lags.
    # Hint: sample_autocorrelation(abs.(g), lags).
    values = error("Complete volatility_clustering: compute the autocorrelations of abs.(g).");

    # TODO 2: Average the autocorrelations over the lags.
    ρ = error("Complete volatility_clustering: average the autocorrelations.");

    return ρ;
end

"""
    conviction_rung(rung::Int, z::Float64, T::Float64, τ::Float64, K::Int) -> Int

Give a trader's next rung on the conviction ladder, which runs from `-K` to `K`.

### Arguments

- `rung`: The trader's current rung, from `-K` to `K`. The trader holds a long position only on rung `K`,
  a short position only on rung `-K`, and no position on every other rung.
- `z`: The trader's signal (dimensionless). A positive `z` favors a long position.
- `T`: The trader's entry threshold (dimensionless, positive).
- `τ`: The trader's exit threshold (dimensionless, below `T`).
- `K`: The top rung of the ladder (positive integer). The ladder has `2K + 1` rungs.

### Returns

- The trader's next rung, from `-K` to `K`.

### Method

All comparisons are strict.

- On a flat rung (`-K < rung < K`), the trader moves one rung up when `z` is above `T`, and one rung down
  when `z` is below `-T`. Otherwise conviction fades: the trader moves one rung toward rung `0`, and stays
  on rung `0` if the trader is already there.
- On rung `K`, the trader exits to the lean-long rung `K - 1` when `z` is below `τ`. Otherwise the trader
  stays on rung `K`.
- On rung `-K`, the trader exits to the lean-short rung `-(K - 1)` when `z` is above `-τ`. Otherwise the
  trader stays on rung `-K`.

With `K = 1`, this rule gives the Standard three-state rule for every input.

### Course references

- Course lecture L12a, section 'The Farmer–Joshi algorithm'.
- PS6 companion: slide [SLIDE], 'The conviction ladder'.
"""
function conviction_rung(rung::Int, z::Float64, T::Float64, τ::Float64, K::Int)::Int

    # TODO 1: On rung K, return K - 1 when z is below τ, and otherwise return K.
    error("Complete conviction_rung: the exit rule from rung K.");

    # TODO 2: On rung -K, return -(K - 1) when z is above -τ, and otherwise return -K.
    error("Complete conviction_rung: the exit rule from rung -K.");

    # TODO 3: On a flat rung, return rung + 1 when z is above T, and return rung - 1 when z is below -T.
    error("Complete conviction_rung: the entry rule on a flat rung.");

    # TODO 4: Otherwise return the rung one step closer to 0: rung - 1 above 0, rung + 1 below 0, and 0 on rung 0.
    error("Complete conviction_rung: the fade toward rung 0.");
end

"""
    hesitant_rung(rung::Int, proposed::Int, p::Float64, u::Float64) -> Int

Give a hesitant trader's next rung: the trader moves to the proposed rung only with probability `p`.

### Arguments

- `rung`: The trader's current rung.
- `proposed`: The rung that `conviction_rung` proposes for the trader.
- `p`: The probability that the trader moves to the proposed rung (between `0` and `1`).
- `u`: A random number drawn uniformly on [0, 1). The simulator draws one `u` for every trader at every step.

### Returns

- The trader's next rung: `proposed` or `rung`.

### Method

The trader moves to the proposed rung when the proposed rung differs from the current rung and `u < p`.
Otherwise the trader stays on the current rung. Entries and exits are both hesitant.

### Course references

- Course lecture L13a, section 'Markov Chains and Hidden Markov Models'.
- PS6 companion: slide [SLIDE], 'Hesitant traders'.
"""
function hesitant_rung(rung::Int, proposed::Int, p::Float64, u::Float64)::Int

    # TODO 1: Return proposed when proposed differs from rung and u is below p, and otherwise return rung.
    # Hint: use one if-block with both conditions.
    error("Complete hesitant_rung: the hesitant move.");
end

"""
    transition_matrix(z::Float64, T::Float64, τ::Float64, K::Int, p::Float64) -> Matrix{Float64}

Give the one-step transition matrix of one trader's rung at a fixed signal `z`.

### Arguments

- `z`: The trader's signal (dimensionless), held fixed.
- `T`: The trader's entry threshold (dimensionless, positive).
- `τ`: The trader's exit threshold (dimensionless, below `T`).
- `K`: The top rung of the ladder (positive integer). The ladder has `2K + 1` rungs.
- `p`: The probability that the trader moves to the proposed rung (between `0` and `1`).

### Returns

- `P`: The `(2K + 1) × (2K + 1)` transition matrix. Row and column `i` hold rung `i - K - 1`, so `P[i, j]`
  is the probability of moving from rung `i - K - 1` to rung `j - K - 1`.

### Method

Each row puts probability `p` on the rung that `conviction_rung` proposes and probability `1 - p` on
staying on the current rung. When the proposed rung equals the current rung, the row puts probability `1`
on staying.

### Course references

- Course lecture L13a, section 'Markov Chains and Hidden Markov Models'.
- PS6 companion: slide [SLIDE], 'The transition matrix of one trader'.
"""
function transition_matrix(z::Float64, T::Float64, τ::Float64, K::Int, p::Float64)::Matrix{Float64}

    # TODO 1: Build a (2K + 1) × (2K + 1) matrix of zeros.
    number_of_rungs = 2 * K + 1;
    P = zeros(number_of_rungs, number_of_rungs);

    # TODO 2: For each row i, find the current rung (i - K - 1) and the rung that conviction_rung proposes.
    # Put p in the column of the proposed rung and 1 - p in column i, or 1 in column i when the two rungs match.
    # Hint: the column of rung r is r + K + 1.
    for i in 1:number_of_rungs
        error("Complete transition_matrix: fill row $(i).");
    end

    return P;
end
