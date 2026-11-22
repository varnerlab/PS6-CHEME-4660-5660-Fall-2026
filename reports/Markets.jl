# PS6 report: the real market next to the synthetic markets of the general factor model. Students do
# not edit this file.
#
# `write_report`, at the end of this file, fits the general factor model with your functions, draws the
# synthetic markets, and writes the tables of Report.md. A row or a table that needs a function you have
# not finished shows UNAVAILABLE, and the rest of the report still prints.
#
# The file reads from top to bottom:
#   1. Rows
#   2. Tables
#   3. Writing the report

# --- 1. Rows ------------------------------------------------------------------------------------

"""
    problem_text(caught) -> String

Return `UNAVAILABLE: ` and the first line of the message of an error, so that a row or a table can
show why it could not run.
"""
function problem_text(caught)::String

    # The first non-empty line of the message -
    first_line = "";
    for line ∈ split(sprint(showerror, caught), '\n')
        cleaned = Base.strip(line);
        if isempty(first_line) && !isempty(cleaned)
            first_line = String(cleaned);
        end
    end

    # Use the type of the error when the message is empty -
    if isempty(first_line)
        first_line = string(typeof(caught));
    end
    return "UNAVAILABLE: " * first_line;
end

"""
    real_row(universe::NamedTuple, settings::NamedTuple) -> NamedTuple

The row of the real market: the statistics of `market_statistics` for the daily growth rates of the
stocks.
"""
function real_row(universe::NamedTuple, settings::NamedTuple)::NamedTuple

    # Measure the real growth rates, and name the row -
    statistics = market_statistics(universe.G, universe, settings);
    return (label = "real market", problem = "", synthetic = false, statistics = statistics);
end

"""
    synthetic_row(label::String, universe::NamedTuple, settings::NamedTuple; fred::Bool, sectors::Bool,
        cholesky_step::Bool) -> NamedTuple

Fit one model, draw `settings.number_of_paths` synthetic markets from it, and find the lowest and the
highest value of each statistic of `market_statistics` over the synthetic markets.

### Arguments

- `label`: The name of the row.
- `universe`: The market from `load_universe`.
- `settings`: The settings from `load_config`.
- `fred`: `true` adds the FRED series as economic factors.
- `sectors`: `true` adds the sector factors (fitting steps 2 and 3).
- `cholesky_step`: `true` runs the Cholesky step (fitting step 4 and sampling step 1).

### Returns

- A `NamedTuple` with `label`, an empty `problem`, `synthetic = true`, and the fields `lowest` and
  `highest` of `range_statistics`. When a function throws, the `NamedTuple` holds only `label` and the
  `UNAVAILABLE` text in `problem`.
"""
function synthetic_row(label::String, universe::NamedTuple, settings::NamedTuple; fred::Bool, sectors::Bool,
    cholesky_step::Bool)::NamedTuple
    try
        # The economic factors: the FRED series, or none -
        x = zeros(size(universe.G, 1), 0);
        if fred == true
            x = economic_factors(load_fred_levels(settings), settings);
        end

        # Fit the model, draw the synthetic markets, and find the range of each statistic -
        fit = fit_factor_model(universe, x; sectors = sectors);
        markets = synthetic_markets(fit, settings; cholesky_step = cholesky_step);
        ranges = range_statistics(markets, universe, settings);
        return (label = label, problem = "", synthetic = true, lowest = ranges.lowest, highest = ranges.highest);
    catch caught
        return (label = label, problem = problem_text(caught));
    end
end

# --- 2. Tables ----------------------------------------------------------------------------------

"""
    markets_table(track::String, universe::NamedTuple, settings::NamedTuple) -> Vector{NamedTuple}

Rows of the table "Real and synthetic markets": the real market, the single index model, and the market
and sectors on every track; and, on the Advanced track, three models with the Cholesky step: the market
and sectors, the market and FRED series, and the market, sectors, and FRED series.
"""
function markets_table(track::String, universe::NamedTuple, settings::NamedTuple)::Vector{NamedTuple}

    # The real market, and the two models of the Standard track -
    rows = NamedTuple[];
    push!(rows, real_row(universe, settings));
    push!(rows, synthetic_row("single index model", universe, settings;
        fred = false, sectors = false, cholesky_step = false));
    push!(rows, synthetic_row("market and sectors", universe, settings;
        fred = false, sectors = true, cholesky_step = false));

    # The three models of the Advanced track, all with the Cholesky step: the sectors, the FRED series in
    # place of the sectors, and the sectors with the FRED series -
    if track == "advanced"
        push!(rows, synthetic_row("market and sectors, with the Cholesky step", universe, settings;
            fred = false, sectors = true, cholesky_step = true));
        push!(rows, synthetic_row("market and FRED series, with the Cholesky step", universe, settings;
            fred = true, sectors = false, cholesky_step = true));
        push!(rows, synthetic_row("market, sectors, and FRED series, with the Cholesky step", universe, settings;
            fred = true, sectors = true, cholesky_step = true));
    end
    return rows;
