# PS6 settings: read a TOML settings file and check every value.
using TOML, SHA

# The columns of the FRED file, data/fred-levels-2014-2024.csv -
const FRED_COLUMNS = ["DGS10", "T10YIE", "DCOILBRENTEU", "DTWEXBGS"];

# The 11 sectors of the Global Industry Classification Standard (GICS) -
const GICS_SECTORS = ["Communication Services", "Consumer Discretionary", "Consumer Staples", "Energy",
    "Financials", "Health Care", "Industrials", "Information Technology", "Materials", "Real Estate", "Utilities"];

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
  number (`100`, not `100.0`).
"""
function config_setting(settings::Dict, key::String, T::Type)

    # Is the setting in the file?
    if !haskey(settings, key)
        throw(ArgumentError("Setting '$key' is missing from the config file."));
    end
    value = settings[key];

    # A number setting cannot be true or false -
    if T <: Number && value isa Bool
        throw(ArgumentError("Setting '$key' must be a number, not true or false."));
    end

    # Integer settings must be written as whole numbers -
    if T <: Integer && !(value isa Integer)
        throw(ArgumentError("Setting '$key' must be a whole number."));
    end

    # Convert the value to T; a text setting such as benchmark_ticker needs quotes -
    try
        return T(value);
    catch
        if T == String
            throw(ArgumentError("Setting '$key' must be text in quotes."));
        end
        throw(ArgumentError("Setting '$key' must be a number."));
    end
end

"""
    config_list(settings::Dict, key::String) -> Vector{String}

Read one list of text values from a parsed TOML file.

### Arguments

- `settings`: The parsed TOML file, from `TOML.parsefile`.
- `key`: The name of the setting.

### Returns

- A `Vector{String}` with the entries of the list. Throws an `ArgumentError` when
  the setting is missing, is not a list, or has an entry that is not text in quotes.
"""
function config_list(settings::Dict, key::String)::Vector{String}

    # Is the setting in the file, and is it a list?
    if !haskey(settings, key) || !(settings[key] isa AbstractVector)
        throw(ArgumentError("Setting '$key' must be a list of text values in quotes."));
    end

    # Copy each entry, one at a time; every entry must be text -
    result = String[];
    for value ∈ settings[key]
        if !(value isa AbstractString)
            throw(ArgumentError("Setting '$key' must be a list of text values in quotes."));
        end
        push!(result, String(value));
    end
    return result;
end

"""
    check_setting(ok::Bool, message::String)

Throw an `ArgumentError` with `message` when a setting fails a check.
"""
function check_setting(ok::Bool, message::String)

    # Stop with the message when the check fails -
    if !ok
        throw(ArgumentError(message));
    end
    return nothing;
end

"""
    load_config(path::AbstractString) -> NamedTuple

Read a TOML settings file and check every value.

### Arguments

- `path`: Location of the settings file, such as `config/defaults.toml`.

### Returns

- A `NamedTuple` with the fields `Δt` (one trading day, `1/steps_per_year`, in yr),
  `number_of_states`, `ν`, `ϵ`, and `λ` (the settings of each jump hidden Markov
  model), `number_of_paths`, `seed`, `benchmark_ticker`, the FRED lists
  `fred_series`, `fred_kinds`, and `fred_names`, and the sector lists `pair_first`
  and `pair_second`. Throws an `ArgumentError` with a one-sentence message when a
  setting is missing or not valid.
"""
function load_config(path::AbstractString)::NamedTuple

    # Read the file -
    settings = nothing;
    try
        settings = TOML.parsefile(path);
    catch
        throw(ArgumentError("The config file could not be read as TOML."));
    end

    # Read each single setting with its type -
    steps_per_year = config_setting(settings, "steps_per_year", Int);
    number_of_states = config_setting(settings, "number_of_states", Int);
    nu = config_setting(settings, "nu", Float64);
    epsilon = config_setting(settings, "epsilon", Float64);
    lambda = config_setting(settings, "lambda", Float64);
    number_of_paths = config_setting(settings, "number_of_paths", Int);
    seed = config_setting(settings, "seed", Int);
    benchmark_ticker = config_setting(settings, "benchmark_ticker", String);

    # Read each list setting -
    fred_series = config_list(settings, "fred_series");
    fred_kinds = config_list(settings, "fred_kinds");
    fred_names = config_list(settings, "fred_names");
    pair_first = config_list(settings, "pair_first");
    pair_second = config_list(settings, "pair_second");

    # Check the single settings -
    check_setting(steps_per_year >= 1, "The steps_per_year must be at least 1.");
    check_setting(number_of_states >= 2, "The number_of_states must be at least 2.");
    check_setting(isfinite(nu) && nu > 0, "The nu must be a positive number.");
    check_setting(0 <= epsilon && epsilon <= 1, "The epsilon must be from 0 to 1.");
    check_setting(isfinite(lambda) && lambda > 0, "The lambda must be a positive number.");
    check_setting(number_of_paths >= 1, "The number_of_paths must be at least 1.");
    check_setting(benchmark_ticker == "SPY", "The benchmark_ticker must be \"SPY\", because the FRED file holds one row for each SPY price day.");

    # Check the FRED series: at least one, each a column of the FRED file named once, each with a kind and a name -
    check_setting(!isempty(fred_series), "The fred_series list must name at least one series.");
    check_setting(length(unique(fred_series)) == length(fred_series), "Each series in fred_series must appear only once.");
    for series ∈ fred_series
        check_setting(series in FRED_COLUMNS, "Every entry of fred_series must be one of $(join(FRED_COLUMNS, ", ")).");
    end
    check_setting(length(fred_kinds) == length(fred_series),
        "The fred_kinds list must have one entry for each series in fred_series.");
    for kind ∈ fred_kinds
        check_setting(kind == "change" || kind == "growth", "Every entry of fred_kinds must be \"change\" or \"growth\".");
    end
    check_setting(length(fred_names) == length(fred_series),
        "The fred_names list must have one entry for each series in fred_series.");

    # Check the pairs of sectors: at least one pair, and each pair names two different GICS sectors -
    check_setting(!isempty(pair_first), "The pair_first list must name at least one sector.");
    check_setting(length(pair_second) == length(pair_first),
        "The pair_second list must have one sector for each sector in pair_first.");
    for k ∈ 1:length(pair_first)
        check_setting(pair_first[k] in GICS_SECTORS, "Every entry of pair_first must be a GICS sector, such as \"Utilities\".");
        check_setting(pair_second[k] in GICS_SECTORS, "Every entry of pair_second must be a GICS sector, such as \"Utilities\".");
        check_setting(pair_first[k] != pair_second[k], "Each pair in pair_first and pair_second must name two different sectors.");
    end

    # The settings, with the time step of one trading day -
    return (Δt = 1.0 / steps_per_year, number_of_states = number_of_states, ν = nu, ϵ = epsilon, λ = lambda,
        number_of_paths = number_of_paths, seed = seed, benchmark_ticker = benchmark_ticker,
        fred_series = fred_series, fred_kinds = fred_kinds, fred_names = fred_names,
        pair_first = pair_first, pair_second = pair_second);
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
