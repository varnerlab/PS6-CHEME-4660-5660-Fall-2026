# Problem Set 6 (PS6): Does a Synthetic Market Move Together Like the Real Market?

A **jump hidden Markov model** generates synthetic daily growth rates of one
asset. The L14a course example
[A Synthetic Market of Many Stocks](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/main/lectures/week-14/L14a/CHEME-5660-L14a-Example-JumpHMM-SectorFactor-Fall-2026.ipynb)
builds a synthetic market from many single-asset models: one model for SPY, the
exchange-traded fund that tracks the S&P 500 index, one model for each sector,
and one model for the stock-specific part of each stock. Each model draws its
own path, and a **factor model** adds the draws into the growth rates of each
stock.

In PS6, we'll use the **general factor model** of lecture L14a, which adds a
**Cholesky step** and **economic factors** to the example. The Cholesky step
keeps the correlations between the factors. Each economic factor is a daily
series, such as the daily change in the 10-year Treasury yield.

> **Does a synthetic market built from single-asset jump hidden Markov models
> move together like the real market?**

We'll explore this question on two tracks, and you will choose one.
**Standard** fits the market and the sector factors.
**Advanced** adds the Cholesky step, and asks whether four economic factors
from FRED, the economic database of the Federal Reserve Bank of St. Louis, can
take the place of the sector factors or add to the sector factors.

## Logistics

- **Dates:** Released Sunday, November 22, 2026. Upload a ZIP of your PS6 folder
  to Canvas by **11:59 PM ET on Sunday, December 6, 2026**.
- **Revisions:** Submit attempted work by the deadline, even if it is
  unfinished. You may then revise with **New Attempt** on Canvas until
  December 19, 2026 at 11:59 PM ET, with no late penalty. We keep your highest
  score, even if you change tracks. A missing, empty, or unreadable submission
  receives a **Frozen Zero** and cannot be revised.
- **Grading:** See the [grading rubric](RUBRIC.md). You are graded on your
  calculations and interpretation, not on whether the synthetic market matches
  the real market.
- **Reference solution:** Released after the deadline. Use the solution to
  understand your mistakes, but do not copy the solution. Copying results in a
  score of 0.
- **Collaboration and AI:** You may discuss ideas and use course materials,
  documentation, the internet, and AI tools. Submit your own work, and do not
  share code or solutions.

## Getting started

Use Julia `1.12.7`. The daily prices of SPY and its stocks come with the course
package, and the four FRED series come in
[data/fred-levels-2014-2024.csv](data/fred-levels-2014-2024.csv).

