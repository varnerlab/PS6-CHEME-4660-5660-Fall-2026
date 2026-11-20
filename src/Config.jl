# PS6 settings: read a TOML settings file and check every value.
using TOML, SHA

"""
    config_setting(settings::Dict, key::String, T::Type)

Read one setting from a parsed TOML file and convert it to type `T`.

### Arguments

- `settings`: The parsed TOML file, from `TOML.parsefile`.
- `key`: The name of the setting.
- `T`: The type the setting must have, such as `Float64`, `Int`, or `String`.

### Returns

- The setting converted to `T`. Throws an `ArgumentError` when the setting is
  missing or cannot be converted. An integer setting must be written as a whole
  number (`60`, not `60.0`).
"""
function config_setting(settings::Dict, key::String, T::Type)

    # Is the setting in the file?
    if !haskey(settings, key)
        throw(ArgumentError("Setting '$key' is missing from the config file."));
    end
    value = settings[key];

    # Integer settings must be written as whole numbers -
    if T <: Integer && !(value isa Integer)
        throw(ArgumentError("Setting '$key' must be a whole number."));
    end

    # Convert the value to T -
    try
        return T(value);
    catch
        throw(ArgumentError("Setting '$key' must be a number."));
    end
end

"""
    check_setting(ok::Bool, message::String)

Throw an `ArgumentError` with `message` when a setting fails a check.
"""
function check_setting(ok::Bool, message::String)
    if !ok
        throw(ArgumentError(message));
    end
    return nothing;
end

"""
    config_list(settings::Dict, key::String, T::Type) -> Vector

Read one list setting from a parsed TOML file and convert each entry to type `T`.

### Arguments

- `settings`: The parsed TOML file, from `TOML.parsefile`.
- `key`: The name of the setting.
- `T`: The type of each entry, such as `Int` or `Float64`.

### Returns

- A `Vector{T}` with the entries of the list. Throws an `ArgumentError` when the
  setting is missing, is not a list, or has an entry that cannot be converted.
  An integer entry must be written as a whole number.
"""
function config_list(settings::Dict, key::String, T::Type)

    # Is the setting in the file, and is it a list?
    if !haskey(settings, key) || !(settings[key] isa AbstractVector)
        throw(ArgumentError("Setting '$key' must be a list of numbers."));
    end

    # Convert each entry, one at a time -
    result = T[];
    for value in settings[key]
        if !(value isa Real) || (T <: Integer && !(value isa Integer))
            if T <: Integer
                throw(ArgumentError("Setting '$key' must be a list of whole numbers."));
            end
            throw(ArgumentError("Setting '$key' must be a list of numbers."));
        end
        push!(result, T(value));
    end
    return result;
end

"""
    expand_lags(first_last::Vector{Int}, key::String, number_of_steps::Int) -> Vector{Int}

Expand a pair `[first, last]` into every lag from the first to the last.

### Arguments

- `first_last`: The first and the last lag, in days.
- `key`: The name of the setting, used in the error message.
- `number_of_steps`: The number of daily steps in a run. Every lag must be shorter.

### Returns

- The lags `first, first+1, ..., last` as a `Vector{Int}`. Throws an `ArgumentError`
  unless `1 ≤ first ≤ last < number_of_steps`.
"""
function expand_lags(first_last::Vector{Int}, key::String, number_of_steps::Int)::Vector{Int}

    # The setting is exactly two numbers -
    check_setting(length(first_last) == 2, "Setting '$key' must list the first and the last lag.");

    # The pair must be a valid range of lags -
    first_lag = first_last[1];
    last_lag = first_last[2];
    check_setting(1 <= first_lag && first_lag <= last_lag && last_lag < number_of_steps,
        "Setting '$key' must satisfy 1 <= first <= last < number_of_steps.");

    # Every lag from the first to the last -
    return collect(first_lag:last_lag);
end

