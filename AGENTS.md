# PS6 assignment conventions

- Keep the README and response files free of equations, LaTeX commands, and
  math delimiters. Explain the task in plain language.
- Organize the assignment around its central question: do hidden states, and
  random moves between them, help the Farmer-Joshi market reproduce the
  stylized facts of the daily growth rates of SPY? The market model is from
  lecture L12a; the benchmark is the daily SPY data (`benchmark_ticker`).
- Three tracks. Standard: the 3-state rule, excess kurtosis, and volatility
  clustering. Advanced: Standard plus the conviction ladder. Expert: Advanced
  plus hesitant moves between states and the transition matrix.
- All settings live in `config/defaults.toml`, read by `load_config` in
  `src/Config.jl`. The file is graded, so students do not edit it. The track
  is chosen in `TRACK.txt`.
- Student code is plain course-style Julia: documented top-level functions,
  explicit loops and if-blocks, and a comment above each step.
- Keep instructor solutions, expected results, and numerical answers out of
  every student file. They live in `instructor/reference/`, which is not
  tracked.
