## DEVELOPING A PREDICTIVE STOCK MARKET MODEL AND OPTIMIZED PORTFOLIO STRATEGY ##

## STEP 1: DATA COLLECTION AND REPROCESSING ##

#install.packages(c("quantmod", "dplyr", "ggplot2"))
library(quantmod)
library(dplyr)
library(ggplot2)

# Data Collection: Fetch historical data for multiple stocks
tickers <- c("AAPL", "GOOGL", "AMZN", "MSFT", "TSLA")
getSymbols(tickers, src = "yahoo", from = "2010-01-01", to = Sys.Date())

# Combine stock data into one data frame
stocks <- list(AAPL = AAPL, 
               GOOGL = GOOGL,
               AMZN = AMZN,
               MSFT = MSFT,
               TSLA = TSLA)

# Preprocessing: Clean data, remove missing values
cleaned_data <- lapply(stocks, function(x) na.omit(x))

## STEP 2: FEATURE ENGINEERING

# Create technical indicators: Moving Averages, RSI, Bollinger Bands
add_features <- function(stock_data) {
  stock_data$SMA_20 <- SMA(Cl(stock_data), n = 20) #Simple Moving Average
  stock_data$RSI_14 <- RSI(Cl(stock_data), n = 14) #Relative Strength Index
  stock_data$BBands <- BBands(Cl(stock_data)) #Bolinger Bands
  return(stock_data)
}

# Apply feature engineering to all stocks
stocks_with_features <- lapply(cleaned_data, add_features)

## STEP 3: MACHINE LEARNING FOR STOCK PRICE PREDICTION

# Split data into training and testing sets (80/20 split)
set.seed(123)  # For reproducibility

train_test_split <- function(stock_data) {
  n <- nrow(stock_data)
  train_data <- stock_data[1:floor(0.8 * n), ]
  test_data <- stock_data[(floor(0.8 * n) + 1):n, ]
  return(list(train = train_data, test = test_data))
}

# Split each stock's data
train_test_data <- lapply(stocks_with_features, train_test_split)

# Linear Regression Model to predict closing prices
predict_stock_price <- function(train_data, test_data) {
  model <- lm(Cl(train_data) ~ SMA_20 + RSI_14, data = train_data)
  predictions <- predict(model, newdata = test_data)
  return(predictions)
}

# Apply the model for each stock
predictions <- lapply(train_test_data,
                      function(x) predict_stock_price(x$train, x$test))

# Calculate Mean Squared Error (MSE)
calculate_mse <- function(pred, actual) {
  mse <- mean((pred - actual)^2)
  return(mse)
}

# MSE for each stock
mse_values <- mapply(calculate_mse, predictions, 
                     lapply(train_test_data, 
                            function(x) Cl(x$test)))
print(mse_values)


## STEP 4: PORTFOLIO CONSTRUCTION AND OPTIMIZATION

#install.packages("quadprog")
#install.packages("PortfolioAnalytics")
#install.packages("ROI")
#install.packages("ROI.plugin.quadprog")
#install.packages("DEoptim")
library(PortfolioAnalytics)
library(ROI)
library(ROI.plugin.quadprog)
library(quadprog)
library(DEoptim)
library(PerformanceAnalytics)

# Calculate daily returns for each stock
stock_returns <- lapply(stocks_with_features, function(x) dailyReturn(Cl(x)))
names(stock_returns) <- names(stocks_with_features) # Rename columns by ticker for clarity

# Combine returns into one data frame
returns_data <- do.call(merge, stock_returns)
returns_data <- na.omit(returns_data) # Remove rows with NA values
colnames(returns_data) <- names(stocks_with_features) # Confirm Column names match Tickers

# Calculate correlation matrix
correlation_matrix <- cor(returns_data)
print(correlation_matrix)

# Calculate expected returns (mean of daily returns)
expected_returns <- colMeans(returns_data)
print(expected_returns)

# Create a portfolio object
portfolio <- portfolio.spec(assets = colnames(returns_data))
portfolio <- add.constraint(portfolio, type = "full_investment")
portfolio <- add.constraint(portfolio, type = "long_only")
portfolio <- add.objective(portfolio, type = "risk", name = "var")  # minimize risk

# Optimize portfolio weights
optimized_portfolio <- optimize.portfolio(returns_data, portfolio, 
                                          optimize_method = "DEoptim", 
                                          trace = TRUE)

# Display optimized weights
weights <- optimized_portfolio$weights
print(weights, 4)



## STEP 5: BACKTESTING THE STRATEGY

# Calculate the portfolio returns based on optimized weights
portfolio_returns <- rowSums(returns_data * weights)
portfolio_returns <- Return.portfolio(returns_data, weights = weights)


head(portfolio_returns, 3)

# Compare portfolio returns with benchmark (S&P 500)
getSymbols("^GSPC", src = "yahoo", from = "2010-01-01", to = Sys.Date())
head(GSPC)
benchmark_returns <- dailyReturn(Ad(GSPC))
head(benchmark_returns)

# Combine portfolio returns with benchmark returns
comparison_data <- merge(portfolio_returns, benchmark_returns)
comparison_data <- na.omit(comparison_data)
colnames(comparison_data) <- c("Portfolio", "S&P 500")


# Plot performance comparison
plot.zoo(comparison_data, main = "Portfolio vs S&P 500", col = c("blue", "red"))

### PERFORMANCE METRICS ###

# Sharpe Ratio (assuming risk-free rate = 0)
sharpe_ratio <- SharpeRatio.annualized(portfolio_returns, Rf = 0, scale = 252)
print(paste("Sharpe Ratio:", round(sharpe_ratio, 3)))

# Sortino Ratio (more penalizing for downside risk)
sortino_ratio <- SortinoRatio(portfolio_returns, MAR = 0)
print(paste("Sortino Ratio:", round(sortino_ratio, 3)))

# Maximum Drawdown
max_drawdown <- maxDrawdown(portfolio_returns)
print(paste("Max Drawdown:", round(max_drawdown, 3)))

# Annualized Return
annual_return <- Return.annualized(portfolio_returns, scale = 252)
print(paste("Annualized Return:", round(annual_return, 3)))

# Annualized Standard Deviation (Risk)
annual_risk <- StdDev.annualized(portfolio_returns, scale = 252)
print(paste("Annualized Volatility (Risk):", round(annual_risk, 3)))

# Summary Table
table.AnnualizedReturns(portfolio_returns)

## STEP 6: DATA VISUALIZATION

# Plot Efficient Frontier
# For simplicity, we'll use a Monte Carlo simulation for this
set.seed(123)

num_portfolios <- 1000
portfolio_results <- matrix(NA, num_portfolios, 3)
colnames(portfolio_results) <- c("Return", "Risk", "Sharpe")

for (i in 1:num_portfolios) {
  weights <- runif(length(tickers))
  weights <- weights / sum(weights)
  portfolio_results[i, 1] <- sum(weights * expected_returns)  # Expected return
  portfolio_results[i, 2] <- sqrt(t(weights) %*% cov(returns_data) %*% weights)  # Portfolio risk
  portfolio_results[i, 3] <- portfolio_results[i, 1] / portfolio_results[i, 2]  # Sharpe ratio
}

# Efficient frontier plot
ef_plot <- data.frame(portfolio_results)
ggplot(ef_plot, aes(x = Risk, y = Return)) +
  geom_point(color = "blue", alpha = 0.3) +
  geom_point(aes(x = sqrt(var(portfolio_returns)), y = mean(portfolio_returns)), color = "red") +
  theme_minimal() +
  labs(title = "Efficient Frontier", x = "Risk (Std. Dev.)", y = "Return")