1. Download the `Source code (zip)` archive from the tagged
   [PS6 GitHub release](https://github.com/varnerlab/PS6-CHEME-4660-5660-Fall-2026/releases/tag/ps6-cheme-4660-5660-2026.1)
   and extract it.
2. In VS Code, open the extracted folder containing
   [Project.toml](Project.toml), and open a terminal there.
3. Install the packages, including `JumpHMM`, the course package for jump hidden
   Markov models. The installation needs internet access:

   ```text
   julia --project=. --startup-file=no -e "using Pkg; Pkg.instantiate()"
   ```

4. Set [TRACK.txt](TRACK.txt) to exactly `standard` or `advanced`:

   | Track | Functions to complete | Questions to answer |
   |:--|:--|:--|
   | Standard | Three functions in [src/Standard.jl](src/Standard.jl): `least_squares_fit`, `sector_matrix`, and `compose_growth_rates` | [responses/Standard.md](responses/Standard.md) |
   | Advanced | Six functions in [src/Advanced.jl](src/Advanced.jl): the same three plus `unmix_factors`, `mix_factors`, and `economic_factor` | [responses/Advanced.md](responses/Advanced.md) |

5. Answer Question 1, your prediction, before you write any code.
6. Replace each `error("Complete ...")` line with the code that the TODO comment
   above it gives, without the `#` in front.
7. Run the checker as you work:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

   The checker runs your track's checks and writes `results/Report.md`. A row
   or a table that needs an unfinished function shows `UNAVAILABLE`. Once your
   functions work, the checker takes less than a minute.

Each function's docstring gives the rule, the course material that does the
same calculation, and the slide of the [mathematical
companion](docs/PS6-Mathematical-Companion.pdf) with the formulas. Grading uses
only `TRACK.txt` and your track's source and response files.

## The model

The supplied code in `src/Model.jl` follows the fitting and sampling algorithms
of lecture L14a step by step, and calls your functions for the calculations.

**The data.** The real market is SPY and 375 of its stocks in 11 sectors: every
stock with daily prices from 2014 to 2024 and a sector of the Global Industry
Classification Standard (GICS), with one ticker per company. The growth rates
are daily, in units of 1/yr, as in the course examples.

**The general factor model** explains the growth rate of each stock on each day
as the sum of five parts: a baseline, a market part, an economic part, a sector
part, and a stock-specific part. The market part is the growth rate of SPY times
the stock's market sensitivity. The economic part adds up each economic factor
times the stock's loading on that factor, and the sector part does the same for
the sector factors.

**Fitting.** The fitting algorithm has five steps:

1. For each stock, fit the stock's growth rates to SPY and, on the Advanced
   track, the economic factors. The fit gives the baseline, the market
   sensitivity, and the economic loadings, and leaves a residual.
2. For each day, fit the residuals of all the stocks to the **sector matrix**,
   which marks the sector of each stock. Each sector factor of that day is the
   average residual of the stocks in that sector.
3. For each stock, fit the residual to the sector factors. The fit gives the
   sector loadings, and the rest of the residual is the stock-specific part.
4. On the Advanced track, unmix the factors (see the Advanced section).
5. Fit a single-asset jump hidden Markov model to each factor and to the
   stock-specific part of each stock.

Steps 1, 2, and 3 are the same least-squares solve with different inputs, and
your function `least_squares_fit` does that solve.

**Sampling.** Each jump hidden Markov model draws a path of 2,766 trading
days, and your function `compose_growth_rates` adds the five parts into the
growth rates of each synthetic stock. The checker draws 10 synthetic markets
from a fixed seed, so every run draws the same synthetic markets.

**The report.** The table **Real and synthetic markets** in
`results/Report.md` has one row for the real market and one row for each
model. Each correlation column averages the correlation over every pair of
stocks of one kind, such as two different stocks in the same sector. The row
**real market** gives one value in each column. Each model's row gives the
lowest and the highest value over the 10 synthetic markets. A model matches the
real market in a column when the real value falls inside that model's range.

## Standard: the market and the sectors

Complete `least_squares_fit`, `sector_matrix`, and `compose_growth_rates`. Run
the checker, and answer Questions 2 and 3 from the table **Real and synthetic
markets**. The table compares the real market with two models: the **single
index model**, which has the market part and the stock-specific part but no
sector factors, and the **market and sectors**.

## Advanced: the Cholesky step and the FRED series

Complete the three Standard functions in `src/Advanced.jl`, then complete
`unmix_factors`, `mix_factors`, and `economic_factor`.

The factors of the real market are correlated. Fitting step 4 unmixes the
factors: `unmix_factors` computes the covariance matrix of the factors and its
Cholesky factor, and turns the factors into uncorrelated factors. The supplied
code fits a jump hidden Markov model to each uncorrelated factor, and
`mix_factors` mixes the draws back into correlated factors. The L6a course
example
[Simulating a Portfolio with Multiple Asset Geometric Brownian Motion](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/main/lectures/week-6/L6a/CHEME-5660-L6a-Example-MAGBM-Portfolio-Fall-2026.ipynb)
uses the same mixing.

Your function `economic_factor` turns each FRED series into an economic factor.
The file `data/fred-levels-2014-2024.csv` holds the level of four FRED series
on each trading day:

| FRED series | Level | Economic factor |
|:--|:--|:--|
| `DGS10` | 10-year Treasury yield (percent) | daily change |
| `T10YIE` | 10-year breakeven inflation rate, a market measure of expected inflation (percent) | daily change |
| `DCOILBRENTEU` | Brent crude oil price (USD per barrel) | growth rate |
| `DTWEXBGS` | US dollar index against a broad basket of currencies | growth rate |

We use the Brent oil price because the WTI oil price fell below zero on April
20, 2020, and a growth rate needs a positive price.

Rerun the checker. Answer Question 2 from the row **market and sectors, with
the Cholesky step**. Answer Question 3 from two rows and one table. The row
**market and FRED series, with the Cholesky step** uses the four FRED series in
place of the 11 sector factors. The row **market, sectors, and FRED series, with
the Cholesky step** adds the four FRED series to the sector factors. The table
**FRED series** gives the R² and the loadings of fitting step 1 for each
sector.

This product uses the FRED® API but is not endorsed or certified by the Federal
Reserve Bank of St. Louis.

## Explore on your own

The exploration is optional and not graded. You will rerun the report with
your own settings in `config/explore.toml`, a copy of the graded settings:

```text
julia --project=. --startup-file=no explore.jl
```

The script uses your finished functions and writes
`results/exploration/Exploration.md`. Try two questions:

- Change the `seed`. Does each model still match the real market in the same
  columns?
- Choose other pairs of sectors in `pair_first` and `pair_second`. Which other
  pairs does the row **market and sectors** miss? On the Advanced track, does
  the Cholesky step fix those pairs too?

## Check and submit your work

1. Save your code and answers, and run the checker one more time:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

   The checker flags unanswered questions and writes `MANIFEST.txt`.
2. ZIP the whole PS6 folder as `CHEME-5660-PS6-<your netid>.zip`.
3. Upload the ZIP to the PS6 assignment on Canvas.