end

"""
    fred_table(universe::NamedTuple, settings::NamedTuple) -> Union{Vector{NamedTuple}, String}

Rows of the table "FRED series": for each sector, the average over the stocks of the sector of the R²
of fitting step 1 with the market alone, the R² with the market and the FRED series, and the loading
on each FRED series. Returns `"UNAVAILABLE: ..."` when a function throws.
"""
function fred_table(universe::NamedTuple, settings::NamedTuple)::Union{Vector{NamedTuple},String}
    try
        # The economic factors, and fitting step 1 with the market alone and with the market and the FRED series -
        x = economic_factors(load_fred_levels(settings), settings);
        number_of_days = size(universe.G, 1);
        market_only = fit_factor_model(universe, zeros(number_of_days, 0); sectors = false);
        with_fred = fit_factor_model(universe, x; sectors = false);

        # One row per sector, averaged over the stocks of the sector -
        rows = NamedTuple[];
        number_of_stocks = length(universe.sectors);
        number_of_series = size(x, 2);
        for sector ∈ universe.sector_names

            # Add up the R² values and the loadings of the stocks in the sector -
            r2_market = 0.0;
            r2_fred = 0.0;
            loadings = zeros(number_of_series);
            count = 0;
            for i ∈ 1:number_of_stocks
                if universe.sectors[i] == sector
                    g = universe.G[:, i];
                    r2_market = r2_market + r_squared(g, market_only.E[:, i]);
                    r2_fred = r2_fred + r_squared(g, with_fred.E[:, i]);

                    # The loadings on the FRED series follow the baseline and the market sensitivity in θ -
                    loadings = loadings + with_fred.Θ[3:end, i];
                    count = count + 1;
                end
            end

            # Divide each total by the number of stocks in the sector -
            push!(rows, (sector = sector, r2_market = r2_market / count, r2_fred = r2_fred / count,
                loadings = loadings / count));
        end
        return rows;
    catch caught
        return problem_text(caught);
    end
end

# --- 3. Writing the report ----------------------------------------------------------------------

"""
    number_text(x::Float64) -> String

Write a number with 2 decimals. A number that rounds to zero prints as `0.00`, never `-0.00`.
"""
function number_text(x::Float64)::String

    # Round to 2 decimals; adding 0.0 turns -0.0 into 0.0 -
    rounded = round(x, digits = 2) + 0.0;
    return @sprintf("%.2f", rounded);
end

"""
    write_header(io::IO, headers::Vector{String}) -> Nothing

Write the header line of a Markdown table: the first column aligned left, and the others aligned right.
"""
function write_header(io::IO, headers::Vector{String})::Nothing

    # The column names, then the alignment line -
    println(io, "| ", join(headers, " | "), " |");
    alignments = fill("--:", length(headers));
    alignments[1] = ":--";
    println(io, "|", join(alignments, "|"), "|");
    return nothing;
end

"""
    statistic_values(statistics::NamedTuple) -> Vector{Float64}

Put the statistics of `market_statistics` in the order of the columns of the table "Real and synthetic
markets": same sector, different sectors, and each pair of sectors.
"""
function statistic_values(statistics::NamedTuple)::Vector{Float64}

    # The two sector columns, then one column for each pair of sectors -
    values = [statistics.same_sector, statistics.different_sectors];
    for pair_value ∈ statistics.pairs
        push!(values, pair_value);
    end
    return values;
end

