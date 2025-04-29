# 📈 Predictive Stock Market Model & Portfolio Optimization
This project builds a predictive model for stock price forecasting using technical indicators (like SMA, RSI, and Bollinger Bands) and applies portfolio optimization techniques to maximize returns while minimizing risk. It includes machine learning for price prediction, constructs an optimized portfolio using historical data, and evaluates performance against the S&P 500 through backtesting and key financial metrics (Sharpe Ratio, Sortino Ratio, etc.).

## Key Features
- Historical stock data collection (AAPL, GOOGL, AMZN, MSFT, TSLA)
- Technical indicator engineering (SMA, RSI, Bollinger Bands)
- Linear regression-based stock price prediction
- Portfolio optimization with constraints (long-only, full investment)
- Performance metrics: Sharpe Ratio, Sortino Ratio, Max Drawdown
- Efficient Frontier visualization using Monte Carlo simulation

## Files
```predictive portfolio.R``` : Main R script for data collection, modeling, optimization, and visualization

```comparison plot.png``` : Portfolio vs. S&P 500 performance plot

```efficient frontier.png``` : Efficient frontier showing return vs. risk

```LICENSE``` : MIT License for open use

## Methodology
- Linear regression models use SMA and RSI to predict closing prices
- Portfolio optimization is performed using the PortfolioAnalytics and DEoptim packages in R
- Backtesting compares the model portfolio with the S&P 500
- Risk metrics and return metrics are computed for evaluation

## How to Run
1. Clone the repo:
   ```bash
   git clone https://github.com/shresthahub/predictive_portfolio.git
   cd predictive_portfolio
   ```

2. Open predictive portfolio.R in RStudio.
3. Install the required R packages and run the code step by step.

## Dependencies
Install the following R packages before running the script: 

```
install.packages(c("quantmod", "PerformanceAnalytics", "PortfolioAnalytics",
                   "ROI", "ROI.plugin.quadprog", "DEoptim", "ggplot2", "dplyr"))
```


## 📌 Future Work
- Use non linear models like Random Forest or XGBoost in R to capture more complex relationships in stock price prediction.
- Automate data refresh using CRON jobs or taskscheduleR so the portfolio stays current.
- Introduce Value at Risk (VaR) or Conditional VaR for more rigorous risk control
- Add periodic rebalancing like monthly or quarterly to maintain optimal weights based on updated data.
- Build an interactive R Shiny app to visualize live predictions and performance

## License
This project is licensed under the MIT License.
