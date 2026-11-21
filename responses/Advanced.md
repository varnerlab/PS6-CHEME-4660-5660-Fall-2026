# PS6 Advanced responses

Answer each question in one or two short paragraphs. In Questions 2 and 3, cite
numbers from `results/Report.md`. Replace each `TODO` line with your answer.
Keep the marker lines around each answer, because the checker reads those lines.

## 1. Will the synthetic stocks move together like the real stocks?

Answer this question before you write any code. Your prediction is not graded
for accuracy. The synthetic market draws SPY, each sector factor, and the
stock-specific part of each stock from separate single-asset jump hidden Markov
models. In the real market, the sector factors of Real Estate and Utilities
move together. Will a synthetic stock in Real Estate and a synthetic stock in
Utilities move together as much as two real stocks do, without the Cholesky
step and with it? Can four economic factors from FRED, such as the daily change
in the 10-year Treasury yield, take the place of the 11 sector factors? Explain
both predictions.

<!-- answer-1:start -->
TODO: Answer Question 1.
<!-- answer-1:end -->

## 2. What does the Cholesky step add?

Compare the row **market and sectors, with the Cholesky step** with the rows
**market and sectors** and **real market**. Which columns move toward the real
market, and why? Was your prediction about the Cholesky step right?

<!-- answer-2:start -->
TODO: Answer Question 2.
<!-- answer-2:end -->

## 3. Can the FRED series take the place of the sector factors?

Compare the row **market and FRED series, with the Cholesky step** with the
rows **single index model**, **market and sectors, with the Cholesky step**,
and **real market**. Can the four FRED series take the place of the 11 sector
factors? Use the table **FRED series** to explain your answer: which sectors
does fitting step 1 explain better with the FRED series, and by how much? Was
your prediction about the FRED series right?

<!-- answer-3:start -->
TODO: Answer Question 3.
<!-- answer-3:end -->
