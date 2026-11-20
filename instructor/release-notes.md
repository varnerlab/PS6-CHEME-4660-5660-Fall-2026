# CHEME 5660 Problem Set 6

This is the Fall 2026 student release of PS6: *Do Hidden States Make the Farmer–Joshi Market Look Real?*

Download **Source code (zip)** below, extract it, and start with `README.md`. The release holds the starter code for three tracks, the market simulator, the mathematical companion, the public checks, the response files, the checker, and the grading rubric. The release does not include the reference solutions.

Set `TRACK.txt` to `standard`, `advanced`, or `expert`.
* __Standard__ measures the course example's market and compares the market with SPY.
* __Advanced__ adds extra flat states, in which a trader builds conviction before taking a position, and compares markets with 3, 5, and 7 states.
* __Expert__ adds hesitant traders, who move to a new state only with a fixed probability, and compares three values of that probability.

Answer Question 1, your prediction, before you write any code.

Use **Julia 1.12.7**, and install the packages as the README describes. `check_submission.jl` checks your code, writes the report to `results/Report.md`, and tells you how to build your ZIP.

The initial submission is due on Canvas by **11:59 PM ET on Sunday, December 6, 2026**. Revisions are accepted until **December 19, 2026 at 11:59 PM ET**. A confirmed Advanced score of 4 earns one Magic Point, and a confirmed Expert score of 4 earns two Magic Points. PS6 earns at most two Magic Points.
