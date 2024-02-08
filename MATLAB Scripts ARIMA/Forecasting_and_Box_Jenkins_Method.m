clear 


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

% Create training and test datasets
train_data = log_close_values(:);
test_data = log_close_values(2001:end);


% P and Q detection

%graphicly 


figure
autocorr(log_close_values, 'NumLags', 1000);
figure
parcorr(log_close_values, 'NumLags', 1000);

% using AIC and BIC


%{
% Define range of possible values for p and q
p = 0:20;
q = 0:20;

% Initialize AIC and BIC matrices
AIC = zeros(length(p), length(q))+inf;
BIC = zeros(length(p), length(q))+inf;

% Estimate ARMA models and compute AIC and BIC values
for i = 1:length(p)
    for j = 1:length(q)
        try
            model = arima(p(i), 1, q(j));
            fit = estimate(model, close_values);

            % Compute log-likelihood
            resid = infer(fit, close_values);
            sigma2 = fit.Variance;
            loglik = -0.5 * (nobs * log(2*pi) + nobs * log(sigma2) + sum(resid.^2) / sigma2);
            % Compute the number of parametres
            numparams = size(fit.AR, 2) + size(fit.MA, 2) + 1;

            [AIC(i,j), BIC(i,j)] = aicbic(loglik, numparams, nobs);
        catch ME
            disp(['Error for p = ', num2str(p(i)), ', q = ', num2str(q(j)), ': ', ME.message]);
            AIC(i,j) = NaN;
            BIC(i,j) = NaN;
        end
    end
end

% Find p and q values with lowest AIC and BIC values
[minAIC, idxAIC] = min(AIC(:));
[minBIC, idxBIC] = min(BIC(:));
[bestpAIC, bestqAIC] = ind2sub(size(AIC), idxAIC);
[bestpBIC, bestqBIC] = ind2sub(size(BIC), idxBIC);

% Display results
disp(['Best p and q values based on AIC: ', num2str(bestpAIC-1), ', ', num2str(bestqAIC-1)]);
disp(['Best p and q values based on BIC: ', num2str(bestpBIC-1), ', ', num2str(bestqBIC-1)]);
%}



% Define the ARIMA model parameters
p =17;      % AR order

d = 1;     % differencing order

q = 116;    % MA orderV

% Fit the ARIMA model to the training data
model = arima(p, d, q);
fit = estimate(model, train_data);

% Generate forecasts for the next 500 time units
[forecast_data, YMSE] = forecast(fit, 500, 'Y0', train_data);

% Convert the forecasted values back to the original scale
forecast_values = exp(forecast_data);
YMSE=exp(YMSE);

% Compute lower and upper 95% forecast intervals
lower = forecast_values - 1.96*sqrt(YMSE);
upper = forecast_values + 1.96*sqrt(YMSE);

% Plot the original data and the initial forecasted values
figure;
plot(dates, close_values);
hold on;
forecast_line = plot(dates(end)+1:dates(end)+500, forecast_values);
lower_line = plot(dates(end)+1:dates(end)+500, lower, 'g--');
upper_line = plot(dates(end)+1:dates(end)+500, upper, 'g--');
legend('Original data', 'Forecasted values', 'Lower 95% interval', 'Upper 95% interval');
title('ARIMA Model with 95% Forecast Intervals for Log-Transformed Close Data');
xlabel('Date');
ylabel('Close values');
% Loop over time steps and update the forecast and bounds lines
for t = 1:500
    % Update the forecast line and bounds lines
    forecast_line.XData = dates(end)+1:dates(end)+t;
    forecast_line.YData = forecast_values(1:t);
    lower_line.XData = dates(end)+1:dates(end)+t;
    lower_line.YData = lower(1:t);
    upper_line.XData = dates(end)+1:dates(end)+t;
    upper_line.YData = upper(1:t);
    
    % Set the axis limits to show the current data
    xlim([dates(end-100) dates(end)+t]);
    ylim([min([close_values; lower(1:t)]) max([close_values; upper(1:t)])]);
    
    % Pause for a short time to allow the plot to update
    pause(0.2);
end






% Diagnostic checking
residuals = infer(fit, train_data);
figure;
subplot(2,1,1);
plot(residuals);
title('Residuals of ARIMA Model');
xlabel('Time');
ylabel('Residuals');

subplot(2,1,2);
autocorr(residuals);
title('Autocorrelation Function of Residuals');
xlabel('Lag');
ylabel('Autocorrelation');

% Ljung-Box test for residual autocorrelation
[h, pValue, stat, criticalValues] = lbqtest(residuals, 'Lags', [10, 15, 20]);
disp(['Ljung-Box test statistic: ',num2str(stat)])
disp(['p-value: ',num2str(pValue)])
disp(['Critical values: ',num2str(criticalValues)])

if h==1
    disp("The residuals exhibit significant autocorrelation.");

else
    disp("The residuals do not exhibit significant autocorrelation.");
end