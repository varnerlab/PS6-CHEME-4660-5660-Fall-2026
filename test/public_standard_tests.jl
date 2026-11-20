# The PS6 public checks for the Standard track.
#
# Each check is a named tuple with two fields:
#   name - what the check tests, as the checker prints it
#   test - the function that runs the check; it returns true when the check passes
# run_public_check in test/Rubric.jl runs one check. Each check calls one student function, so
# an unfinished function does not block the checks of the others.

"""
    ps6_regime_growth_rates() -> Vector{Float64}

A fixed series of 5,000 growth rates with volatility regimes: blocks of 500 steps that alternate
between a standard deviation of 0.5 and a standard deviation of 2.0.
"""
function ps6_regime_growth_rates()::Vector{Float64}

    # Draw each block of 500 steps with the standard deviation of its regime -
    rng = Xoshiro(11);
    g = zeros(5000);
    for k ∈ 1:5000
        block = div(k - 1, 500);
        if iseven(block)
            g[k] = 0.5 * randn(rng);
        else
            g[k] = 2.0 * randn(rng);
        end
    end
    return g;
end

# --- three_state_rule checks ---

"""
    check_three_state_matches_course() -> Bool

`three_state_rule` matches the course `threshold_position` for three pairs of thresholds
`(T, τ)`, every state, and a grid of signals that includes `T`, `-T`, `τ`, and `-τ`.
"""
function check_three_state_matches_course()::Bool

    # Compare three_state_rule with the course function on every case -
    for (T, τ) ∈ ((0.5, -0.1), (2.0, 0.0), (3.7, -0.2))
        signals = vcat(collect(range(-5, 5, length = 201)), [T, -T, τ, -τ]);
        for state ∈ -1:1
            for z ∈ signals
                expected = Int(threshold_position(Float64(state), z, T, τ, 1.0, 1));
                if three_state_rule(state, z, T, τ) != expected
                    return false;
                end
            end
        end
    end
    return true;
end

"""
    check_three_state_strict() -> Bool

A signal exactly at a threshold does not move the trader: all comparisons are strict.
"""
function check_three_state_strict()::Bool

    # From state 0, a signal exactly at T or at -T does not enter a position -
    if three_state_rule(0, 2.0, 2.0, 0.0) != 0
        return false;
    end
    if three_state_rule(0, -2.0, 2.0, 0.0) != 0
        return false;
    end

    # From state 1, a signal exactly at τ does not exit -
    if three_state_rule(1, -0.1, 2.0, -0.1) != 1
        return false;
    end

    # From state -1, a signal exactly at -τ does not exit -
    return three_state_rule(-1, 0.1, 2.0, -0.1) == -1;
end

"""
    check_three_state_type() -> Bool

`three_state_rule` returns an `Int` in `-1:1` for 1,000 random inputs, each with an exit threshold below
its entry threshold.
"""
function check_three_state_type()::Bool

    # Draw a random state, signal, entry threshold from 0.3 to 3.3, and exit threshold from -0.2 to 0.2 for each case -
    rng = Xoshiro(5660);
    for i ∈ 1:1000
        state = rand(rng, -1:1);
        result = three_state_rule(state, 6.0 * rand(rng) - 3.0, 3.0 * rand(rng) + 0.3, 0.4 * rand(rng) - 0.2);

        # The next state must be an Int from -1 to 1 -
        if !(result isa Int) || result < -1 || result > 1
            return false;
        end
    end
    return true;
end

"""
    check_three_state_market() -> Bool

A small market with 50 value investors and 50 trend followers that uses `three_state_rule`
reproduces the log price of the course `solve` function.
"""
function check_three_state_market()::Bool

    # Run the same small market with three_state_rule and with the course solve function -
    market = build_market(_SETTINGS, 1; value_number = 50, trend_number = 50);
    ours = simulate_market(market, :three, 1, 1.0; number_of_steps = 500, burn_in = 100, seed = 1);
    course = solve(market; number_of_steps = 500, burn_in = 100, rng = Xoshiro(2));

    # The two log prices must be identical -
    return ours.log_price == course.log_price;
end

# --- excess_kurtosis checks ---

"""
    check_kurtosis_by_hand() -> Bool

For the growth rates `[1, 2, 3, 4, 10]`, the excess kurtosis is -0.212, from population moments.
"""
function check_kurtosis_by_hand()::Bool
    return isapprox(excess_kurtosis([1.0, 2.0, 3.0, 4.0, 10.0]), -0.212; atol = 1e-12);
end

