% This code reads in a time series of daily closing stock prices and applies 
% three different transformations to test for stationarity. The first plot 
% shows the original time series, the second plot shows the logarithmically 
% transformed time series, and the third plot shows the differenced time series.

% Load data from Shel.csv
data = readtable('Shel.csv', 'VariableNamingRule', 'preserve');

% Extract the dates and Close column
dates = data.Date;
close_values = data.Close;

% Create a figure with three subplots
figure
subplot(3,1,1)
plot(dates, close_values)
title('Close values before applying logarithm')
xlabel('Date')
ylabel('Close values')

% Perform augmented Dickey-Fuller (ADF) test on original time series
[h, pValue, stat, criticalValues] = adftest(close_values);
disp(['ADF test statistic: ',num2str(stat)])
disp(['p-value: ',num2str(pValue)])
disp(['Critical values: ',num2str(criticalValues')])

if h==0
    disp("The time series is non-stationary.");
else
    disp("The time series is stationary.");
end

% Apply natural logarithm to Close values
log_close_values = log(close_values);

% Create second subplot with log-transformed Close values
subplot(3,1,2)
plot(dates, log_close_values)
title('Close values after applying logarithm')
xlabel('Date')
ylabel('Log-transformed close values')

% Perform augmented Dickey-Fuller (ADF) test on log-transformed time series
[h, pValue, stat, criticalValues] = adftest(log_close_values);
disp(['ADF test statistic: ',num2str(stat)])
disp(['p-value: ',num2str(pValue)])
disp(['Critical values: ',num2str(criticalValues')])

if h==0
    disp("The log-transformed time series is non-stationary.");
else
    disp("The log-transformed time series is stationary.");
end

% Create third subplot with differenced Close values
Diff_close_values=[close_values(1);diff(close_values)];
subplot(3,1,3)
plot(dates, Diff_close_values)
title('Close values after applying differencing')
xlabel('Date')
ylabel('Diff-transformed close values')

% Perform augmented Dickey-Fuller (ADF) test on differenced time series
[h, pValue, stat, criticalValues] = adftest(Diff_close_values);
disp(['ADF test statistic: ',num2str(stat)])
disp(['p-value: ',num2str(pValue)])
disp(['Critical values: ',num2str(criticalValues')])

if h==0
    disp("The differenced time series is non-stationary.");
else
    disp("The differenced time series is stationary.");
end