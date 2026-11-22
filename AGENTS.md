# PS6 assignment conventions

- Keep the README and response files free of equations, LaTeX commands, and
  math delimiters. Explain the task in plain language.
- Organize the assignment around its central question: does a synthetic market
  built from single-asset jump hidden Markov models move together like the real
  market? The model is the general factor model of lecture L14a, section
  'Building a General Factor Model'; the real market is SPY
  (`benchmark_ticker`) and its 375 stocks.
- Two tracks. Standard: the market and the sector factors (`least_squares_fit`,
  `sector_matrix`, `compose_growth_rates`). Advanced: Standard plus the Cholesky
  step (`unmix_factors`, `mix_factors`) and four FRED series as economic factors
  (`economic_factor`), used in place of the sector factors and added to them.
- The report gives each model's lowest and highest value over the 10
  synthetic markets. A model matches the real market in a column when the
  real value falls inside that model's range.
- The supplied code in `src/Model.jl` follows the lecture's fitting and sampling
  algorithms exactly. `least_squares_fit` is the one solve for fitting steps 1,
  2, and 3.
- All settings live in `config/defaults.toml`, read by `load_config` in
  `src/Config.jl`. The file is graded, so students do not edit it. The track
  is chosen in `TRACK.txt`.
- The FRED series ship in `data/fred-levels-2014-2024.csv`, built by
  `instructor/make_fred_data.jl`. Never commit or print the FRED API key.
- Student code is plain course-style Julia: documented top-level functions,
  explicit loops and if-blocks, and a comment above each step.
- The checks grade the code, and the teaching team grades only the answers
  (a 3 or a 4). Students write no docstrings and no helper functions, and
  nothing grades code quality.
- Keep instructor solutions, expected results, and numerical answers out of
  every student file. They live in `instructor/reference/`, which is not
  tracked.
