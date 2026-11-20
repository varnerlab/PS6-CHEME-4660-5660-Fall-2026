# Problem Set 6 (PS6): Do Hidden States Make the Farmer–Joshi Market Look Real?

The daily growth rates of real stock prices share a few patterns, called
**stylized facts**. Large daily moves happen more often than a Normal
distribution predicts (**fat tails**). Large moves come in clusters, so calm
periods and turbulent periods alternate (**volatility clustering**). One day's
growth rate says little about the next day's growth rate (a **weak
autocorrelation**).

The **Farmer–Joshi market**, from the L12a course example
[The Farmer–Joshi Market](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/main/lectures/week-12/L12a/CHEME-5660-L12a-Example-FarmerJoshi-Fall-2026.ipynb),
is a model of one asset traded by two groups of traders. **Value investors**
buy when the price is below their estimate of the asset's value, and sell when
the price is above that estimate. **Trend followers** buy after the price has
risen, and sell after the price has fallen. Each trader is short, flat, or
long, and computes a **signal**, a number that is positive when the trader
favors a long position. A flat trader enters a position when the signal passes
the trader's **entry threshold**, and a trader holding a position exits when
the signal falls back past the trader's **exit threshold**. A **market maker**
fills every order and moves the price in the direction of the traders' net
demand. As in the course example, we'll compare the growth rates of this market
with the daily growth rates of SPY, an exchange-traded fund that tracks the
S&P 500 index.

PS6 gives the traders **hidden states**. The market sees each trader's
position, but not the trader's state. The idea comes from a student project and
from our class discussion (L12a) of giving the traders states like those of a
hidden Markov model.

> **Do hidden states, and random moves between them, help the Farmer–Joshi
> market reproduce the stylized facts of the daily growth rates of SPY?**

We'll explore this question on three tracks, and you will choose one.
**Standard** measures the course example's market, which has no hidden states,
and compares the market with SPY. **Advanced** adds a **conviction ladder**:
extra flat states in which a trader builds conviction before taking a position.
Advanced compares markets with 3, 5, and 7 states. **Expert** adds **hesitant
traders**, who move to a new state only with a fixed probability, and compares
three values of that probability.

## Logistics

- **Dates:** Released Sunday, November 22, 2026. Upload a ZIP of your PS6 folder
  to Canvas by **11:59 PM ET on Sunday, December 6, 2026**.
- **Revisions:** Submit attempted work by the deadline, even if it is
  unfinished. You may then revise until December 19, 2026 at 11:59 PM ET. We
  keep your highest score, even if you change tracks. A missing, empty, or
  unreadable submission receives a **Frozen Zero** and cannot be revised.
- **Grading:** The most you can earn is 4 on Standard, 4 plus one Magic Point
  on Advanced, and 4 plus two Magic Points on Expert. You can earn at most two
  Magic Points on PS6. A 3 or 4 requires passing every check, and the teaching
  team then reviews your code and answers. You are graded on your calculations
  and interpretation, not on whether the market matches SPY. See the [grading
  rubric](RUBRIC.md).
- **Reference solution:** Released after the deadline. Use the solution to
  understand your mistakes, but do not copy the solution. Copying results in a
  score of 0.
- **Collaboration and AI:** You may discuss ideas and use course materials,
  documentation, the internet, and AI tools. Submit your own work, and do not
  share code or solutions.

## Getting started

Use Julia `1.12.7`. The SPY closing prices come with the course package, and the
packages are the same as in PS5.