"""
    check_kurtosis_shift_scale() -> Bool

Adding a constant to the growth rates and multiplying them by a positive constant does not
change the excess kurtosis.
"""
function check_kurtosis_shift_scale()::Bool

    # Compare the kurtosis of 1,000 Normal draws with the kurtosis of 3g + 7 -
    g = randn(Xoshiro(7), 1000);
    return isapprox(excess_kurtosis(3.0 .* g .+ 7.0), excess_kurtosis(g); rtol = 1e-10);
end

"""
    check_kurtosis_normal() -> Bool

The excess kurtosis of 200,000 Normal draws is within 0.05 of zero.
"""
function check_kurtosis_normal()::Bool
    return abs(excess_kurtosis(randn(Xoshiro(5660), 200_000))) < 0.05;
end

"""
    check_kurtosis_type_and_input() -> Bool

`excess_kurtosis` returns a `Float64` and leaves its input unchanged.
"""
function check_kurtosis_type_and_input()::Bool

    # Keep a copy of the input, then compute the kurtosis -
    g = randn(Xoshiro(21), 100);
    copy_of_g = copy(g);
    result = excess_kurtosis(g);

    # The result must be a Float64, and the input must be unchanged -
    return result isa Float64 && g == copy_of_g;
end

# --- volatility_clustering checks ---

"""
    check_clustering_matches_course() -> Bool

For a fixed series with volatility regimes, `volatility_clustering` equals the mean of the
course `sample_autocorrelation` of the absolute growth rates over the lags 1 to 10.
"""
function check_clustering_matches_course()::Bool

    # The expected value: the mean course autocorrelation of abs.(g) over the lags 1 to 10 -
    g = ps6_regime_growth_rates();
    lags = collect(1:10);
    expected = mean(sample_autocorrelation(abs.(g), lags));

    # The student's clustering must equal the expected value -
    return isapprox(volatility_clustering(g, lags), expected; atol = 1e-12);
end

"""
    check_clustering_white_noise() -> Bool

For 100,000 independent Normal draws, the clustering over the lags 1 to 10 is within 0.01 of zero.
"""
function check_clustering_white_noise()::Bool
    return abs(volatility_clustering(randn(Xoshiro(3), 100_000), collect(1:10))) < 0.01;
end

"""
    check_clustering_regimes() -> Bool

For the fixed series with volatility regimes, the clustering over the lags 1 to 10 is above 0.1.
"""
function check_clustering_regimes()::Bool
    return volatility_clustering(ps6_regime_growth_rates(), collect(1:10)) > 0.1;
end

"""
    check_clustering_lags() -> Bool

`volatility_clustering` averages over exactly the lags passed: for the lags 1, 5, and 20 it equals
the mean of those three autocorrelations, and the input is unchanged.
"""
function check_clustering_lags()::Bool

    # The expected value over the lags 1, 5, and 20 only, with a copy of the input -
    g = ps6_regime_growth_rates();
    copy_of_g = copy(g);
    lags = [1, 5, 20];
    expected = mean(sample_autocorrelation(abs.(g), lags));

    # The clustering must equal the expected value, and the input must be unchanged -
    result = volatility_clustering(g, lags);
    return isapprox(result, expected; atol = 1e-12) && g == copy_of_g;
end

"""
    standard_public_checks() -> Vector{NamedTuple}

The twelve Standard public checks: four for each of `three_state_rule`, `excess_kurtosis`, and
`volatility_clustering`.
"""
function standard_public_checks()::Vector{NamedTuple}

    # The name the checker prints, and the function that runs each check -
    return NamedTuple[
        (name = "Three-state rule: matches the course threshold rule", test = check_three_state_matches_course),
        (name = "Three-state rule: a signal at a threshold does not move the trader", test = check_three_state_strict),
        (name = "Three-state rule: returns an Int in -1:1", test = check_three_state_type),
        (name = "Three-state rule: a small market matches the course solve function", test = check_three_state_market),
        (name = "Excess kurtosis: hand-computed value for [1, 2, 3, 4, 10]", test = check_kurtosis_by_hand),
        (name = "Excess kurtosis: unchanged by a shift and a positive scale", test = check_kurtosis_shift_scale),
        (name = "Excess kurtosis: near zero for a Normal sample", test = check_kurtosis_normal),
        (name = "Excess kurtosis: returns a Float64 and leaves the input unchanged", test = check_kurtosis_type_and_input),
        (name = "Volatility clustering: matches the mean autocorrelation of abs.(g)", test = check_clustering_matches_course),
        (name = "Volatility clustering: near zero for white noise", test = check_clustering_white_noise),
        (name = "Volatility clustering: positive for volatility regimes", test = check_clustering_regimes),
        (name = "Volatility clustering: averages over exactly the lags passed", test = check_clustering_lags),
    ]
end
