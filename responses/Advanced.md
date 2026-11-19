# PS6 Advanced responses

**Central question:** Do hidden states, and random moves between them, help the
Farmer–Joshi market reproduce the stylized facts of the daily growth rates of
SPY?

Write a few sentences for each lettered part, and label each part with its
letter. Cite numbers from `results/Report.md`. Put your answer between each
question's `<!-- answer-N:start -->` and `<!-- answer-N:end -->` markers, in
place of the TODO.

## 1. Which stylized facts will the market reproduce?

**a. What do you predict?** Answer before you write any code; accuracy is not
graded. The daily growth rates of SPY have fat tails, volatility clustering, and
a weak autocorrelation. Which of these stylized facts will the market with both
value investors and trend followers reproduce? Which group of traders do you
expect to cause each stylized fact, and why? Will a conviction ladder with 5
or 7 states move the market closer to SPY, and why?

**b. What are the stylized facts of SPY?** In **Farmer–Joshi and SPY**, use the
row **SPY (daily closes)**. Cite the excess kurtosis, the clustering at
lags 1–10 and at lags 11–50, and the autocorrelation at lag 1. Do the two
clustering values and the autocorrelation at lag 1 lie outside the white-noise
band for SPY? What does each value say about the daily growth rates of SPY?

<!-- answer-1:start -->
TODO: Answer parts a and b.
<!-- answer-1:end -->

## 2. How does each group of traders shape the growth rates?

**a. What does each group produce alone?** In **Farmer–Joshi and SPY**, compare
the rows **value investors only** and **trend followers only** with SPY. Cite
the excess kurtosis, the clustering at lags 1–10, and the autocorrelation at
lag 1. Which stylized facts does each group produce alone? Explain each group's
autocorrelation at lag 1 with the group's rule for buying and selling.

**b. What changes when both groups trade?** Compare the row **both groups** with
the rows **value investors only** and **trend followers only**. How do the value
investors change the autocorrelation at lag 1 and the gap spread, compared with
the market of trend followers only? Explain the change with the value investors'
rule.

<!-- answer-2:start -->
TODO: Answer parts a and b.
<!-- answer-2:end -->

## 3. Do hidden states move the market toward SPY?

**a. How do the stylized facts change with the number of states?** In
**Conviction ladders**, compare the rows **both groups, 3 states**, **both
groups, 5 states**, and **both groups, 7 states** with SPY. Cite the excess
kurtosis, the clustering at both lag ranges, and the autocorrelation at lag 1.
Which values move toward SPY's values as the number of states rises, and which
values move away?

**b. What does the hidden state change about when a trader trades?** With 5
states, how many consecutive steps with a signal above the entry threshold does
a flat trader on rung `0` need to enter a long position? What happens to the
trader's rung when the signal drops below the entry threshold before the trader
enters? Use these answers to explain the changes in part a.

**c. What can we conclude?** Do hidden states help the Farmer–Joshi market
reproduce the stylized facts of SPY? Was your prediction in part 1a right?

<!-- answer-3:start -->
TODO: Answer parts a, b, and c.
<!-- answer-3:end -->
