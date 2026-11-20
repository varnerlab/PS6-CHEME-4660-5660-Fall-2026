# PS6 market: the Farmer-Joshi market, written as a loop that calls your functions for each trader's next state.
# This file is supplied. Do not edit it, except to try the noise traders in a copy of your PS6 folder.

"""
    build_market(settings::NamedTuple, seed::Int; value_number::Int = settings.value_number,
        trend_number::Int = settings.trend_number) -> MyFarmerJoshiMarketModel

Draw the traders of one market with the course `build` function.

### Arguments

- `settings`: The settings from `load_config`.
- `seed`: The run number. The traders are drawn from a random generator seeded with `base_seed + seed`.
- `value_number`: The number of value investors. The default is the number in `settings`.
- `trend_number`: The number of trend followers. The default is the number in `settings`.

### Returns

- The market model, holding each trader's entry threshold, exit threshold, capital, offset or lag.
"""
function build_market(settings::NamedTuple, seed::Int; value_number::Int = settings.value_number,
    trend_number::Int = settings.trend_number)::MyFarmerJoshiMarketModel

    # Collect the settings under the names the course build function reads -
    data = (value_number = value_number, trend_number = trend_number,
        value_T_min = settings.value_T_min, value_T_max = settings.value_T_max,
        value_τ_min = settings.value_tau_min, value_τ_max = settings.value_tau_max,
        trend_T_min = settings.trend_T_min, trend_T_max = settings.trend_T_max,
        trend_τ_min = settings.trend_tau_min, trend_τ_max = settings.trend_tau_max,
        value_a = settings.capital_scale, trend_a = settings.capital_scale,
        value_v_min = settings.value_v_min, value_v_max = settings.value_v_max,
        trend_θ_min = settings.trend_lag_min, trend_θ_max = settings.trend_lag_max,
        λ = settings.liquidity, σ_S = settings.sigma_S, σ_v = settings.sigma_v,
        μ_v = settings.mu_v, Δt = settings.Δt, rng = MersenneTwister(settings.base_seed + seed));

    # Draw the traders -
    return build(MyFarmerJoshiMarketModel, data);
end

"""
    state_position(state::Int, K::Int, c::Float64) -> Float64

Convert a trader's state into the position the market sees.

### Arguments

- `state`: The trader's state, a whole number from `-K` to `K`.
- `K`: The top state.
- `c`: The trader's capital.

### Returns

- `c` in state `K` (long), `-c` in state `-K` (short), and `0.0` in every other state.
"""
function state_position(state::Int, K::Int, c::Float64)::Float64

    # Only the top and bottom states hold a position -
    if state == K
        return c;
    end
    if state == -K
        return -c;
    end
    return 0.0;
end

"""
    check_state(state, K::Int, name::String) -> Int

Check that a function returned a state.

### Arguments

- `state`: The value the function returned.
- `K`: The top state.
- `name`: The name of the function, used in the error message.

### Returns

- The state, when it is an `Int` from `-K` to `K`. Otherwise throws an `ArgumentError` that names the function.
"""
function check_state(state, K::Int, name::String)::Int

    # A state is a whole number from -K to K -
    if !(state isa Int) || state < -K || state > K
        throw(ArgumentError("$name returned $state; a state must be a whole number from -$K to $K."));
    end
    return state;
end

"""
    next_state(rule::Symbol, state::Int, z::Float64, T::Float64, τ::Float64, K::Int, p::Float64, u::Float64) -> Int

Find one trader's state for the next step.

### Arguments

- `rule`: `:three` calls `three_state_rule`, and `:conviction` calls `conviction_rule`.
- `state`: The trader's current state.
- `z`: The trader's signal, positive when the signal favors a long position.
- `T`: The trader's entry threshold.
- `τ`: The trader's exit threshold.
- `K`: The top state.
- `p`: The probability that the trader acts on a proposed move.
- `u`: A uniform random number on [0, 1) for this trader and this step.

### Returns

- The next state. Calls `hesitant_rule` only when `p < 1.0`.
"""
function next_state(rule::Symbol, state::Int, z::Float64, T::Float64, τ::Float64, K::Int, p::Float64, u::Float64)::Int

    # Ask the rule for the state it proposes -
    proposed = state;
    if rule == :three
        proposed = check_state(three_state_rule(state, z, T, τ), K, "three_state_rule");
    else
        proposed = check_state(conviction_rule(state, z, T, τ, K), K, "conviction_rule");
    end

    # A trader that always acts takes the proposed state -
    if p >= 1.0
        return proposed;
    end

    # A hesitant trader acts on the proposal only some of the time -
    return check_state(hesitant_rule(state, proposed, p, u), K, "hesitant_rule");
end

