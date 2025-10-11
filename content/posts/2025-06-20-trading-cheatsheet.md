---
layout: post
draft: true
title: "Derivatives Trading"
slug: "trading"
date: "2025-06-20 20:10:00+1000"
lastmod: "2025-10-11 09:34:00+1000"
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
  - [Buyer vs Seller](#buyer-vs-seller)
  - [Options Bring Flexibility](#options-bring-flexibility)
  - [The Value of an Option](#the-value-of-an-option)
  - [Option Premiums](#option-premiums)
- [Spread Trading](#spread-trading)
- [Portfolio Strategies - Covered Calls](#portfolio-strategies---covered-calls)
- [Options Cheatsheet](#options-cheatsheet)
- [Glossary](#glossary)
- [Indicators](#indicators)

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

### Buyer vs Seller

You pay a premium upfront to purchase this right. The option's value fluctuates based on the underlying stock's price movements, time remaining until expiration, and other factors like volatility. If the option becomes profitable, you can either exercise it (buy/sell the stock) or sell the option itself for a profit. If it expires worthless, you only lose the premium you paid.

The traits of a Call or Put invert depending if you are the buyer or the seller (aka writer):

| Option Type | Buyer                                                     | Seller                                                           |
| ----------- | --------------------------------------------------------- | ---------------------------------------------------------------- |
| Call        | Pay premium, for a right to **BUY** stock at strike price | Receive the premium, obligated to **SELL** stock at strike price |
| Put         | Pay premium, for right to **SELL** stock at strike price  | Receive the premium, obligated to **BUY** stock at strike price  |

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

**Call Value Example**:

```
=== Call Option ===
Share price: $31.00
Strike price: $30.50
Expiry: 25 November
Option Value: $0.72
```

- Intinsic value = $0.50 ($31.00 - $30.50)
- Time value = $0.22 ($0.72 - $0.50)

**Scenario 1: One week later, share price increase**:

```
=== Call Option ===
Share price: $32.00
Strike price: $30.50
Option Value: $1.68
```

- Intinsic value = $1.50 ($32.00 - $30.50)
- Time value = $0.18 ($1.68 - $1.50)
- Profit = 233% = 2.3X = ($1.68 / $0.72 × 100)

A 233% profit off a ~3% increase in share price.

**Scenario 2: One week later, share price decrease**:

```
=== Call Option ===
Share price: $29.50
Strike price: $30.50
Option Value: $0.18
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

## Spread Trading

Iron Condor

## Portfolio Strategies - Covered Calls

## Options Cheatsheet

1. Options are bought in contracts; contract size is usually 100 shares per contract.
1. Calculate **break even** by adding (call) or subtracting (put), the **option value** from the **strike price**.

## Glossary

| Term                   | Definition                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------ |
| **Ask**                | The lowest price a seller is willing to accept for a security                                    |
| **ASX**                | Australian Securities Exchange - Australia's primary stock exchange                              |
| **ATR**                | Average True Range - measures volatility over a specified period                                 |
| **Bear market**        | Prices of securities are falling, or are expected to fall                                        |
| **Bid**                | The highest price a buyer is willing to pay for a security                                       |
| **Breakout**           | When price moves beyond a defined support or resistance level                                    |
| **Bull market**        | Market characterised by rising prices and investor optimism                                      |
| **CFD**                | Contract for Difference - derivative for speculating on price movements                          |
| **Derivative**         | Financial contract whose value is anchored to price of an underlying asset                       |
| **DMA**                | Direct Market Access - electronic trading without broker intermediation                          |
| **ECN**                | Electronic Communication Network - automated system matching buy/sell orders                     |
| **EMA**                | Exponential Moving Average - gives more weight to recent prices                                  |
| **Exercise Price**     | See _Strike Price_                                                                               |
| **Forex/FX**           | Foreign Exchange - trading currency pairs                                                        |
| **Futures**            | Contracts to buy/sell an asset at a predetermined price on a future date                         |
| **Gap**                | Price difference between consecutive trading periods                                             |
| **Going Long**         | Buying a security expecting price to rise                                                        |
| **Going Short**        | Selling a security expecting price to fall (often borrowed shares)                               |
| **Iron Condor**        | See _Strangle_                                                                                   |
| **ITM**                | In The Money - options that have intrinsic value                                                 |
| **Leverage**           | Using borrowed capital to increase potential returns (and risks)                                 |
| **Liquidity**          | How easily an asset can be bought or sold without affecting its price                            |
| **Margin Call**        | Demand for additional funds when losses exceed available margin                                  |
| **Margin**             | Money required to open a leveraged position                                                      |
| **Market Maker**       | Entity providing liquidity by continuously buying and selling                                    |
| **Market Order**       | Order to buy/sell immediately at current market price                                            |
| **Moving Average**     | Average price over a specific number of periods                                                  |
| **Options**            | Contracts giving the right (not obligation) to buy/sell at a specific price                      |
| **OTM**                | Out of The Money - options without intrinsic value                                               |
| **P&L**                | Profit and Loss statement                                                                        |
| **Pullback**           | Temporary reversal in the direction of a trend                                                   |
| **Resistance**         | Price level where selling pressure historically emerges                                          |
| **Retracement**        | Temporary reversal in the direction of a price trend, followed by a return to the original trend |
| **RSI**                | Relative Strength Index - momentum oscillator measuring speed and change of price movements      |
| **Scalping**           | Very short-term trading strategy holding positions for seconds to minutes                        |
| **SMA**                | Simple Moving Average - arithmetic mean of prices over specified periods                         |
| **SPI**                | Share Price Index Futures - derivative contracts based on ASX 200 index                          |
| **Spread**             | Difference between bid and ask prices                                                            |
| **Stop Loss**          | Order to sell when price falls to a predetermined level to limit losses                          |
| **Straddle**           | Buy both a call and put at the same strike price                                                 |
| **Strangle**           | Sell options to collect premiums when you expect the stock to stay flat                          |
| **Strike Price**       | TODO                                                                                             |
| **Support**            | Price level where buying interest historically emerges                                           |
| **Swing Trading**      | Holding positions for days to weeks to capture price swings                                      |
| **Take Profit**        | Order to sell when price reaches a predetermined profit level                                    |
| **Technical Analysis** | Analyzing price charts and patterns to predict future movements                                  |
| **Tick**               | Minimum price movement of a trading instrument                                                   |
| **Timeframe**          | Period used for chart analysis (1min, 5min, 1hr, daily, etc.)                                    |
| **Trading Range**      | Price band between support and resistance levels where a security trades                         |
| **Uptrend Line**       | Technical analysis line connecting successive higher troughs in an upward price trend            |
| **Volatility**         | Degree of price variation over time                                                              |
| **Whipsaw**            | Rapid price movements in opposite directions causing losses                                      |
| **XJO**                | S&P/ASX 200 Index - benchmark Australian stock market index of top 200 companies                 |

## Indicators

| Indicator           | Definition                                                                                               |
| ------------------- | -------------------------------------------------------------------------------------------------------- |
| **Bollinger Bands** | Momentum indicator of moving averages and standard deviations to identify overbought/oversold conditions |
| **MACD**            | Moving Average Convergence Divergence                                                                    |
| **Stochastic**      | Momentum indicator comparing a security's closing price to its price range over a set period             |
| **Volume**          | Number of shares or contracts traded in a given period                                                   |
