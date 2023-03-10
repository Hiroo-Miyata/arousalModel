function [w, RMSE, r2, AIC] = MAPregression(firingRates, tuningCurves, reactionTimes, rewardLabels, directionLabels, type, regression)

% define the model
ntrials = size(firingRates, 1);
reactionTimes = reshape(reactionTimes, ntrials, 1);
tuningCurves = reshape(tuningCurves, ntrials, 1);

%% model
if type == "gain" % 1. gain model
    % y = a(RT + B) * meanFR + noise
    Y = firingRates;
    X = cat(2, reactionTimes.*tuningCurves, tuningCurves);
elseif type == "offset"
    % y = a(RT + B) + meanFR + noise 
    Y = firingRates - tuningCurves;
    X = cat(2, reactionTimes, ones(ntrials, 1));
elseif type == "normal"
    % y = meanFR + noise
    Y = firingRates;
end


if type ~= "normal"
    if regression == "ML"
        % ML estimate
        w = inv(X' * X) * X' * Y;
    elseif regression == "MAP"
        % MAP estimate (ridge regression)
        lambda = 0.1;
        w = inv(X' * X + lambda * eye(size(X, 2))) * X' * Y;
    end
else
    w = nan;
end

% get root mean squared error and r2 value
if type == "normal"
    RMSE = sqrt(mean((Y - tuningCurves).^2));
    r2 = 1 - (sum((Y - tuningCurves).^2) / sum((Y - mean(Y)).^2));
    AIC = nan;
else
    RMSE = sqrt(mean((Y - X * w).^2));
    r2 = 1 - (sum((Y - X * w).^2) / sum((Y - mean(Y)).^2));
    % get AIC
    AIC = ntrials * log(RMSE) + 2 * length(w);
end


end