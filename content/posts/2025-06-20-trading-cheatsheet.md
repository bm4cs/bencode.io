---
layout: post
draft: false
title: "Derivatives Trading"
slug: "trading"
date: "2025-10-11 08:34:00+1000"
lastmod: "2025-10-11 08:34:00+1000"
comments: false
categories:
  - stocks
  - trading
  - shares
  - minis
  - warrants
  - options
---

This post captures foundational knowledge that will help master Australian derivates trading.

- [Options Fundamentals](#options-fundamentals)
  - [Call Option Analogy: Renting the Right to Buy a House Later](#call-option-analogy-renting-the-right-to-buy-a-house-later)
  - [Put Option Analogy: Renting the Right to Sell a House Later](#put-option-analogy-renting-the-right-to-sell-a-house-later)
  - [American vs European](#american-vs-european)
  - [Buyer vs Seller](#buyer-vs-seller)
  - [Options Bring Flexibility](#options-bring-flexibility)
  - [The Value of an Option](#the-value-of-an-option)
    - [Call Value Example](#call-value-example)
  - [Option Premiums](#option-premiums)
- [End-To-End Call Walkthrough](#end-to-end-call-walkthrough)
- [Portfolio Strategies](#portfolio-strategies)
  - [Covered Calls](#covered-calls)
  - [Covered Puts](#covered-puts)
- [Spread Trading](#spread-trading)
  - [Bull Call (debit)](#bull-call-debit)
  - [Bull Put (credit)](#bull-put-credit)
  - [Bear Put (debit)](#bear-put-debit)
  - [Bear Call (credit)](#bear-call-credit)
  - [Condor (debit)](#condor-debit)
  - [Iron Condor (credit)](#iron-condor-credit)
- [Indicators](#indicators)
  - [Stochastics](#stochastics)
  - [Bollinger Bands](#bollinger-bands)
  - [50-Day Moving Average (50-DMA)](#50-day-moving-average-50-dma)
  - [Volume](#volume)
- [Options Trading Cheat Sheet](#options-trading-cheat-sheet)
- [FAQ](#faq)
- [Glossary](#glossary)

## Options Fundamentals

An option is a contract that gives you the right, but not the obligation, to buy or sell a stock at a specific price (called the strike price) before a certain date (the expiration date).

There are two types:

| Option Type | Gives You the Right To | You Use It When |
| ----------- | ---------------------- | --------------- |
| Call        | Buy at a fixed price   | Price goes up   |
| Put         | Sell at a fixed price  | Price goes down |

### Call Option Analogy: Renting the Right to Buy a House Later

Imagine you're dealing with houses instead of stocks.

You find a house you might want to buy in the future. You pay the owner $500 today to get the option to buy it for $100,000 anytime in the next 3 months.

If the house’s market value jumps to $120,000, you still get to buy it for $100,000—you just made a $20,000 profit (minus the $500 you paid).

If the house’s value drops to $90,000, you can walk away. You lose the $500, but you’re not forced to buy.

### Put Option Analogy: Renting the Right to Sell a House Later

Now imagine you own a house and you’re worried its value might drop. You pay $500 for the option to sell it for $100,000 anytime in the next 3 months.

If the market crashes and the house is only worth $80,000, you still get to sell it for $100,000, you just saved $20,000.

If the house goes up to $110,000, you ignore the option and sell it at market price. You lose the $500, but that’s okay.

### American vs European

It comes down to WHEN the option can be exercised.

American Options:

- Can be exercised at any time before or on the expiration date
- More flexible for the buyer
- Most stock options in the US are American-style
- On the ASX are distinguished by round strike prices e.g. `$4.40`

European Options:

- Can only be exercised on the expiration date itself
- No early exercise allowed
- Common for index options (like SPX)
- On the ASX are distinguished with 1 cent offsets on strike prices e.g. `$4.41`

The difference matters most when you want to lock in profits or cut losses before expiration. With American options, you have that choice. With European options, you're locked in until expiration day. Though you can still sell the option in the market before then to exit your position.

American options are generally slightly more valuable due to this added flexibility, though in practice most option holders close positions by selling rather than exercising anyway.

### Buyer vs Seller

You pay a premium upfront to purchase this right. The option's value fluctuates based on the underlying stock's price movements, time remaining until expiration, and other factors like volatility. If the option becomes profitable, you can either exercise it (buy/sell the stock) or sell the option itself for a profit. If it expires worthless, you only lose the premium you paid.

The traits of a Call or Put invert depending if you are the buyer or the seller (aka writer):

| Option Type | Buyer                                                    | Seller                                                           |
| ----------- | -------------------------------------------------------- | ---------------------------------------------------------------- |
| Call        | Pay premium, for right to **BUY** stock at strike price  | Receive the premium, obligated to **SELL** stock at strike price |
| Put         | Pay premium, for right to **SELL** stock at strike price | Receive the premium, obligated to **BUY** stock at strike price  |

Time decay impacts the buyer and seller in opposite ways:

- Buyers fight against time decay. They need the stock to move significantly and quickly.
- Sellers benefit from time decay. They profit as the option loses value over time, even if the stock doesn't move.

Notes:

- `Premium` = `IntrinsicValue` + `TimeValue`
- Its rare that you want options to be exercised, except for **Covered Calls** or **Covered Puts**.

### Options Bring Flexibility

Several strategies that allow you to profit from different market scenarios:

**Directional plays**:

- Bullish: Buy calls to profit from price increases
- Bearish: Buy puts to profit from price decreases

**Non-directional strategies**:

- Straddle: Buy both a call and put at the same strike price. You profit if the stock makes a large move in _either_ direction, regardless of which way it goes. This bets on volatility, not direction.
- Sideways: Sell options (like iron condors or strangles) to collect premiums when you expect the stock to stay relatively flat

**Risk management**:

- Hedge existing stock positions against losses
- Cap your downside to just the premium paid (when buying options)
- Generate income by selling options against stocks you own (covered calls)

**Leverage**:

- Control large amounts of stock with relatively small capital
- Amplify gains (and losses) compared to owning the stock directly

The core flexibility comes from combining different strike prices, expiration dates, and option types (calls/puts) to create strategies tailored to your specific market outlook and risk tolerance.

### The Value of an Option

An option's total price (premium) = **Intrinsic value** + **Time value**

**Intrinsic value**:

The profit you could lock in right now if you exercised the option (zero if the option is out-of-the-money).

If an option allows you to either buy stock cheaper (Call), or sell stock for more (Put), than the share price, it has **intrinsic value**.

| Value Types            | Has Intrinic Value |
| ---------------------- | ------------------ |
| In The Money (ITM)     | ✅                 |
| Out of The Money (OTM) | ❌                 |

**Time value**:

The extra amount people pay for the possibility that the option becomes more valuable before expiration.

Time value erodes as expiration approaches. This is known as **Time decay (theta)**. The closer you get to expiration, the less time there is for the stock to make a favorable move, so the time value decreases.

Time value doesn't disappear linearly. It erodes slowly at first, then accelerates rapidly in the final 30-60 days, with the steepest drop in the last few weeks. **Think logarithmic decay**.

Time decay example:

- A stock trades at $100
- A $100 call option with 6 months until expiration costs $8
- Since the stock is exactly at the strike price, intrinsic value = $0
- The entire $8 is time value. You're paying for the chance the stock rises above $100 before expiration.

#### Call Value Example

```
╔════════════════════════════════════╗
║                                    ║
║        === Call Option ===         ║
║                                    ║
║        Share price: $31.00         ║
║        Strike price: $30.50        ║
║        Expiry: 25 November         ║
║        Option Value: $0.72         ║
║                                    ║
╚════════════════════════════════════╝
```

- Intinsic value = $0.50 ($31.00 - $30.50)
- Time value = $0.22 ($0.72 - $0.50)

**Scenario 1: One week later, share price increase**:

```
╔════════════════════════════════════╗
║                                    ║
║        === Call Option ===         ║
║                                    ║
║        Share price: $32.00         ║
║        Strike price: $30.50        ║
║        Expiry: 25 November         ║
║        Option Value: $1.68         ║
║                                    ║
╚════════════════════════════════════╝
```

- Intinsic value = $1.50 ($32.00 - $30.50)
- Time value = $0.18 ($1.68 - $1.50)
- Profit = 233% = 2.3X = ($1.68 / $0.72 × 100)

A 233% profit off a ~3% increase in share price.

**Scenario 2: One week later, share price decrease**:

```
╔════════════════════════════════════╗
║                                    ║
║        === Call Option ===         ║
║                                    ║
║        Share price: $29.50         ║
║        Strike price: $30.50        ║
║        Expiry: 25 November         ║
║        Option Value: $0.18         ║
║                                    ║
╚════════════════════════════════════╝
```

- Intinsic value = -$1.00 ($29.50 - $30.50)
- Time value = $0.18 ($0.18 - 0)
- Loss = -75% = 0.25X = ($0.18 / $0.72 × 100)

A 75% loss off a ~5% decrease in share price.

### Option Premiums

The premium listed is the per-share price, but you must buy options in contracts of 100 shares.

If you see a _Call Option_ quoted at $3.50, that's the price per share. To calculate your actual cost:

Total cost = Premium × 100 shares per contract × Number of contracts

Example:

- Option premium listed: $3.50
- You buy 1 contract
- Total code = $350 = $3.50 × 100

If you bought 5 contracts at $3.50:

- Total cost = $1750 = $3.50 × 100 × 5

This standardisation means even "cheap" options can require meaningful capital. A $0.50 option still costs you $50 per contract. It also means your profit and loss calculations scale by 100. If that $3.50 option increases to $5.00, you don't make $1.50, you make $150 per contract (minus the premium you paid).

This is part of the leverage component of options; you control 100 shares of stock for a fraction of what it would cost to buy them outright.

## End-To-End Call Walkthrough

Assuming a bullish (uptrending) assessment.

**Entry signals**:

1. Is the open and close in opposite thirds?
2. Does it have a higher high and a higher low?
3. Is it day one or two of the movement?

**Technical analysis**:

1. Model trend lines, support and resistance.
2. Is there enough profit to resistance?
3. Is the stochastic pointing up?
4. Is the share price within bollinger bands?

Resulting analysis:

```
╔══════════════════════════╗
║                          ║
║   Share price:  $4.32    ║
║   Resistance:   $4.45    ║
║   Support:      $4.20    ║
║   Date:        19-Sep    ║
║                          ║
╚══════════════════════════╝
```

**Setting up an In-The-Money (ITM) Call**:

1. Enter the share ticker into _Options Calculator_.
2. Pick a contract with an expiry 6-8 weeks away: 30-Oct
3. Pick a strike 1-2 strike levels below the current price: $4.10
4. Let's say the option is valued at 0.29 or 29 cents per share.
5. Enter a quantity (number of contacts) working back from the overall target risk for the trade e.g. $2500: 2500 / (0.29 × 100) = 86.206 = 86 contracts
6. Calculate the break-even share price: $4.39 (4.10 + 0.29)

**Payoff and technical stops**:

1. Using the _Options Calculator_, determine 20-25% profit thresholds.
2. A resistance of 4.44 would yield $760-800 profit, or 30% (760 / 2494)
3. A support of 4.20 would bleed out a $500-700 loss, or 28% (700 / 2494)

**Entering**:

If you have reached this point, all prior rules must have checked out.

1. In the _Options Calculator_ label the strategy to help track it `ANZ COST 0.45 PROFIT (1.2X) 34.80 0.54 LOSS (0.8X) 33.60 0.36`
2. Buy options between 1500-1600 (typically lowest cost in the day), unless its the second day of move.

**Exiting**:

1. The next day the stock price rose to $4.43 (i.e. almost at resistance)
2. The option is now worth 0.38.
3. Calculate profit: 0.38 - 0.29 = 0.09 or 9 cents = 31% (0.09 / 0.29)
4. Multiplied out by 86 contracts = 0.09 × 100 shares per contact × 85 contracts = $774

## Portfolio Strategies

### Covered Calls

A strategy to profit from sideways or bullish movement, by writing calls against shares you already own.

For example, you own 100 shares of a stock and sell a call option against those shares:

- You own 100 shares of XYZ at $50/share ($5,000 invested)
- You sell a call option with a $55 strike price expiring in 30 days
- You collect $200 premium upfront

Two possible outcomes:

1. Stock stays below $55: The option expires worthless. You keep your shares, keep the $200 premium, and can sell another call next month.
2. Stock rises above $55: Your shares get exercised at $55. You keep the $200 premium plus the $5/share gain ($500), totaling $700 profit. You miss out on any gains above $55.

Benefits:

- **Generate income**: Earn regular premium income from stocks you're holding long-term, especially in flat or mildly bullish markets.
- **Lower cost base**: The premiums collected reduce your effective purchase price of the stock over time.
- **Accept capped upside**: You're willing to sell your shares at the strike price and forgo unlimited upside in exchange for immediate income.

### Covered Puts

A strategy that aims to profit from sideways and bearish movement, by writing puts against a short, giving someone the right to sell stock to us.

An example, you short 100 shares of a stock (borrowing and selling shares you don't own) and sell a put option against that short position.

- You short 100 shares of XYZ at $50/share (you sold borrowed shares for $5,000)
- You sell a put option with a $45 strike price expiring in 30 days
- You collect $200 premium upfront

Two possible outcomes:

- Stock stays above $45: The option expires worthless. You keep the $200 premium, maintain your short position, and can sell another put next month.
- Stock falls below $45: You're obligated to buy shares at $45 to close your short. You keep the $200 premium plus the $5/share gain from shorting at $50 ($500), totaling $700 profit. You miss out on any further downside below $45.

Benefits:

- **Generate income on short positions**: Earn premium income while betting against a stock you think will decline or stay flat.
- **Lower short position risk**: The premium collected provides a small buffer and reduces your effective short price.
- **Accept capped downside profit**: You're willing to buy back shares at the strike price, forgoing unlimited profit if the stock crashes, in exchange for immediate premium income.

This is much riskier than a covered call because shorting stock carries unlimited loss potential if the stock rises sharply.

## Spread Trading

Strategies are categorised as debit or credit, which means they either cost you money upfront to enter (i.e. you pay a net debit), or you collect money upfront (receive a net credit).

### Bull Call (debit)

A bull call spread costs money but you control when you profit.

You want to bet the stock goes up, but buying a call is expensive. So you sell a higher call to someone else to help pay for it. It's like getting a discount coupon; you save money upfront, but you agree to share some of your winnings if the stock really takes off.

You **buy a call** at a lower strike price and **sell a call** at a higher strike price (same expiration). You profit if the stock goes up, but your gains are capped at the higher strike.

You pay a net debit (costs money upfront) because you're buying the more expensive lower-strike call.

### Bull Put (credit)

A bull put spread pays you money upfront but you're taking on an obligation.

Someone pays you money to promise you'll buy their stock at a certain price if it drops. You're nervous about that promise, so you buy insurance (a lower put) in case the stock really crashes. You keep the difference between what they paid you and what your insurance cost. You win as long as the stock doesn't fall too much.

You sell a put at a higher strike price and buy a put at a lower strike price (same expiration). You profit if the stock stays flat or goes up, keeping the premium difference.

You receive a net credit (collect money upfront) because you're selling the more expensive higher-strike put.

### Bear Put (debit)

A bear put spread costs money but lets you profit from declines.

You think the stock will fall, so you buy the right to sell it at a high price. But puts are expensive, so you sell someone else the right to sell at an even lower price to help pay for yours. It's like betting on a team to lose, but agreeing to share some winnings if they lose really badly; you get a discount on your bet upfront.

You buy a put at a higher strike price and sell a put at a lower strike price (same expiration). You profit if the stock goes down, but your gains are capped at the lower strike.

You pay a net debit (costs money upfront) because you're buying the more expensive higher-strike put.

### Bear Call (credit)

A bear call spread pays you money upfront but you're betting the stock won't rise.

Someone pays you money to let them buy stock from you at a certain price if it goes up. You're worried the stock might really shoot up, so you buy insurance (a higher call) to protect yourself. You keep the difference between what they paid you and what your insurance cost. You win as long as the stock doesn't rise too much.

You sell a call at a lower strike price and buy a call at a higher strike price (same expiration). You profit if the stock stays flat or goes down, keeping the premium difference.

You receive a net credit (collect money upfront) because you're selling the more expensive lower-strike call.

### Condor (debit)

You're betting the stock will stay calm and not move too much in either direction. You set up four price levels like fence posts. If the stock stays between the two middle posts, you win. If it runs wild past the outer posts, you lose (but only what you paid). It's like betting a dog will stay in the yard; not too far left, not too far right.

You combine a bull spread and a bear spread using all calls OR all puts. You buy options at the outer strikes and sell options at the inner strikes. You profit if the stock stays within a range between the two middle strikes.

You pay a net debit (costs money upfront).

### Iron Condor (credit)

Two people pay you money; one bets the stock goes way up, another bets it goes way down. You take their money and buy cheap insurance on both sides in case they're right. As long as the stock stays boring and doesn't move much, you keep all the money. It's like being paid to bet that nothing exciting happens; you win if things stay calm.

You combine a **Bull Put** spread (lower strikes) and a **Bear Call** spread (higher strikes). You sell options at the inner strikes and buy options at the outer strikes for protection. You profit if the stock stays within the range between the two short strikes.

You receive a net credit (collect money upfront).

## Indicators

### Stochastics

TODO

### Bollinger Bands

TODO

### 50-Day Moving Average (50-DMA)

The average closing price of a stock over the past 50 trading days. It's recalculated daily, creating a smoothed line on a chart that filters out short-term price noise.

- Trend identification: Shows the intermediate-term direction of a stock. If price is above the 50-DMA, it suggests an uptrend; below suggests a downtrend.
- Support and resistance: The 50-DMA often acts as a support level in uptrends (stock bounces off it) or resistance in downtrends (stock struggles to break above it).

Trading signals:

- Stock crossing above the 50-DMA can signal bullish momentum
- Stock crossing below can signal bearish momentum

Traders often watch when the 50-DMA crosses the 200-DMA (called a "Golden Cross" when 50 crosses above, or "Death Cross" when it crosses below).
In the context of options:
Traders use the 50-DMA to time entries and exits. For example:

Buying calls when a stock bounces off its 50-DMA in an uptrend
Selling calls or buying puts when a stock fails to break above its 50-DMA
Setting strike prices relative to where the 50-DMA sits

It's a popular technical indicator because 50 days represents roughly 2-3 months of trading, capturing medium-term momentum without being too reactive to daily swings.

### Volume

TODO


## Options Trading Cheat Sheet

1. Start looking for trades 1430-1500.
1. Options are bought in contracts; contract size is usually 100 shares per contract.
1. Only place 20% of capital at risk on any one trade (e.g. $2,000 per trade for a $10,000 trading bank).
1. Do not do more than 60 contracts per trade.
1. Only have 3 trades open at any one time.
1. To maximise profit always look at selling at market open (1000-1030), as market tends to open high and stoops over the day.
1. To minimise loss, wait to sell until afternoon.
1. Limit losses at 20% on any one trade.
1. Calculate **break even** by adding (call) or subtracting (put), the **option value** from the **strike price**.
1. When buying a **Call** always pick the first strike price below the current share price.
1. ASX traded ETO's expire on a Thursday, as per their [expiry date calendar](https://www.asx.com.au/markets/trade-our-derivatives-market/overview/equity-derivatives/single-stock-derivatives/expiry-calendar.html).
1. Due to time decay, pick an expiry 6-8 weeks out, minimum of 4 weeks, and never hold with less than 3 weeks to expiry.
1. Spreads don't suffer from time decay.
1. Set technical stops at ~20% support (for a call) or resistance (for a put).
1. Monitor daily.
1. Exit signals: for directional stay in the trade no longer than seven trading days, bollinger band breakout, no more than 3 weeks out from expiry, when 20-30% profit is reached

## FAQ

- Why is having real-time market data important when trading options
- What are common repair strategies
- When should I close a trade
- To what unit does an option premium apply
- What differentiates European and American options
- What are the basic entry signals for a bullish day
- What are the basic entry signals for a bearish day
- When is the maximum risk realised for a call option, for a share that falls below its strike price
- How many options are usually bundled into a contract?
- When is a mini warrant a preferrable instrument to an option? When the exit thresholds on an option sit above the support. In this case you want to take advantage of a support bounce (trampoline).
- How much is brokerage? AUD$75 per strike or 0.55% (whichever is higher)

## Glossary

| Term                   | Definition                                                                                               |
| ---------------------- | -------------------------------------------------------------------------------------------------------- |
| **Ask**                | The lowest price a seller is willing to accept for a security                                            |
| **ASX**                | Australian Securities Exchange - Australia's primary stock exchange                                      |
| **ATR**                | Average True Range - measures volatility over a specified period                                         |
| **Bear market**        | Prices of securities are falling, or are expected to fall                                                |
| **Bid**                | The highest price a buyer is willing to pay for a security                                               |
| **Bollinger Bands**    | Momentum indicator of moving averages and standard deviations to identify overbought/oversold conditions |
| **Breakout**           | When price moves beyond a defined support or resistance level                                            |
| **Bull market**        | Market characterised by rising prices and investor optimism                                              |
| **CFD**                | Contract for Difference - derivative for speculating on price movements                                  |
| **Derivative**         | Financial contract whose value is anchored to price of an underlying asset                               |
| **DMA**                | Direct Market Access - electronic trading without broker intermediation                                  |
| **ECN**                | Electronic Communication Network - automated system matching buy/sell orders                             |
| **EMA**                | Exponential Moving Average - gives more weight to recent prices                                          |
| **Exercise Price**     | See _Strike Price_                                                                                       |
| **Forex/FX**           | Foreign Exchange - trading currency pairs                                                                |
| **Futures**            | Contracts to buy/sell an asset at a predetermined price on a future date                                 |
| **Gap**                | Price difference between consecutive trading periods                                                     |
| **Going Long**         | Buying a security expecting price to rise                                                                |
| **Going Short**        | Selling a security expecting price to fall (often borrowed shares)                                       |
| **Iron Condor**        | See _Strangle_                                                                                           |
| **ITM**                | In The Money - options that have intrinsic value                                                         |
| **LEPO**               | Low Exercise Price Option (LEPO) is an ASX traded option designed to be traded on margin                 |
| **Leverage**           | Using borrowed capital to increase potential returns (and risks)                                         |
| **Liquidity**          | How easily an asset can be bought or sold without affecting its price                                    |
| **MACD**               | Moving Average Convergence Divergence                                                                    |
| **Margin Call**        | Demand for additional funds when losses exceed available margin                                          |
| **Margin**             | Money required to open a leveraged position                                                              |
| **Market Maker**       | Entity providing liquidity by continuously buying and selling                                            |
| **Market Order**       | Order to buy/sell immediately at current market price                                                    |
| **Moving Average**     | Average price over a specific number of periods                                                          |
| **Options**            | Contracts giving the right (not obligation) to buy/sell at a specific price                              |
| **OTM**                | Out of The Money - options without intrinsic value                                                       |
| **P&L**                | Profit and Loss statement                                                                                |
| **Pullback**           | Temporary reversal in the direction of a trend                                                           |
| **Resistance**         | Price level where selling pressure historically emerges                                                  |
| **Retracement**        | Temporary reversal in the direction of a price trend, followed by a return to the original trend         |
| **RSI**                | Relative Strength Index - momentum oscillator measuring speed and change of price movements              |
| **Scalping**           | Very short-term trading strategy holding positions for seconds to minutes                                |
| **SMA**                | Simple Moving Average - arithmetic mean of prices over specified periods                                 |
| **SPC**                | Shares Per Contract - the number of shares of the underlying asset that one option contract represents   |
| **SPI**                | Share Price Index Futures - derivative contracts based on ASX 200 index                                  |
| **Spread**             | Difference between bid and ask prices                                                                    |
| **Stochastic**         | Momentum indicator comparing a security's closing price to its price range over a set period             |
| **Stop Loss**          | Order to sell when price falls to a predetermined level to limit losses                                  |
| **Straddle**           | Buy both a call and put at the same strike price                                                         |
| **Strangle**           | Sell options to collect premiums when you expect the stock to stay flat                                  |
| **Strike Price**       | TODO                                                                                                     |
| **Support**            | Price level where buying interest historically emerges                                                   |
| **Swing Trading**      | Holding positions for days to weeks to capture price swings                                              |
| **Take Profit**        | Order to sell when price reaches a predetermined profit level                                            |
| **Technical Analysis** | Analyzing price charts and patterns to predict future movements                                          |
| **Tick**               | Minimum price movement of a trading instrument                                                           |
| **Timeframe**          | Period used for chart analysis (1min, 5min, 1hr, daily, etc.)                                            |
| **Trading Range**      | Price band between support and resistance levels where a security trades                                 |
| **Uptrend Line**       | Technical analysis line connecting successive higher troughs in an upward price trend                    |
| **Volatility**         | Degree of price variation over time                                                                      |
| **Volume**             | Number of shares or contracts traded in a given period                                                   |
| **Whipsaw**            | Rapid price movements in opposite directions causing losses                                              |
| **XJO**                | S&P/ASX 200 Index - benchmark Australian stock market index of top 200 companies                         |
