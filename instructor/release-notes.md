# CHEME 5660 Problem Set 6

This is the Fall 2026 student release of PS6: *Do Hidden States Make the Farmer–Joshi Market Look Real?*

Download **Source code (zip)** below, extract it, and begin with `README.md`. The release contains the starter code for three tracks, the Farmer–Joshi market simulator, the mathematical companion, public tests, response files, the submission checker, and the grading rubric. The reference solutions are not included.

Set `TRACK.txt` to `standard`, `advanced`, or `expert`.
* __Standard__ measures the course example's market, which has no hidden states, and compares the market with SPY.
* __Advanced__ adds a conviction ladder, extra flat states in which a trader builds conviction before taking a position, and compares markets with 3, 5, and 7 states.
* __Expert__ adds hesitant traders, who move to a new state only with a fixed probability, and compares three values of that probability.

Write your prediction in Question 1a before you write any code.

Use **Julia 1.12.7** and follow the package setup in the README. `check_submission.jl` checks your code, prints the comparison report, and gives the instructions for building your ZIP.

The initial submission is due on Canvas by **11:59 PM ET on Sunday, December 6, 2026**. Eligible revisions are accepted until **December 19, 2026 at 11:59 PM ET**. An accepted Advanced score of 4 earns one Magic Point, and an accepted Expert score of 4 earns two Magic Points. PS6 earns at most two Magic Points.
