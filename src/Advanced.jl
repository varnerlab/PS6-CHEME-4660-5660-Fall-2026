# PS6 Advanced: complete the 4 functions below: the 3 Standard functions and 1 for the conviction ladder.
# The simulator calls three_state_rung for every trader at every step of the first table and
# conviction_rung for every trader at every step of the second table. The report calls
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
- PS6 companion: slide 6, 'The three-state rule'.
"""
function three_state_rung(rung::Int, z::Float64, T::Float64, τ::Float64)::Int

    # From rung 0 (flat), the trader enters on a strong signal, and otherwise stays flat -
    if rung == 0
        # TODO 1: Return 1 when z is above T, and return -1 when z is below -T.
        # Hint: write one if-block for each entry.
        error("Complete three_state_rung: the entry rule from rung 0.");
        return 0;
    end

    # From rung 1 (long), the trader exits when the signal falls below τ, and otherwise stays long -
    if rung == 1
        # TODO 2: Return 0 when z is below τ.
        error("Complete three_state_rung: the exit rule from rung 1.");
        return 1;
    end

    # From rung -1 (short), the trader exits when the signal rises above -τ, and otherwise stays short -
    # TODO 3: Return 0 when z is above -τ.
    error("Complete three_state_rung: the exit rule from rung -1.");
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
- PS6 companion: slide 10, 'The conviction ladder'.
"""
function conviction_rung(rung::Int, z::Float64, T::Float64, τ::Float64, K::Int)::Int

    # On the top rung (long), the trader exits to rung K - 1 when the signal falls below τ -
    if rung == K
        # TODO 1: Return K - 1 when z is below τ.
        error("Complete conviction_rung: the exit rule from rung K.");
        return K;
    end

    # On the bottom rung (short), the trader exits to rung -(K - 1) when the signal rises above -τ -
    if rung == -K
        # TODO 2: Return -(K - 1) when z is above -τ.
        error("Complete conviction_rung: the exit rule from rung -K.");
        return -K;
    end

    # On a flat rung, a strong signal moves the trader one rung toward the signal's side -
    # TODO 3: Return rung + 1 when z is above T, and return rung - 1 when z is below -T.
    error("Complete conviction_rung: the entry rule on a flat rung.");

    # Otherwise the trader's conviction fades one rung toward rung 0 -
    if rung > 0
        return rung - 1;
    end
    if rung < 0
        return rung + 1;
    end
    return 0;
end
