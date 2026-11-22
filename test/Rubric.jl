# SHA-256 of the supplied config/defaults.toml; the checker warns when a student edits the file -
const PS6_DEFAULTS_SHA256 = "3de583ea2c8b4f88bc80e41ff37ea0aaaad6ba809bbca1599e23d6ded9bed207";

"""
    run_public_check(check::NamedTuple)

Run one public check (see `test/public_standard_tests.jl` for the check format).

### Returns

- What the check's `test` function returns: `true` when the check passes.
"""
function run_public_check(check::NamedTuple)
    return check.test();
end

"""
    evaluate_public_checks(checks) -> Vector{NamedTuple}

Run each public check and record its result. An error in one check does not
stop the others.

### Arguments

- `checks`: The public checks, from `standard_public_checks` or
  `advanced_public_checks`.

### Returns

One record per check, with its `name`, a `passed` value of `true` or `false`,
and an error message in `detail`. An empty message means the check passed.
"""
function evaluate_public_checks(checks::AbstractVector{<:NamedTuple})::Vector{NamedTuple}

    # main loop: run each check, and catch any error so that the other checks still run -
    results = NamedTuple[];
    for check ∈ checks
        passed = false;
        detail = "";
        try
            value = run_public_check(check);
            passed = value === true;
            if !passed
                detail = "check returned $(repr(value))";
            end
        catch caught
            detail = sprint(showerror, caught);
        end
        push!(results, (name = check.name, passed = passed, detail = detail));
    end

    return results;
end

"""
    number_passed(results) -> Int

Count the check results that passed.
"""
function number_passed(results::AbstractVector{<:NamedTuple})::Int

    # Count one for each check that passed -
    passed = 0;
    for result ∈ results
        if result.passed
            passed = passed + 1;
        end
    end
    return passed;
end

"""
    failed_public_checks(checks, detail) -> Vector{NamedTuple}

Mark every check as failed when the student's source file cannot be loaded.

### Arguments

- `checks`: The selected track's checks, each with a `name` field.
- `detail`: Error message explaining why the source could not be loaded.

### Returns

One failed result per check, each with the supplied error message.
"""
function failed_public_checks(checks::AbstractVector{<:NamedTuple},
    detail::String)::Vector{NamedTuple}

    # One failed result for each check -
    results = NamedTuple[];
    for check ∈ checks
        push!(results, (name = check.name, passed = false, detail = detail));
    end
    return results;
end


"""
    print_public_test_report(results, title; tests_ran=true) -> Nothing

Print aligned pass/fail labels and a summary. Number repeated errors and
print each distinct diagnostic once after the checks.

### Arguments

- `results`: Check records with `name`, `passed`, and `detail` fields.
- `title`: Heading to print above the checks.
- `tests_ran`: If false, explain that loading prevented the checks from running.
  The caller displays the loading error once instead of repeating it per check.

### Returns

`nothing`. The report is printed to the terminal.
"""
function print_public_test_report(results::AbstractVector{<:NamedTuple},
    title::String; tests_ran::Bool=true)::Nothing

    # The heading; when the checks could not run, there is nothing more to list -
    print_terminal_section(title; major=true);
    if !tests_ran
        print_terminal_text("Checks could not run because a setup or source file did not load. Fix the error below and run the checker again.");
        print_terminal_text("Public tests: 0/$(length(results)) passed. Checks that cannot run count as failed.");
        return nothing;
    end

    # The distinct error messages of the failed checks, each printed once -
    details = String[];
    for result ∈ results
        if !result.passed && !isempty(result.detail) && !(result.detail in details)
            push!(details, result.detail);
        end
    end
    if !isempty(details)
        println("Numbers in brackets refer to the error messages in Check details.");
        println();
    end

    # One line per check; a failed check points to its error message -
    for result ∈ results
        if result.passed
            status = "PASS";
            reference = "";
        else
            status = "FAIL";
            reference = "";
            for (index, detail) ∈ enumerate(details)
                if detail == result.detail
                    reference = " [$(index)]";
                end
            end
        end
        print_terminal_text(result.name * reference; prefix="[$(status)] ", continuation="       ");
    end

    # The summary line -
    passed = number_passed(results);
    println("\nPublic tests: $(passed)/$(length(results)) passed");

    # The error messages -
    if !isempty(details)
        print_terminal_section("Check details");
        for (index, detail) ∈ enumerate(details)
            println("Error $(index)");
            print_terminal_detail(detail);
            if index < length(details)
                println();
            end
        end
    end
    return nothing;