"""
    write_markets_table(io::IO, rows::Vector{NamedTuple}, settings::NamedTuple, number_of_days::Int) -> Nothing

Write the table "Real and synthetic markets", with a paragraph above it that says what each column and
each row holds, and when a model matches the real market. A row that could not run shows its
`UNAVAILABLE` text in place of its numbers.
"""
function write_markets_table(io::IO, rows::Vector{NamedTuple}, settings::NamedTuple, number_of_days::Int)::Nothing

    # The heading, and what each column and each row holds -
    println(io, "## Real and synthetic markets\n");
    println(io, "Each correlation column gives the average correlation of the daily growth rates over every pair ",
        "of stocks of one kind: two different stocks in the same sector, two stocks in different sectors, or one ",
        "stock in each sector of a pair. The row **real market** gives one value in each column. Each other row ",
        "is one model, and gives the lowest and the highest value over $(settings.number_of_paths) synthetic ",
        "markets of $(number_of_days) days, the length of the data. A model matches the real market in a column ",
        "when the real value falls inside that model's range.\n");

    # The columns: the two sector columns, then one column for each pair of sectors -
    headers = ["Market or model", "Average correlation, same sector", "Average correlation, different sectors"];
    number_of_pairs = length(settings.pair_first);
    for k ∈ 1:number_of_pairs
        push!(headers, "Average correlation, $(settings.pair_first[k]) and $(settings.pair_second[k])");
    end
    write_header(io, headers);

    # One line per row -
    for row ∈ rows
        cells = [row.label];
        if !isempty(row.problem)
            # The UNAVAILABLE text fills the first number column, and the other columns stay empty -
            push!(cells, row.problem);
            for k ∈ 1:(length(headers) - 2)
                push!(cells, "");
            end
        elseif row.synthetic == false
            # The real market: one value in each column -
            for value ∈ statistic_values(row.statistics)
                push!(cells, number_text(value));
            end
        else
            # A model: the lowest and the highest value over its synthetic markets -
            lowest = statistic_values(row.lowest);
            highest = statistic_values(row.highest);
            for k ∈ 1:length(lowest)
                push!(cells, number_text(lowest[k]) * " to " * number_text(highest[k]));
            end
        end
        println(io, "| ", join(cells, " | "), " |");
    end
    println(io);
    return nothing;
end

"""
    write_fred_table(io::IO, rows, settings::NamedTuple) -> Nothing

Write the table "FRED series", with a paragraph above it that says what each column holds. A table
that could not run shows its `UNAVAILABLE` text instead of rows.
"""
function write_fred_table(io::IO, rows, settings::NamedTuple)::Nothing

    # The heading -
    println(io, "## FRED series\n");

    # A table that could not run -
    if rows isa String
        println(io, rows, "\n");
        return nothing;
    end

    # What each column holds -
    println(io, "Each row averages over the stocks of one sector. R² is the fraction of the variance of a stock's ",
        "daily growth rates that fitting step 1 explains, with SPY alone or with SPY and the FRED series. Each ",
        "loading column gives the average loading of fitting step 1 on one FRED series: the change in a stock's ",
        "growth rate (1/yr) when the economic factor of that series changes by one unit. The economic factors have ",
        "different units, so compare loadings only within a column, across sectors.\n");

    # The columns: the two R² columns, and one loading column for each FRED series -
    headers = ["Sector", "Average R² with SPY", "Average R² with SPY and the FRED series"];
    for name ∈ settings.fred_names
        push!(headers, "Average loading on the $(name)");
    end
    write_header(io, headers);

    # One line per sector -
    for row ∈ rows
        cells = [row.sector, number_text(row.r2_market), number_text(row.r2_fred)];
        for loading ∈ row.loadings
            push!(cells, number_text(loading));
        end
        println(io, "| ", join(cells, " | "), " |");
    end
    println(io);
    return nothing;
end

"""
    write_report(track::String, settings::NamedTuple, path::String) -> Nothing

Fit the general factor models with your functions, draw the synthetic markets, and write the tables of
the report to `path`.

### Arguments

- `track`: `"standard"` (the first table, with the real market and two models) or `"advanced"` (both
  tables, and three more models).
- `settings`: The settings from `load_config`.
- `path`: The Markdown file to write.
"""
function write_report(track::String, settings::NamedTuple, path::String)::Nothing

    # Load the market, then run the tables of the track; Base.invokelatest lets the report call functions defined after it was loaded -
    universe = load_universe(settings);
    markets = Base.invokelatest(markets_table, track, universe, settings);
    fred = "";
    if track == "advanced"
        fred = Base.invokelatest(fred_table, universe, settings);
    end

    # Write the file: the title, then each table of the track -
    io = open(path, "w");
    try
        println(io, "# PS6 report\n");
        write_markets_table(io, markets, settings, size(universe.G, 1));
        if track == "advanced"
            write_fred_table(io, fred, settings);
        end
    finally
        close(io);
    end
    return nothing;
end
