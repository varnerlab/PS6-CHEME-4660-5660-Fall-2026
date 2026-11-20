# The PS6 public checks for the Advanced track: the twelve Standard checks, then four checks of
# conviction_rung. Each check calls one student function, so an unfinished function does not
# block the checks of the others.

"""
    ps6_signal_grid(T::Float64, τ::Float64) -> Vector{Float64}

The signals the conviction checks use: a grid from -5 to 5 that also holds `T`, `-T`, `τ`, and `-τ`.
"""
function ps6_signal_grid(T::Float64, τ::Float64)::Vector{Float64}
    return vcat(collect(range(-5, 5, length = 201)), [T, -T, τ, -τ]);
end

# --- conviction_rung checks ---

"""
    check_conviction_k1_matches_course() -> Bool

With `K = 1`, `conviction_rung` matches the course `threshold_position` for three pairs of thresholds
`(T, τ)`, every rung, and the signal grid of the three-state checks.
"""
function check_conviction_k1_matches_course()::Bool

    # Compare the conviction rung with the course function on every case -
    for (T, τ) in ((0.5, -0.1), (2.0, 0.0), (3.7, -0.2))
        signals = ps6_signal_grid(T, τ);
        for rung in -1:1
            for z in signals
                expected = Int(threshold_position(Float64(rung), z, T, τ, 1.0, 1));
                if conviction_rung(rung, z, T, τ, 1) != expected
                    return false;
                end
            end
        end
    end
    return true;
end

"""
    check_conviction_by_hand() -> Bool

Hand-computed rungs for `K = 2` and `K = 3`, with `T = 1.0` and `τ = -0.1`.
"""
function check_conviction_by_hand()::Bool

    # The entry and exit thresholds of every case -
    T = 1.0;
    τ = -0.1;

    # Each case is (K, rung, z, expected next rung) -
    cases = (
        (2, 0, 1.5, 1), (2, 1, 1.5, 2), (2, 1, 0.5, 0), (2, 1, -1.5, 0), (2, 2, 0.5, 2),
        (2, 2, -0.2, 1), (2, -1, -1.5, -2), (2, -2, 0.2, -1), (2, 0, 0.5, 0),
        (3, 2, 0.5, 1), (3, 3, -0.2, 2),
    );

    # The conviction rung must give the expected next rung in every case -
    for (K, rung, z, expected) in cases
        if conviction_rung(rung, z, T, τ, K) != expected
            return false;
        end
    end
    return true;
end

"""
    check_conviction_range() -> Bool

For `K` from 1 to 4, `conviction_rung` returns an `Int` in `-K:K` that is at most one rung away
from the current rung, over every rung and the signal grid.
"""
function check_conviction_range()::Bool

    # The thresholds and the signal grid -
    T = 1.0;
    τ = -0.1;
    signals = ps6_signal_grid(T, τ);

    # For every K, rung, and signal: an Int in -K:K, at most one rung from the current rung -
    for K in 1:4
        for rung in -K:K
            for z in signals
                result = conviction_rung(rung, z, T, τ, K);
                if !(result isa Int) || result < -K || result > K || abs(result - rung) > 1
                    return false;
                end
            end
        end
    end
    return true;
end

"""
    check_conviction_symmetry() -> Bool

Flipping the sign of the rung and the signal flips the sign of the next rung, for `K` from 1 to 3,
over every rung and the signal grid.
"""
function check_conviction_symmetry()::Bool

    # The thresholds and the signal grid -
    T = 1.0;
    τ = -0.1;
    signals = ps6_signal_grid(T, τ);

    # For every K, rung, and signal: the mirrored case gives the mirrored next rung -
    for K in 1:3
        for rung in -K:K
            for z in signals
                if conviction_rung(-rung, -z, T, τ, K) != -conviction_rung(rung, z, T, τ, K)
                    return false;
                end
            end
        end
    end
    return true;
end

"""
    advanced_public_checks() -> Vector{NamedTuple}

The sixteen Advanced public checks: the twelve Standard checks, then four for `conviction_rung`.
"""
function advanced_public_checks()::Vector{NamedTuple}

    # The twelve Standard checks, then the four conviction checks -
    checks = standard_public_checks();
    push!(checks, (name = "Conviction rung: K = 1 matches the course threshold rule", test = check_conviction_k1_matches_course));
    push!(checks, (name = "Conviction rung: hand-computed rungs for K = 2 and K = 3", test = check_conviction_by_hand));
    push!(checks, (name = "Conviction rung: stays in -K:K and moves at most one rung", test = check_conviction_range));
    push!(checks, (name = "Conviction rung: flipping the rung and the signal flips the result", test = check_conviction_symmetry));
    return checks;
end
