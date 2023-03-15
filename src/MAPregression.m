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
    X = tuningCurves;
elseif type == "both"
    % y = a(RT + B) + c(RT + D)*meanFR + noise
    Y = firingRates - tuningCurves;
    X = cat(2, reactionTimes.*tuningCurves, tuningCurves, reactionTimes, ones(ntrials, 1));
end

% split data into training and test sets 
% k-fold cross validation
k = 10;
n = size(X, 1);
indices = crossvalind('Kfold', n, k);
for i = 1:k
    test = (indices == i); train = ~test;
    Xtrain = X(train, :);
    Ytrain = Y(train);
    Xtest = X(test, :);
    Ytest = Y(test);
    % get model parameters
    if type ~= "normal"
        if regression == "ML"
            % ML estimate
            w = inv(Xtrain' * Xtrain) * Xtrain' * Ytrain;
        elseif regression == "MAP"
            % MAP estimate (ridge regression)
            lambda = 0.1;
            w = inv(Xtrain' * Xtrain + lambda * eye(size(Xtrain, 2))) * Xtrain' * Ytrain;
        end
    else
        w = nan;
    end
    % get root mean squared error and r2 value
    if type == "normal"
        SEs = (Ytest-tuningCurves(test)).^2;
        RMSE(i) = sqrt(mean(SEs));
        r2(i) = 1 - (sum((Ytest - tuningCurves(test)).^2) / sum((Ytest - mean(Ytest)).^2));
        AIC(i) = nan;
    else
        SEs = (Ytest - Xtest * w).^2;
        RMSE(i) = sqrt(mean(SEs));
        r2(i) = 1 - (sum((Ytest - Xtest * w).^2) / sum((Ytest - mean(Ytest)).^2));
        % get AIC
        AIC(i) = ntrials * log(RMSE(i)) + 2 * length(w);
    end
end


% if type ~= "normal"
%     if regression == "ML"
%         % ML estimate
%         w = inv(X' * X) * X' * Y;
%     elseif regression == "MAP"
%         % MAP estimate (ridge regression)
%         lambda = 0.1;
%         w = inv(X' * X + lambda * eye(size(X, 2))) * X' * Y;
%     end
% else
%     w = nan;
% end

% % get root mean squared error and r2 value
% if type == "normal"
%     SEs = (Y-tuningCurves).^2;
%     RMSE = sqrt(mean(SEs));
%     r2 = 1 - (sum((Y - tuningCurves).^2) / sum((Y - mean(Y)).^2));
%     AIC = nan;
% else
%     SEs = (Y - X * w).^2;
%     RMSE = sqrt(mean(SEs));
%     r2 = 1 - (sum((Y - X * w).^2) / sum((Y - mean(Y)).^2));
%     % get AIC
%     AIC = ntrials * log(RMSE) + 2 * length(w);
% end


end