"""
    check_odd_states(value::Int, key::String)

Throw an `ArgumentError` unless `value` is odd and at least 3.
"""
function check_odd_states(value::Int, key::String)
    check_setting(value >= 3 && isodd(value), "Every number of states in '$key' must be odd and at least 3.");
    return nothing;
end

"""
    load_config(path::AbstractString) -> NamedTuple

Read a TOML settings file and check every value.

### Arguments

- `path`: Location of the settings file, such as `config/defaults.toml`.

### Returns

- A `NamedTuple` with the fields `Δt` (one trading day, `1/steps_per_year`, in yr),
  `sigma_S`, `sigma_v`, `mu_v`, `value_number`, `trend_number`, the ranges
  `value_T_min`, `value_T_max`, `value_tau_min`, `value_tau_max`, the same four
  for `trend_`, `value_v_min`, `value_v_max`, `trend_lag_min`, `trend_lag_max`,
  `capital_scale`, `liquidity`, `number_of_steps`, `burn_in`, `base_seed`, `seeds`,
  `short_lags`, `long_lags` (each expanded to every lag from the first to the last),
  `number_of_states`, `expert_states`, `probabilities`, and `benchmark_ticker`.
  Throws an `ArgumentError` with a one-sentence message when a setting is missing
  or invalid.
"""
function load_config(path::AbstractString)::NamedTuple

    # Read the file -
    settings = nothing;
    try
        settings = TOML.parsefile(path);
    catch
        throw(ArgumentError("The config file could not be read as TOML."));
    end

    # Read each scalar setting with its type -
    steps_per_year = config_setting(settings, "steps_per_year", Int);
    sigma_S = config_setting(settings, "sigma_S", Float64);
    sigma_v = config_setting(settings, "sigma_v", Float64);
    mu_v = config_setting(settings, "mu_v", Float64);
    value_number = config_setting(settings, "value_number", Int);
    trend_number = config_setting(settings, "trend_number", Int);
    value_T_min = config_setting(settings, "value_T_min", Float64);
    value_T_max = config_setting(settings, "value_T_max", Float64);
    value_tau_min = config_setting(settings, "value_tau_min", Float64);
    value_tau_max = config_setting(settings, "value_tau_max", Float64);
    trend_T_min = config_setting(settings, "trend_T_min", Float64);
    trend_T_max = config_setting(settings, "trend_T_max", Float64);
    trend_tau_min = config_setting(settings, "trend_tau_min", Float64);
    trend_tau_max = config_setting(settings, "trend_tau_max", Float64);
    value_v_min = config_setting(settings, "value_v_min", Float64);
    value_v_max = config_setting(settings, "value_v_max", Float64);
    trend_lag_min = config_setting(settings, "trend_lag_min", Int);
    trend_lag_max = config_setting(settings, "trend_lag_max", Int);
    capital_scale = config_setting(settings, "capital_scale", Float64);
    liquidity = config_setting(settings, "liquidity", Float64);
    number_of_steps = config_setting(settings, "number_of_steps", Int);
    burn_in = config_setting(settings, "burn_in", Int);
    base_seed = config_setting(settings, "base_seed", Int);
    expert_states = config_setting(settings, "expert_states", Int);
    benchmark_ticker = config_setting(settings, "benchmark_ticker", String);

    # Read each list setting -
    seeds = config_list(settings, "seeds", Int);
    short_pair = config_list(settings, "short_lags", Int);
    long_pair = config_list(settings, "long_lags", Int);
    number_of_states = config_list(settings, "number_of_states", Int);
    probabilities = config_list(settings, "probabilities", Float64);

    # Check that each value makes sense -
    check_setting(steps_per_year >= 1, "The steps_per_year must be at least 1.");
    check_setting(sigma_S >= 0, "The sigma_S must not be negative.");
    check_setting(sigma_v >= 0, "The sigma_v must not be negative.");
    check_setting(value_number >= 0, "The value_number must not be negative.");
    check_setting(trend_number >= 0, "The trend_number must not be negative.");
    check_setting(value_number + trend_number > 0, "The value_number and trend_number must not both be zero.");
    check_setting(0 < value_T_min && value_T_min <= value_T_max,
        "The value_T_min must be positive and not above value_T_max.");
    check_setting(value_tau_min <= value_tau_max && value_tau_max < value_T_min,
        "The value_tau_min must not exceed value_tau_max, and value_tau_max must be below value_T_min.");
    check_setting(0 < trend_T_min && trend_T_min <= trend_T_max,
        "The trend_T_min must be positive and not above trend_T_max.");
    check_setting(trend_tau_min <= trend_tau_max && trend_tau_max < trend_T_min,
        "The trend_tau_min must not exceed trend_tau_max, and trend_tau_max must be below trend_T_min.");
    check_setting(value_v_min <= value_v_max, "The value_v_min must not exceed value_v_max.");
    check_setting(1 <= trend_lag_min && trend_lag_min <= trend_lag_max,
        "The trend_lag_min must be at least 1 and not above trend_lag_max.");
    check_setting(capital_scale > 0, "The capital_scale must be positive.");
    check_setting(liquidity > 0, "The liquidity must be positive.");
    check_setting(number_of_steps >= 100, "The number_of_steps must be at least 100.");
    check_setting(burn_in >= 0, "The burn_in must not be negative.");
    check_setting(!isempty(seeds), "The seeds list must not be empty.");
    check_setting(!isempty(number_of_states), "The number_of_states list must not be empty.");
    check_setting(!isempty(probabilities), "The probabilities list must not be empty.");
    check_setting(!isempty(benchmark_ticker), "The benchmark_ticker must not be empty.");

    # Every number of states is odd and at least 3 -
    for value in number_of_states
        check_odd_states(value, "number_of_states");
    end
    check_odd_states(expert_states, "expert_states");

    # Every probability is above 0 and at most 1 -
    for value in probabilities
        check_setting(0 < value && value <= 1, "Every probability in 'probabilities' must be above 0 and at most 1.");
    end

    # Expand each pair of first and last lag into the full range of lags -
    short_lags = expand_lags(short_pair, "short_lags", number_of_steps);
    long_lags = expand_lags(long_pair, "long_lags", number_of_steps);

    # The settings, with the time step of one trading day -
    return (Δt = 1.0 / steps_per_year, sigma_S = sigma_S, sigma_v = sigma_v, mu_v = mu_v,
        value_number = value_number, trend_number = trend_number,
        value_T_min = value_T_min, value_T_max = value_T_max,
        value_tau_min = value_tau_min, value_tau_max = value_tau_max,
        trend_T_min = trend_T_min, trend_T_max = trend_T_max,
        trend_tau_min = trend_tau_min, trend_tau_max = trend_tau_max,
        value_v_min = value_v_min, value_v_max = value_v_max,
        trend_lag_min = trend_lag_min, trend_lag_max = trend_lag_max,
        capital_scale = capital_scale, liquidity = liquidity,
        number_of_steps = number_of_steps, burn_in = burn_in, base_seed = base_seed,
        seeds = seeds, short_lags = short_lags, long_lags = long_lags,
        number_of_states = number_of_states, expert_states = expert_states,
        probabilities = probabilities, benchmark_ticker = benchmark_ticker);
end

"""
    config_hash(path::AbstractString) -> String

Compute the SHA-256 hash of a settings file, so a run records exactly which settings it used.

### Returns

- The SHA-256 hash of the file as a 64-character hex string. Windows line
  endings are changed to `\\n` first, so a copy saved on Windows has the same
  hash.
"""
function config_hash(path::AbstractString)::String

    # Use the same line endings on every operating system, then hash the text -
    text = replace(read(path, String), "\r\n" => "\n");
    return bytes2hex(sha256(text));
end
