# PS6 grading rules

Your selected track is graded out of **4**. The most you can earn is 4 on
Standard, 4 plus **one Magic Point** on Advanced, and 4 plus **two Magic
Points** on Expert. You can earn at most two Magic Points on PS6. Select your
track in `TRACK.txt`.

| Score | Checks passed | Other requirements |
|:--:|:--|:--|
| 0 | None, or the selected source file cannot load | — |
| 1 | At least one, but no more than half | — |
| 2 | More than half, but fewer than all | — |
| 3 | All | At least one requirement for a 4 (below) is not met |
| 4 | All | Every requirement for a 4 is met |

The checks are the public checks that `check_submission.jl` runs, four for each
function. Standard has **12 checks**. Advanced has **16 checks**: the same 12
plus four for `conviction_rung`. Expert has **24 checks**: the same 16 plus four
for `hesitant_rung` and four for `transition_matrix`. Completing only the work
of an earlier track therefore earns at most 2. The cutoffs for scores 1 and 2
are 1–6 and 7–11 checks on Standard, 1–8 and 9–15 on Advanced, and 1–12
and 13–23 on Expert.

Checks run separately, so an unfinished function does not block the checks of
the other functions.

## Requirements for a 4

- **Standard functions:** `three_state_rung` follows the three-state rule in its
  docstring, with strict comparisons. `excess_kurtosis` uses population moments.
  `volatility_clustering` averages the autocorrelations of the absolute growth
  rates over exactly the lags passed in. Use the arguments passed in; do not
  hard-code them, and do not modify the growth rates `g`.
- **Advanced:** `conviction_rung` follows the rule in its docstring for every
  value of `K`. Complete the Advanced copies of the three Standard functions.
- **Expert:** `hesitant_rung` follows the rule in its docstring.
  `transition_matrix` builds each row from `conviction_rung` and the probability
  `p`, as its docstring describes, and each row of the matrix sums to one.
  Complete the Expert copies of the four Advanced functions.
- **Documentation:** Keep the supplied docstrings. Document each helper's
  purpose, inputs, and output, and comment non-obvious steps. Load helper files
  under `src` through `Include.jl`.
- **Written work:** Answer all three questions in the selected response file
  with the requested numbers and reasoning. Include the
  prediction and say whether the prediction was right. Cite selected values from
  `results/Report.md` rather than reproducing the tables, and explain each
  difference from SPY with what the traders do.
- **Finished work:** Remove completed TODOs and starter errors from the selected
  track's source and response files. Leave the other tracks' files unchanged.

We do not require the market to match SPY or your prediction to be right. We
assess the calculations and your interpretation.

## How we check submissions

As in PS3 to PS5, grading copies the selected source and response files, custom
helpers under `src`, `Include.jl`, and `TRACK.txt` into a fresh copy of the
assignment. Edits to any other file, such as `config/defaults.toml`, the
supplied files in `src` and `reports`, the files in `test`, or the checker, are
not used. Helper files must not define functions with the same names as the
track functions, the supplied functions, or course functions such as `build` and
`sample_autocorrelation`.

The checker gives feedback; the teaching team assigns the grade.

## Initial submission and revisions

PS6 is released **November 22, 2026**. Submit a readable ZIP with attempted work
by **December 6, 2026 at 11:59 PM ET**. A missing, empty, or unreadable
submission receives a **Frozen Zero** and cannot be revised for credit or earn a
Magic Point. Incomplete attempted work and failed checks qualify for revisions.

After a qualifying initial submission, revisions are allowed until
**December 19, 2026 at 11:59 PM ET**, with no limit on attempts. Use **New
Attempt** on the same Canvas assignment. Revisions have no late penalty, even if
Canvas labels them late. We keep your highest score, even if you change tracks.
A revision that scores 4 on Advanced or Expert also earns that track's Magic
Points.

## Independent work

You may discuss ideas and use course materials, books, documentation, the
internet, and AI tools. Submit your own work. Do not share code or solutions.

The reference solution will be released after the initial deadline. Use the
solution to understand errors and debug your work, but do not copy the solution.
Copying results in a score of 0 for PS6 that revisions cannot change. These
rules also apply to revisions.
