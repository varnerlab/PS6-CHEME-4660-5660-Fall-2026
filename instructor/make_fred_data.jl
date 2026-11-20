# Build data/fred-levels-2014-2024.csv: the level of four FRED series on each SPY price day, 2014 to 2024.
# Instructor only. The script needs a FRED API key and the FredAPI package of the CHEME 5800 course
# repository. Run it from the PS6 folder; the second environment on the load path supplies FredAPI:
#
#   JULIA_LOAD_PATH="@:<path to CHEME-5800-CourseRepository-Fall-2026>:@stdlib" \
#       julia --project=. --startup-file=no instructor/make_fred_data.jl <path to Configuration.toml>
#
# The script reads the key from the configuration file and never prints or saves it.
using VLQuantitativeFinancePackage # the SPY price days
using FredAPI # the FRED series observations
using CSV # write the file
using DataFrames # the table of levels
using Dates # the price days

# The series, and the dates to download: a month before the first price day, so that day has a level -
const FRED_SERIES = ["DGS10", "T10YIE", "DCOILBRENTEU", "DTWEXBGS"];
const FIRST_DAY = "2013-12-01";
const LAST_DAY = "2024-12-31";

"""
    fred_observations(connection::AbstractDict, series_id::String) -> DataFrame

Download the observations of one FRED series from `FIRST_DAY` to `LAST_DAY`.

### Arguments

- `connection`: The FRED connection settings from `read_configuration`, with the keys `apikey` and `baseurl`.
- `series_id`: The FRED identifier of the series, such as `"DGS10"`.

### Returns

- A table with the columns `date` and `value`. A value is `missing` on a day the source did not publish.
"""
function fred_observations(connection::AbstractDict, series_id::String)::DataFrame

    # Build the request for the series, then call FRED -
    model = MyFredSeriesObservationsEndpointModel(apikey = connection["apikey"], series_id = series_id,
        observation_start = FIRST_DAY, observation_end = LAST_DAY);
    request_url = url(connection["baseurl"], model);
    return api(MyFredSeriesObservationsEndpointModel, request_url; handler = process_observations_response_dataframe);
end

"""
    level_on_day(observations::DataFrame, day::Date) -> Float64

Find the level of a series on a price day: the last value on or before that day. FRED leaves a value
blank on days its source does not publish, such as bond-market holidays.

### Arguments

- `observations`: The table from `fred_observations`, sorted by date.
- `day`: The price day.

### Returns

- The last value on or before `day`.

### Errors

- An `ArgumentError` when the series has no value on or before `day`.
"""
function level_on_day(observations::DataFrame, day::Date)::Float64

    # Find the last observation on or before the day, then step back over blank values -
    k = searchsortedlast(observations.date, day);
    while k >= 1 && ismissing(observations.value[k])
        k = k - 1;
    end

    # A day before the first value has no level -
    if k < 1
        throw(ArgumentError("The series has no value on or before $(day)."));
    end
    return Float64(observations.value[k]);
end

"""
    main(config_path::String) -> Nothing

Download the four series, find each series' level on each SPY price day, and write the file.

### Arguments

- `config_path`: The path to the FRED `Configuration.toml` file that holds the API key.
"""
function main(config_path::String)::Nothing

    # Read the connection settings; the key stays in this dictionary -
    connection = read_configuration(config_path);

    # The SPY price days, from the course data -
    days = Date.(MyTrainingMarketDataSet()["dataset"]["SPY"].timestamp);

    # One column per series: its level on each price day -
    table = DataFrame(date = days);
    for series_id ∈ FRED_SERIES
        observations = fred_observations(connection, series_id);
        levels = zeros(length(days));
        for t ∈ 1:length(days)
            levels[t] = level_on_day(observations, days[t]);
        end
        table[!, series_id] = levels;
        println(series_id, ": a level on each of ", length(days), " price days");
    end

    # Write the file -
    path = joinpath(@__DIR__, "..", "data", "fred-levels-2014-2024.csv");
    CSV.write(path, table);
    println("Wrote ", normpath(path), ".");
    return nothing;
end

# The path to the configuration file is the only argument -
if length(ARGS) != 1
    throw(ArgumentError("Give the path to the FRED Configuration.toml file."));
end
main(ARGS[1]);