end


"""
    response_issues(path::String) -> Vector{String}

Find missing or unfinished answers and describe how to fix them.

### Arguments

- `path`: Selected track's Markdown response file.

### Returns

A list of messages for missing files, incorrect answer markers, empty answers,
or answers that contain TODO. An empty list means no issues were found.
The check ignores HTML comments inside answers. It checks for text, not
whether an answer is correct; the teaching team reviews the answers.

### Errors

An unreadable file raises a file-read error.
"""
function response_issues(path::String)::Vector{String}

    # A missing file is the only issue to report -
    if !isfile(path)
        return ["Response file is missing. Restore it from the PS6 ZIP and answer all three questions."];
    end

    # Read the response file, and start an empty list of issues -
    text = read(path, String);
    issues = String[];

    # main loop: check the answer block of each of the three questions -
    for index ∈ 1:3

        # Find the markers and the text between them -
        start_marker = "<!-- answer-$(index):start -->";
        end_marker = "<!-- answer-$(index):end -->";
        pattern = Regex("<!-- answer-$(index):start -->(.*?)<!-- answer-$(index):end -->", "s");
        blocks = collect(eachmatch(pattern, text));

        # Each question needs exactly one pair of markers -
        if count(start_marker, text) != 1 || count(end_marker, text) != 1 || length(blocks) != 1
            push!(issues, "Question $(index): Keep one $(start_marker) before your answer and one $(end_marker) after it.");
            continue;
        end
        # Remove HTML comments, then surrounding space (Base.strip: the course package has its own strip) -
        answer = replace(blocks[1].captures[1], r"<!--.*?-->"s => "");
        answer = Base.strip(answer);

        # An answer needs a letter or a number, and must not still contain TODO -
        if !occursin(r"[\p{L}\p{N}]", answer)
            push!(issues, "Question $(index) has no answer. Write your answer between its marker lines.");
        elseif occursin(r"\bTODO\b"i, answer)
            push!(issues, "Question $(index) still contains TODO. Replace the TODO line with your answer.");
        end
    end
    return issues;
end


"""
    rubric_score(results; tests_ran, completion) -> Int

Calculate the rubric score from the check results and the teaching team's review.

### Arguments

- `results`: A vector of check records with Boolean `passed` fields.
- `tests_ran`: Whether the student's source file loaded; `false` gives 0.
- `completion`: Set to `true` only when the teaching team has graded the
  answers and found all three complete.

### Returns

An integer from 0 to 4. A submission with no passing checks receives 0.
Passing at least one check but no more than half gives 1; passing more than
half but fewer than all gives 2.
When all checks pass, return 3 if `completion` is `false` and 4 if it is `true`.

### Notes

Standard has 12 checks: passing 1–6 gives 1, 7–11 gives 2, and all 12 gives
3 or 4. Advanced has 24 checks: passing 1–12 gives 1, 13–23 gives 2, and all
24 gives 3 or 4. The local checker prints "3 or 4" when all checks pass, and the
teaching team chooses between 3 and 4 from the answers.
"""
function rubric_score(results::AbstractVector{<:NamedTuple};
    tests_ran::Bool, completion::Bool)::Int

    # Count the checks that passed, out of all the checks -
    passed = number_passed(results);
    total = length(results);

    # The score follows the rubric's thresholds -
    if !tests_ran || passed == 0
        return 0;
    elseif 2*passed <= total
        return 1;
    elseif passed < total
        return 2;
    elseif !completion
        return 3;
    else
        return 4;
    end
end
