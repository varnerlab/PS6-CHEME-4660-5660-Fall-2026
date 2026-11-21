# CHEME 5660 Problem Set 6

This is the Fall 2026 student release of PS6: *Does a Synthetic Market Move Together Like the Real Market?*

Download **Source code (zip)** below, extract it, and start with `README.md`. The release holds the starter code for three tracks, the supplied model code, the FRED data file, the mathematical companion, the public checks, the response files, the checker, and the grading rubric. The release does not include the reference solutions.

Set `TRACK.txt` to `standard`, `advanced`, or `expert`.
* __Standard__ fits the market and the sector factors of the general factor model, and compares how the real and synthetic stocks move together.
* __Advanced__ adds the Cholesky step, which keeps the correlations between the factors in the synthetic market.
* __Expert__ adds four economic factors from FRED, such as the daily change in the 10-year Treasury yield.

Answer Question 1, your prediction, before you write any code.

Use **Julia 1.12.7**, and install the packages as the README describes. `check_submission.jl` checks your code, writes the report to `results/Report.md`, and tells you how to build your ZIP.

The initial submission is due on Canvas by **11:59 PM ET on Sunday, December 6, 2026**. Revisions are accepted until **December 19, 2026 at 11:59 PM ET**. A confirmed Advanced score of 4 earns one Magic Point, and a confirmed Expert score of 4 earns two Magic Points. PS6 earns at most two Magic Points.

This product uses the FRED® API but is not endorsed or certified by the Federal Reserve Bank of St. Louis.