"""
    simulate_market(model::MyFarmerJoshiMarketModel, rule::Symbol, K::Int, p::Float64;
        number_of_steps::Int, burn_in::Int, seed::Int) -> NamedTuple

Run one Farmer-Joshi market, with each trader's next state set by your functions.

### Arguments

- `model`: The market from `build_market`.
- `rule`: `:three` (requires `K == 1`) or `:conviction`.
- `K`: The top state. The traders have `2K + 1` states.
- `p`: The probability that a trader acts on a proposed move.
- `number_of_steps`: The number of daily steps kept.
- `burn_in`: The number of first daily steps dropped.
- `seed`: The run number. The price and value noise come from `Xoshiro(seed + 1)`, and the
  uniform numbers for `hesitant_rule` from `Xoshiro(seed + 2)`.

### Returns

- A `NamedTuple` with `log_price` and `log_value`, each `number_of_steps + 1` long.
"""
function simulate_market(model::MyFarmerJoshiMarketModel, rule::Symbol, K::Int, p::Float64;
    number_of_steps::Int, burn_in::Int, seed::Int)::NamedTuple

    # Check the rule and the top state -
    if rule != :three && rule != :conviction
        throw(ArgumentError("The rule must be :three or :conviction."));
    end
    if rule == :three && K != 1
        throw(ArgumentError("The rule :three needs K = 1."));
    end

    # Two random streams, one for the noise and one for the traders' actions -
    noise_rng = Xoshiro(seed + 1);
    action_rng = Xoshiro(seed + 2);

    # Start every trader flat, at log price 0 and log value 0 -
    total = burn_in + number_of_steps;
    log_price = zeros(total + 1);
    log_value = zeros(total + 1);
    value_states = zeros(Int, length(model.value_entry));
    trend_states = zeros(Int, length(model.trend_entry));
    sqrt_dt = sqrt(model.Δt);

    # Just for fun, and not graded: noise traders. To add them, work in a copy of your PS6 folder, and
    # delete the #= and =# lines around this block and around the noise-trader loop below. The noise
    # traders then join every market the simulator runs.
    #=
    # The noise traders: how many, their thresholds, and their position size, the market's capital scale model.a
    # (capital_scale in the settings) times T minus tau -
    noise_number = 1200;
    noise_entry = 1.0;
    noise_exit = 0.0;
    noise_capital = model.a * (noise_entry - noise_exit);
    noise_states = zeros(Int, noise_number);

    # A third random stream, for the noise traders' signals and actions -
    signal_rng = Xoshiro(seed + 3);
    =#

    # One loop pass per daily step -
    for k in 1:total

        # The net demand of every trader this step -
        net = 0.0;

        # Value investors first. A positive signal means the price is below the value.
        for i in eachindex(value_states)
            z = -(log_price[k] - (log_value[k] + model.value_offset[i]));
            u = rand(action_rng);
            old_state = value_states[i];
            new_state = next_state(rule, old_state, z, model.value_entry[i], model.value_exit[i], K, p, u);
            c = model.value_capital[i];
            net += state_position(new_state, K, c) - state_position(old_state, K, c);
            value_states[i] = new_state;
        end

        # Trend followers next. Each trend follower draws its uniform number, then waits until it has a full lag of history.
        for j in eachindex(trend_states)
            u = rand(action_rng);
            lag = model.trend_lag[j];
            if k - 1 >= lag
                z = log_price[k] - log_price[k - lag];
                old_state = trend_states[j];
                new_state = next_state(rule, old_state, z, model.trend_entry[j], model.trend_exit[j], K, p, u);
                c = model.trend_capital[j];
                net += state_position(new_state, K, c) - state_position(old_state, K, c);
                trend_states[j] = new_state;
            end
        end

        # Just for fun: the noise-trader loop. Delete the #= and =# lines to add it, with the block above the loop.
        #=
        # Noise traders last. Each noise trader's signal is a standard Normal random number that the market cannot see.
        for n in eachindex(noise_states)
            z = randn(signal_rng);
            u = rand(signal_rng);
            old_state = noise_states[n];
            new_state = next_state(rule, old_state, z, noise_entry, noise_exit, K, p, u);
            net += state_position(new_state, K, noise_capital) - state_position(old_state, K, noise_capital);
            noise_states[n] = new_state;
        end
        =#

        # The net demand moves the price, and the value takes its own step -
        log_price[k + 1] = log_price[k] + net / model.λ + model.σ_S * sqrt_dt * randn(noise_rng);
        log_value[k + 1] = log_value[k] + model.μ_v * model.Δt + model.σ_v * sqrt_dt * randn(noise_rng);
    end

    # Keep the steps after the burn-in -
    kept = (burn_in + 1):(total + 1);
    return (log_price = log_price[kept], log_value = log_value[kept]);
end