1. Download the `Source code (zip)` archive from the tagged
   [PS6 GitHub release](https://github.com/varnerlab/PS6-CHEME-4660-5660-Fall-2026/releases/tag/ps6-cheme-4660-5660-2026.1)
   and extract it.
2. In VS Code, open the extracted folder containing
   [Project.toml](Project.toml), and open a terminal there.
3. Install the packages. The installation needs internet access:

   ```text
   julia --project=. --startup-file=no -e 'using Pkg; Pkg.instantiate()'
   ```

4. Set [TRACK.txt](TRACK.txt) to exactly `standard`, `advanced`, or `expert`:

   | Track | Functions to complete | Questions to answer |
   |:--|:--|:--|
   | Standard | Three functions in [src/Standard.jl](src/Standard.jl): `three_state_rung`, `excess_kurtosis`, and `volatility_clustering` | [responses/Standard.md](responses/Standard.md) |
   | Advanced | Four functions in [src/Advanced.jl](src/Advanced.jl): the same three plus `conviction_rung` | [responses/Advanced.md](responses/Advanced.md) |
   | Expert | Six functions in [src/Expert.jl](src/Expert.jl): the same four plus `hesitant_rung` and `transition_matrix` | [responses/Expert.md](responses/Expert.md) |

5. Answer Question 1a, your prediction, before you write any code.
6. Complete each function by replacing each `error("Complete ...")` with your
   calculation. Follow the TODO hint above each `error` line, then delete the
   TODO. Do not change the function names, arguments, docstrings, or supplied
   return statements.
7. Run the checker as you work:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

   The checker runs the 12 Standard, 16 Advanced, or 24 Expert checks and writes
   `results/Report.md`. Unfinished calculations show `UNAVAILABLE`. Once your
   functions work, the checker takes up to two minutes.

You complete `excess_kurtosis` and `volatility_clustering` by copying a few
lines from the course example. Each docstring names the course material that
does the same calculation, and the slide of the [mathematical
companion](docs/PS6-Mathematical-Companion.pdf) that gives the formulas.

Edit only `TRACK.txt`, your track's source and response files, `Include.jl`,
`config/explore.toml`, and any helper files you add. Put helper functions in
`.jl` files under [src](src), load the files from [Include.jl](Include.jl), and
document each function.

## The market and its states

**The rungs.** We'll model a trader's state as an integer, the **rung**. In the
course example, a trader has three states, which we number as rungs `-1`
(short), `0` (flat), and `1` (long). We call the course example's rule the
**three-state rule**:

- A trader on rung `0` moves to rung `1` when the signal is above the entry
  threshold, and to rung `-1` when the signal is below minus the entry
  threshold.
- A trader on rung `1` exits to rung `0` when the signal falls below the exit
  threshold. A trader on rung `-1` exits to rung `0` when the signal rises above
  minus the exit threshold.

A **conviction ladder** has more rungs. With 5 states, the rungs run from `-2`
to `2`. A trader holds a long position only on the top rung and a short position
only on the bottom rung, and holds no position on any rung in between. With 5
states, the market cannot tell a trader on rung `1` from a trader on rung `0`,
because neither trader holds a position: the rung is the trader's hidden state.

**The simulator.** The supplied code in `src/Market.jl` runs the course
package's Farmer–Joshi market one step at a time. One step is one trading day.
Each group has 1,200 traders. At each step, the simulator computes each trader's
signal, calls your function for the trader's next rung, and adds up the changes
in the traders' positions to get the net demand. The market maker then moves
the log price in the direction of the net demand, and random noise moves both
the log price and the log value.

- A value investor's signal is the investor's estimate of the log value minus
  the log price. The estimate is the log value plus the investor's fixed offset.
- A trend follower's signal is the change in the log price over the trader's
  lag, the fixed number of steps the trader looks back.

Each trader draws an entry threshold and a lower exit threshold, which stay
fixed while the market runs. The graded settings are in `config/defaults.toml`.

**The stylized facts.** The **growth rate** of the price over one step is the
change in the log price divided by the length of the step in years, in 1/yr. The
report compares the growth rates of each simulated market with the daily growth
rates of SPY, from the closing prices of 2014 to 2024 that come with the course
package. Each simulated row is the mean over 5 runs of 20,000 steps. Every table
has these columns:

| Column | What the column measures |
|:--|:--|
| Excess kurtosis | Fat tails: `0` for a Normal distribution, and larger when large moves are more common than in a Normal distribution |
| Clustering, lags 1–10 and lags 11–50 | Volatility clustering: the mean autocorrelation of the absolute growth rates over lags 1 to 10 or 11 to 50, measured in steps |
| Autocorrelation, lag 1 | The correlation of each growth rate with the growth rate one step later |
| Volatility (1/sqrt(yr)) | The annualized volatility of the price, which measures the size of the price moves |
| Gap spread | The standard deviation of the log price minus the log value: how far the price wanders from the value. The course package gives no value for SPY, so SPY's gap spread is `n/a`. |

Below each table, the report gives the half-width of the **white-noise band**:
for a series with no autocorrelation, 95% of the autocorrelations lie between
minus and plus this number. As in the course example, we compare the patterns
in the growth rates, not the size of the moves.

## Standard: the three-state rule

Complete these functions:

1. **`three_state_rung`** returns a trader's next rung under the three-state
   rule.
2. **`excess_kurtosis`** returns the excess kurtosis of a market's growth rates,
   from population moments.
3. **`volatility_clustering`** returns the mean autocorrelation of the absolute
   growth rates over a list of lags.

Run the checker, read the table **Farmer–Joshi and SPY** in `results/Report.md`,
and answer Questions 1 and 2. The table compares SPY with three markets: **value
investors only**, **trend followers only**, and **both groups**. Standard
students also answer Question 3 from this table.

## Advanced: the conviction ladder

Complete the Advanced copies of the three Standard functions, then complete one
more function:

4. **`conviction_rung`** returns a trader's next rung on a conviction ladder
   with rungs from `-K` (the bottom rung) to `K` (the top rung). On every other
   rung, the trader is flat. A flat trader moves one rung up when the signal is
   above the entry threshold, and one rung down when the signal is below minus
   the entry threshold. Otherwise the trader's conviction fades, and the trader
   moves one rung toward rung `0`, or stays on rung `0` if the trader is already
   there. On the top rung, the trader exits to the rung below when the signal
   falls below the exit threshold. On the bottom rung, the trader exits to the
   rung above when the signal rises above minus the exit threshold. With 3
   states, this rule is the three-state rule.

Rerun the checker, read the table **Conviction ladders**, and answer Question 3.
The table compares SPY with the market with both groups at 3, 5, and 7 states.

## Expert: hesitant traders

Complete the Expert copies of the four Advanced functions, then complete two
more functions:

5. **`hesitant_rung`** returns a hesitant trader's next rung. At each step, the
   simulator draws one random number for each trader, uniformly between `0` and
   `1`. The trader moves to the rung that `conviction_rung` proposes when that
   number is below the probability `p`, and otherwise stays on the current rung.
   Entries and exits are both hesitant.
6. **`transition_matrix`** returns the one-step transition matrix of one
   trader's rung at a fixed signal. Each entry is the probability of moving in
   one step from the row's rung to the column's rung, so each row sums to one.

The report uses your `transition_matrix` to compute the expected number of steps
a trader takes to go from rung `0` (flat) to the top rung (long) while the
signal stays above the entry threshold. Rerun the checker, read the tables
**Conviction ladders** and **Hesitant traders**, and answer Question 3. The
table **Hesitant traders** compares SPY with the market with both groups at 5
states, with `p` set to `1`, `0.5`, and `0.2`.

## Explore on your own

Change any setting in `config/explore.toml`, a copy of the graded settings, and
run:

```text
julia --project=. --startup-file=no explore.jl
```

The script `explore.jl` builds your track's report from your functions and the
settings in `config/explore.toml`, and writes
`results/exploration/Exploration.md`. The exploration is not graded. Try other
numbers of states (any odd number of 3 or more), other probabilities,
other numbers of value investors and trend followers, other noise levels, or
other seeds.

## Check and submit your work

1. Save your code and answers, and run the checker one more time:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

   The checker flags unanswered questions and writes `MANIFEST.txt`.
2. ZIP the whole PS6 folder as `CHEME-5660-PS6-<your netid>.zip`.
3. Upload the ZIP to the PS6 assignment on Canvas.
