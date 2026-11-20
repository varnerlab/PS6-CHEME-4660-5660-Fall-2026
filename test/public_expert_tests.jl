# The PS6 public checks for the Expert track: the sixteen Advanced checks, then eight checks of
# hesitant_rule and transition_matrix. Each hesitant_rule check calls only hesitant_rule. The
# transition_matrix checks also need a finished conviction_rule, because transition_matrix calls
# conviction_rule.

# --- hesitant_rule checks ---

"""
    check_hesitant_accepts() -> Bool

`hesitant_rule` takes the proposed state when the draw `u` is below `p`.
"""
function check_hesitant_accepts()::Bool

    # Each case is (state, proposed, p, u, expected state) -
    cases = ((0, 1, 0.5, 0.3, 1), (2, 1, 0.2, 0.1, 1));
    for (state, proposed, p, u, expected) ∈ cases
        if hesitant_rule(state, proposed, p, u) != expected
            return false;
        end
    end
    return true;
end

"""
    check_hesitant_holds() -> Bool

`hesitant_rule` keeps the current state when the draw `u` is at least `p`, for entries and for exits.
"""
function check_hesitant_holds()::Bool

    # Each case is (state, proposed, p, u, expected state): two entries, then an exit from long and an exit from short -
    cases = ((0, 1, 0.5, 0.5, 0), (0, 1, 0.5, 0.9, 0), (1, 0, 0.5, 0.7, 1), (-2, -1, 0.2, 0.5, -2));
    for (state, proposed, p, u, expected) ∈ cases
        if hesitant_rule(state, proposed, p, u) != expected
            return false;
        end
    end
    return true;
end

"""
    check_hesitant_certain() -> Bool

With `p = 1.0`, `hesitant_rule` takes the proposed state for every draw `u` from 0 to 0.999.
"""
function check_hesitant_certain()::Bool

    # A trader in state -1 with the proposed state 0 must move for every draw -
    for k ∈ 0:999
        u = k / 1000;
        if hesitant_rule(-1, 0, 1.0, u) != 0
            return false;
        end
    end
    return true;
end

"""
    check_hesitant_same_state() -> Bool

When the proposed state equals the current state, `hesitant_rule` returns that state for any draw `u`.
"""
function check_hesitant_same_state()::Bool

    # A draw below p and a draw above p must both keep state 1 -
    for u ∈ (0.1, 0.9)
        if hesitant_rule(1, 1, 0.5, u) != 1
            return false;
        end
    end
    return true;
end

# --- transition_matrix checks ---

"""
    ps6_transition_entry(state::Int, proposed::Int, column_state::Int, p::Float64) -> Float64

The probability that a trader in `state` is in `column_state` one step later, when `conviction_rule`
proposes `proposed` and the trader acts on a proposed move with probability `p`.
"""
function ps6_transition_entry(state::Int, proposed::Int, column_state::Int, p::Float64)::Float64

    # When the proposed state is the current state, the trader stays -
    if proposed == state
        if column_state == state
            return 1.0;
        end
        return 0.0;
    end

    # Otherwise the trader moves with probability p and stays with probability 1 - p -
    if column_state == proposed
        return p;
    end
    if column_state == state
        return 1.0 - p;
    end
    return 0.0;
end

"""
    check_transition_rows() -> Bool

`transition_matrix` returns a `(2K+1) × (2K+1)` matrix whose rows each sum to 1, for `K` from 1 to 3,
three values of `p`, and five signals.
"""
function check_transition_rows()::Bool

    # The entry and exit thresholds of every case -
    T = 1.0;
    τ = -0.1;
    for K ∈ 1:3
        for p ∈ (1.0, 0.5, 0.2)
            for z ∈ (-2.0, -0.5, 0.0, 0.5, 2.0)

                # The matrix must have one row and one column for each state -
                P = transition_matrix(z, T, τ, K, p);
                if size(P) != (2 * K + 1, 2 * K + 1)
                    return false;
                end

                # Each row must sum to 1 -
                for i ∈ 1:(2 * K + 1)
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
    check_transition_entries() -> Bool

Every entry of `transition_matrix` is `p` in the column of the state that `conviction_rule` proposes,
`1 - p` in the column of the current state, and `0` in every other column, or `1` on the diagonal when
the proposed state is the current state. The check covers `K` from 1 to 3, three values of `p`, and
five signals.
"""
function check_transition_entries()::Bool

    # The entry and exit thresholds of every case -
    T = 1.0;
    τ = -0.1;
    for K ∈ 1:3
        for p ∈ (1.0, 0.5, 0.2)
            for z ∈ (-2.0, -0.5, 0.0, 0.5, 2.0)
                P = transition_matrix(z, T, τ, K, p);

                # Row i must match the state that conviction_rule proposes for state i - K - 1 -
                for i ∈ 1:(2 * K + 1)
                    proposed = conviction_rule(i - K - 1, z, T, τ, K);
                    for j ∈ 1:(2 * K + 1)
                        expected = ps6_transition_entry(i - K - 1, proposed, j - K - 1, p);
                        if !isapprox(P[i, j], expected, atol = 1e-12)
                            return false;
                        end
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

    # With z above T, each flat or short state moves up one state with probability 0.5 -
    P = transition_matrix(2.0, 1.0, -0.1, 1, 0.5);
    expected = [0.5 0.5 0.0; 0.0 0.5 0.5; 0.0 0.0 1.0];
    return size(P) == (3, 3) && isapprox(P, expected, atol = 1e-12);
end

"""
    check_transition_steps_to_long() -> Bool

At a strong signal `z = 10.0`, the expected number of steps from state 0 to state `K`, computed
from `transition_matrix` with the supplied `expected_steps_to_long`, is `K / p`.
"""
function check_transition_steps_to_long()::Bool

    # The entry and exit thresholds of every case -
    T = 1.0;
    τ = -0.1;

    # For every K and p, the expected steps from state 0 to state K must be K / p -
    for K ∈ 1:3
        for p ∈ (1.0, 0.5, 0.2)
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

The twenty-four Expert public checks: the sixteen Advanced checks, then four for `hesitant_rule`
and four for `transition_matrix`.
"""
function expert_public_checks()::Vector{NamedTuple}

    # The sixteen Advanced checks, then four hesitant checks and four transition checks -
    checks = advanced_public_checks();
    push!(checks, (name = "Hesitant rule: accepts the proposed state when u is below p", test = check_hesitant_accepts));
    push!(checks, (name = "Hesitant rule: keeps the state when u is at least p", test = check_hesitant_holds));
    push!(checks, (name = "Hesitant rule: p = 1 accepts every draw", test = check_hesitant_certain));
    push!(checks, (name = "Hesitant rule: a proposal equal to the state returns the state", test = check_hesitant_same_state));
    push!(checks, (name = "Transition matrix: size and row sums", test = check_transition_rows));
    push!(checks, (name = "Transition matrix: every entry matches conviction_rule and p", test = check_transition_entries));
    push!(checks, (name = "Transition matrix: hand-computed matrix for K = 1", test = check_transition_by_hand));
    push!(checks, (name = "Transition matrix: expected steps from state 0 to state K", test = check_transition_steps_to_long));
    return checks;
end
