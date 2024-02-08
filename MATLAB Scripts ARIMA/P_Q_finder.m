% Load data from Shel.csv
data = readtable('Shel.csv', 'VariableNamingRule', 'preserve');
% Extract the  Close column

close_values = data.Close;

nobs = length(close_values);


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