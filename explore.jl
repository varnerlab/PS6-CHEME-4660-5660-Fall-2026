# Optional and ungraded. Edit config/explore.toml, then run from the PS6 folder:
#   julia --project=. --startup-file=no explore.jl
# Reruns the report with your settings and your own functions (the TRACK.txt track).
# Results are written to results/exploration/Exploration.md; nothing here is submitted.

const _ROOT = @__DIR__;

"""
    load_message(caught) -> String

Explain in one line why loading stopped: the file and line, and the first line
of the error.

### Arguments

- `caught`: The error thrown while loading `Include.jl`.

### Returns

The message to print. An `ArgumentError` from the setup checks (such as a
wrong TRACK.txt) is returned as it is.
"""
function load_message(caught)::String

    # An error inside an included file is wrapped in a LoadError; keep the innermost file and line -
    place = "";
    while caught isa LoadError
        place = " ($(relpath(caught.file, _ROOT)), line $(caught.line))";
        caught = caught.error;
    end
    if caught isa ArgumentError
        return caught.msg;
    end

    # A syntax error names the problem after the ── mark; any other error gives its first line -
    text = sprint(showerror, caught);
    if caught isa Meta.ParseError
        detail = "syntax error";
        problem = match(r"── ([^\n]+)", text);
        if problem !== nothing
            detail = detail * ", " * problem.captures[1];
        end
    else
        detail = string(typeof(caught));
        for line ∈ split(text, '\n')
            # Base.strip: the course package has its own strip -
            if !isempty(Base.strip(line))
                detail = String(Base.strip(line));
                break;
            end
        end
    end

    # Keep the message short -
    if length(detail) > 200
        detail = first(detail, 197) * "...";
    end
    return "Your code could not be loaded$(place): $(detail). Run check_submission.jl to see the full message.";
end

"""
    load_assignment(path::String) -> String

Load the same files as the checker with `Include.jl`, including your track's
source file.

### Arguments

- `path`: The path to `Include.jl`.

### Returns

An empty string when everything loads, or a one-line message from
`load_message` when loading stops.
"""
function load_assignment(path::String)::String
    try
        include(path);
    catch caught
        return load_message(caught);
    end
    return "";
end

"""
    run_exploration() -> Nothing

Run the markets with the settings in config/explore.toml, then write the report
with your own functions to results/exploration/Exploration.md.

### Returns

`nothing`. Throws an `ArgumentError` with a one-sentence message when a setting
in config/explore.toml is missing or invalid.
"""
function run_exploration()::Nothing

    # Read your settings; load_config names any setting that is not valid -
    settings = load_config(joinpath(_ROOT, "config", "explore.toml"));

    # Write the report -
    directory = joinpath(_ROOT, "results", "exploration");
    mkpath(directory);
    path = joinpath(directory, "Exploration.md");
    write_report(_TRACK, settings, path);
    println("Wrote ", relpath(path, _ROOT), ".");
    return nothing;
end

# Load your code; stop with a one-line message when it does not load -
const _EXPLORE_LOAD_ERROR = load_assignment(joinpath(_ROOT, "Include.jl"));
if !isempty(_EXPLORE_LOAD_ERROR)
    println(_EXPLORE_LOAD_ERROR);
    exit(1);
end

# Run the exploration; a problem with your settings stops it with a one-line message -
try
    run_exploration();
catch caught
    if caught isa ArgumentError
        println(caught.msg);
        exit(1);
    end
    rethrow();
end
