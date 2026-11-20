# Problem Set 6 (PS6): Do Hidden States Make the Farmer–Joshi Market Look Real?

The daily growth rates of real stock prices share a few patterns, called
**stylized facts**. Large daily moves happen more often than a Normal
distribution predicts (**fat tails**). Large moves come in clusters, so calm
and turbulent periods alternate (**volatility clustering**). One day's
growth rate says little about the next day's growth rate (a **weak
autocorrelation**).

The **Farmer–Joshi market**, from the L12a course example
[The Farmer–Joshi Market](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/main/lectures/week-12/L12a/CHEME-5660-L12a-Example-FarmerJoshi-Fall-2026.ipynb),
is a model of one asset traded by two groups of traders. **Value investors**
buy when the price is below their estimate of the asset's value, and sell when
the price is above that estimate. **Trend followers** buy after the price has
risen, and sell after the price has fallen. We'll compare the growth rates of
this market with the daily growth rates of SPY, an exchange-traded fund that
tracks the S&P 500 index.

In PS6, each trader has a **hidden state**: the market sees the trader's
position, but not the trader's state. The idea comes from a student project and
from our discussion in L12a.

> **Do hidden states, and random moves between them, help the Farmer–Joshi
> market reproduce the stylized facts of the daily growth rates of SPY?**

We'll explore this question on three tracks, and you will choose one.
**Standard** measures the course example's market. **Advanced** adds extra
states in which a trader holds nothing and builds conviction before buying or
selling. **Expert** adds **hesitant traders**, who move to a new state only with
a fixed probability.

## Logistics

- **Dates:** Released Sunday, November 22, 2026. Upload a ZIP of your PS6 folder
  to Canvas by **11:59 PM ET on Sunday, December 6, 2026**.
- **Revisions:** Submit attempted work by the deadline, even if it is
  unfinished. You may then revise with **New Attempt** on Canvas until
  December 19, 2026 at 11:59 PM ET, with no late penalty. We keep your highest
  score, even if you change tracks. A missing, empty, or unreadable submission
  receives a **Frozen Zero** and cannot be revised.
- **Grading:** See the [grading rubric](RUBRIC.md). You are graded on your
  calculations and interpretation, not on whether the market matches SPY.
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
   | Standard | Three functions in [src/Standard.jl](src/Standard.jl): `three_state_rule`, `excess_kurtosis`, and `volatility_clustering` | [responses/Standard.md](responses/Standard.md) |
   | Advanced | Four functions in [src/Advanced.jl](src/Advanced.jl): the same three plus `conviction_rule` | [responses/Advanced.md](responses/Advanced.md) |
   | Expert | Six functions in [src/Expert.jl](src/Expert.jl): the same four plus `hesitant_rule` and `transition_matrix` | [responses/Expert.md](responses/Expert.md) |

5. Answer Question 1, your prediction, before you write any code.
6. Replace each `error("Complete ...")` line with your calculation. Follow the
   TODO hint above the line, then delete the TODO.
7. Run the checker as you work:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

   The checker runs your track's checks and writes `results/Report.md`. A table
   that needs an unfinished function shows `UNAVAILABLE`. Once your functions
   work, the checker takes up to two minutes.

Each function's docstring gives the rule, the course material that does the
same calculation, and the slide of the [mathematical
companion](docs/PS6-Mathematical-Companion.pdf) with the formulas. Grading uses
only `TRACK.txt`, your track's source and response files, `Include.jl`, and any
helper files you add under [src](src).

## The market

The simulator in `src/Market.jl` runs the Farmer–Joshi market one step at a
time. One step is one trading day, and each group has 1,200 traders. Each trader
computes a **signal**, a number that is positive when the trader favors a long
position:

- A value investor's signal is the investor's estimate of the log value minus
  the log price.
- A trend follower's signal is the change in the log price over the trader's
  lag, the fixed number of steps the trader looks back.

**States.** In the course example, each trader has three states: `-1`
(short), `0` (flat), and `1` (long). A flat trader enters a position when the
signal passes the trader's **entry threshold**. A trader with a position exits
when the signal falls back past the trader's **exit threshold**. We call this
rule the **three-state rule**.

At each step, the simulator calls your function for each trader's next state.
The changes in the traders' positions add up to the net demand, which moves the
log price. Random noise moves both the log price and the log value.

**The report.** The checker writes `results/Report.md`, which compares each
simulated market with the daily growth rates of SPY from 2014 to 2024. Each
simulated row is the mean over 5 runs of 20,000 steps. The columns measure fat
tails (the excess kurtosis, `0` for a Normal distribution), volatility
clustering at lags 1–10 and 11–50, the autocorrelation at lag 1, the volatility,
and the **gap spread**, how far the price wanders from the value. As in the
course example, we compare the patterns in the growth rates, not the size of the
moves. Below each table, the report gives the **white-noise band**: for a series
with no autocorrelation, about 95% of the autocorrelations fall between minus
and plus this number.

## Standard: the three-state rule

Complete `three_state_rule`, `excess_kurtosis`, and `volatility_clustering`. Run
the checker, and answer Questions 2 and 3 from the table **Farmer–Joshi and
SPY**. The table compares SPY with three markets: **value investors only**,
**trend followers only**, and **value investors and trend followers**. On the
Advanced and Expert tracks, answer only Question 2 from this table.

## Advanced: more states

Complete the three Standard functions in `src/Advanced.jl`, then complete
`conviction_rule`. With 5 states, the states run from `-2` to `2`. A trader
holds a long position only in state `2` and a short position only in state
`-2`, so the market cannot tell a trader in state `1` from a trader in state
`0`. A strong signal moves a flat trader one state toward a position. Otherwise
the trader's conviction fades one state back toward `0`. The docstring gives the
full rule.

Rerun the checker, and answer Question 3 from the table **More states**. The
table compares SPY with the market of value investors and trend followers,
with 3, 5, and 7 states per trader.

## Expert: hesitant traders

Complete the four Advanced functions in `src/Expert.jl`, then complete
`hesitant_rule` and `transition_matrix`. A hesitant trader moves to the state
that `conviction_rule` proposes only with probability `p`. Otherwise the trader
stays in the current state. The transition matrix holds the probability of each
one-step move between states. The report uses your matrix to compute the
expected number of steps a flat trader takes to go long while the signal stays
above the entry threshold.

Rerun the checker, and answer Question 3 from the tables **More states** and
**Hesitant traders**. The table **Hesitant traders** compares SPY with the
market of value investors and trend followers, with 5 states per trader and
`p` set to `1`, `0.5`, and `0.2`.

## Explore on your own

Change any setting in `config/explore.toml`, a copy of the graded settings, and
run:

```text
julia --project=. --startup-file=no explore.jl
```

The script writes `results/exploration/Exploration.md` with your functions. The
exploration is not graded.

**Just for fun.** This idea earns no points, and you do not need to try it. You
could build a new agent-based model by adding a third kind of trader, **noise
traders**, who buy and sell on private signals that the market cannot see. Each
noise trader's signal is a new random number at each step. The code is already
in `simulate_market` in `src/Market.jl`, commented out between `#=` and `=#`
lines. Work in a copy of your PS6 folder, so that the checker still runs the
supplied market. Delete those lines in the copy, and run `explore.jl` there.
Which stylized facts do noise traders change?

## Check and submit your work

1. Save your code and answers, and run the checker one more time:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

   The checker flags unanswered questions and writes `MANIFEST.txt`.
2. ZIP the whole PS6 folder as `CHEME-5660-PS6-<your netid>.zip`.
3. Upload the ZIP to the PS6 assignment on Canvas.
