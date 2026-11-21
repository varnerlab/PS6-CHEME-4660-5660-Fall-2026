# PS6 Expert responses

Answer each question in one or two short paragraphs, and cite numbers from
`results/Report.md`. Replace each `TODO` line with your answer. Keep the marker
lines around each answer, because the checker reads those lines.

## 1. Will the synthetic stocks move together like the real stocks?

Answer this question before you write any code. Your prediction is not graded
for accuracy. The synthetic market draws SPY, each sector factor, and the
stock-specific part of each stock from separate single-asset jump hidden Markov
models. Will two synthetic stocks in the same sector move together as much as
two real stocks in the same sector? Will two stocks in different sectors?
Explain why. Which sectors do you expect to move with the 10-year
Treasury yield, and in which direction? With the Cholesky step, will adding the
FRED series move the synthetic market closer to the real market?

<!-- answer-1:start -->
TODO: Answer Question 1.
<!-- answer-1:end -->

## 2. What do the sector factors add?

In the table **Real and synthetic markets**, compare the rows **single index
model** and **market and sectors** with the row **real market**. What do the
sector factors add to the synthetic market? Use the columns **Same sector** and
**Different sectors** in your answer.

<!-- answer-2:start -->
TODO: Answer Question 2.
<!-- answer-2:end -->

## 3. Does the FRED data help?

Answer for the fit and for the synthetic market. In the table **FRED series**,
which sectors gain the most R² when fitting step 1 adds the FRED series, and
which loadings explain the gain? In the table **Real and synthetic markets**,
compare the row **market, FRED series, and sectors, with the Cholesky step**
with the rows **market and sectors, with the Cholesky step** and **real
market**. Does the FRED data move the synthetic market closer to the real
market? Why do the two answers differ? Was your prediction in Question 1 right?

<!-- answer-3:start -->
TODO: Answer Question 3.
<!-- answer-3:end -->
