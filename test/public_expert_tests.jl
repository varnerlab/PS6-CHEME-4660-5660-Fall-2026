# The PS6 public checks for the Expert track: the sixteen Advanced checks, then eight checks of
# hesitant_rung and transition_matrix. Each check calls one student function, so an unfinished
# function does not block the checks of the others.

# --- hesitant_rung checks ---

"""
    check_hesitant_accepts() -> Bool

`hesitant_rung` takes the proposed rung when the draw `u` is below `p`.
"""
function check_hesitant_accepts()::Bool

    # Each case is (rung, proposed, p, u, expected rung) -
    cases = ((0, 1, 0.5, 0.3, 1), (2, 1, 0.2, 0.1, 1));
    for (rung, proposed, p, u, expected) in cases
        if hesitant_rung(rung, proposed, p, u) != expected
            return false;
        end
    end
    return true;
end

"""
    check_hesitant_holds() -> Bool

`hesitant_rung` keeps the current rung when the draw `u` is at least `p`.
"""
function check_hesitant_holds()::Bool

    # Each case is (rung, proposed, p, u, expected rung) -
    cases = ((0, 1, 0.5, 0.5, 0), (0, 1, 0.5, 0.9, 0));
    for (rung, proposed, p, u, expected) in cases
        if hesitant_rung(rung, proposed, p, u) != expected
            return false;
        end
    end
    return true;
end

"""
    check_hesitant_certain() -> Bool

With `p = 1.0`, `hesitant_rung` takes the proposed rung for every draw `u` from 0 to 0.999.
"""
function check_hesitant_certain()::Bool
    for k in 0:999
        u = k / 1000;
        if hesitant_rung(-1, 0, 1.0, u) != 0
            return false;
        end
    end
    return true;
end

"""
    check_hesitant_same_rung() -> Bool

When the proposed rung equals the current rung, `hesitant_rung` returns that rung for any draw `u`.
"""
function check_hesitant_same_rung()::Bool
    for u in (0.1, 0.9)
        if hesitant_rung(1, 1, 0.5, u) != 1
            return false;
        end
    end
    return true;
end

# --- transition_matrix checks ---

"""
    check_transition_rows() -> Bool

`transition_matrix` returns a `(2K+1) × (2K+1)` matrix whose rows each sum to 1, for `K` from 1 to 3,
three values of `p`, and five signals.
"""
function check_transition_rows()::Bool
    T = 1.0;
    τ = -0.1;
    for K in 1:3
        for p in (1.0, 0.5, 0.2)
            for z in (-2.0, -0.5, 0.0, 0.5, 2.0)
                P = transition_matrix(z, T, τ, K, p);
                if size(P) != (2 * K + 1, 2 * K + 1)
                    return false;
                end
                for i in 1:(2 * K + 1)
                    if !isapprox(sum(P[i, :]), 1.0, atol = 1e-12)
                        return false;
                    end
                end
            end
        end
    end
    return true;
end

"""
    check_transition_certain() -> Bool

With `p = 1.0`, `transition_matrix` puts probability 1 on the rung that `conviction_rung` gives
and probability 0 on every other rung.
"""
function check_transition_certain()::Bool
    T = 1.0;
    τ = -0.1;
    for K in 1:3
        for z in (-2.0, -0.5, 0.0, 0.5, 2.0)
            P = transition_matrix(z, T, τ, K, 1.0);
            for i in 1:(2 * K + 1)
                target = conviction_rung(i - K - 1, z, T, τ, K);
                for j in 1:(2 * K + 1)
                    expected = 0.0;
                    if j - K - 1 == target
                        expected = 1.0;
                    end
                    if P[i, j] != expected
                        return false;
                    end
                end
            end
        end
    end
    return true;
end

"""
    check_transition_by_hand() -> Bool

The hand-computed `transition_matrix` for `K = 1`, `z = 2.0`, and `p = 0.5`.
"""
function check_transition_by_hand()::Bool
    P = transition_matrix(2.0, 1.0, -0.1, 1, 0.5);
    expected = [0.5 0.5 0.0; 0.0 0.5 0.5; 0.0 0.0 1.0];
    return size(P) == (3, 3) && isapprox(P, expected, atol = 1e-12);
end

"""
    check_transition_steps_to_long() -> Bool

At a strong signal `z = 10.0`, the expected number of steps from rung 0 to rung `K`, computed
from `transition_matrix` with the supplied `expected_steps_to_long`, is `K / p`.
"""
function check_transition_steps_to_long()::Bool
    T = 1.0;
    τ = -0.1;
    for K in 1:3
        for p in (1.0, 0.5, 0.2)
            P = transition_matrix(10.0, T, τ, K, p);
            if !isapprox(expected_steps_to_long(P, K), K / p)
                return false;
            end
        end
    end
    return true;
end

"""
    expert_public_checks() -> Vector{NamedTuple}

The twenty-four Expert public checks: the sixteen Advanced checks, then four for `hesitant_rung`
and four for `transition_matrix`.
"""
function expert_public_checks()::Vector{NamedTuple}
    checks = advanced_public_checks();
    push!(checks, (name = "Hesitant rung: accepts the proposed rung when u is below p", test = check_hesitant_accepts));
    push!(checks, (name = "Hesitant rung: keeps the rung when u is at least p", test = check_hesitant_holds));
    push!(checks, (name = "Hesitant rung: p = 1 accepts every draw", test = check_hesitant_certain));
    push!(checks, (name = "Hesitant rung: a proposal equal to the rung returns the rung", test = check_hesitant_same_rung));
    push!(checks, (name = "Transition matrix: size and row sums", test = check_transition_rows));
    push!(checks, (name = "Transition matrix: p = 1 matches the conviction rung", test = check_transition_certain));
    push!(checks, (name = "Transition matrix: hand-computed matrix for K = 1", test = check_transition_by_hand));
    push!(checks, (name = "Transition matrix: expected steps from rung 0 to rung K", test = check_transition_steps_to_long));
    return checks;
end
