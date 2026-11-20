# PS6 facts: the statistics of a market's growth rates.
# This file is supplied. Do not edit it.

"""
    growth_rates(log_price::Vector{Float64}, Δt::Float64) -> Vector{Float64}

Compute the growth rate of the price at each step, `diff(log_price) / Δt` (1/yr).
"""
function growth_rates(log_price::Vector{Float64}, Δt::Float64)::Vector{Float64}
    return diff(log_price) ./ Δt;
end

"""
    lag_one_autocorrelation(g::Vector{Float64}) -> Float64

Compute the autocorrelation of the growth rates `g` at lag 1, with the course `sample_autocorrelation`.
"""
function lag_one_autocorrelation(g::Vector{Float64})::Float64
    return sample_autocorrelation(g, [1])[1];
end

"""
    annualized_volatility(g::Vector{Float64}, Δt::Float64) -> Float64

Compute the standard deviation of the growth rates `g` times `sqrt(Δt)`, the volatility in 1/sqrt(yr).
"""
function annualized_volatility(g::Vector{Float64}, Δt::Float64)::Float64
    return std(g) * sqrt(Δt);
end

"""
    white_noise_band(n::Int) -> Float64

Compute the 95 percent band, `1.96 / sqrt(n)`, inside which the autocorrelations of `n` white-noise values fall.
"""
function white_noise_band(n::Int)::Float64
    return 1.96 / sqrt(n);
end

"""
    benchmark_growth_rates(settings::NamedTuple) -> Vector{Float64}

Compute the growth rates (1/yr) of the daily closes of the benchmark ticker in the course data set.
"""
function benchmark_growth_rates(settings::NamedTuple)::Vector{Float64}

    # Read the daily closes of the benchmark ticker -
    dataset = MyTrainingMarketDataSet()["dataset"];
    closes = Float64.(dataset[settings.benchmark_ticker].close);

    # Growth rate of the price at each day -
    return growth_rates(log.(closes), settings.Δt);
end

"""
    expected_steps_to_long(P::Matrix{Float64}, K::Int) -> Float64

Compute the expected number of steps for a trader to go from state 0 to state `K`.

### Arguments

- `P`: The one-step transition matrix of the states. Row and column `i` is state `i - K - 1`.
- `K`: The top state. State `K` is treated as absorbing.

### Returns

- The expected number of steps, from the fundamental matrix of the other states.
"""
function expected_steps_to_long(P::Matrix{Float64}, K::Int)::Float64

    # The transition matrix among the states below K -
    number_of_states = 2 * K + 1;
    Q = P[1:(number_of_states - 1), 1:(number_of_states - 1)];

    # The fundamental matrix gives the expected visits to each state before reaching K -
    N = inv(I - Q);

    # Expected steps starting from state 0, which is state K + 1 -
    steps = 0.0;
    for j ∈ 1:(number_of_states - 1)
        steps += N[K + 1, j];
    end
    return steps;
end

"""
    market_facts(g::Vector{Float64}, gap::Vector{Float64}, settings::NamedTuple) -> NamedTuple

Summarize one market with the statistics the report compares.

### Arguments

- `g`: The growth rates of the price.
- `gap`: The log price minus the log value.
- `settings`: The settings from `load_config`.

### Returns

- A `NamedTuple` with `kurtosis`, `clustering_short`, `clustering_long`, `lag_one`, `volatility`,
  and `gap_spread` (the standard deviation of `gap`). Every field is `NaN` when a growth rate is not finite or the growth rates have zero variance.
"""
function market_facts(g::Vector{Float64}, gap::Vector{Float64}, settings::NamedTuple)::NamedTuple

    # A frozen or broken price has no statistics -
    broken = false;
    for value ∈ g
        if !isfinite(value)
            broken = true;
        end
    end
    if broken || std(g) == 0.0
        return (kurtosis = NaN, clustering_short = NaN, clustering_long = NaN,
            lag_one = NaN, volatility = NaN, gap_spread = NaN);
    end

    # Statistics that use your functions -
    kurtosis = excess_kurtosis(g);
    clustering_short = volatility_clustering(g, settings.short_lags);
    clustering_long = volatility_clustering(g, settings.long_lags);

    # Supplied statistics -
    return (kurtosis = kurtosis, clustering_short = clustering_short, clustering_long = clustering_long,
        lag_one = lag_one_autocorrelation(g), volatility = annualized_volatility(g, settings.Δt),
        gap_spread = std(gap));
end
