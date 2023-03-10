function [parameters, MRSE, AIC] = MAPregression(firingRates, reactionTimes, rewardLabels, directionLabels)

% define the model
ntrials = size(firingRates, 1)
reactionTime = reshape(reactionTime, ntrials, 1);
tuningCurves = reshape(tuningCurves, ntrials, 1);

Y = firingRates
X0 = [1 0];

model = @(X) sum((firingRates - (x(1) * ReactionTime + x(2)) * tuningCurves).^2 + sum(X.^2))
parameters = fminsearch(model, X0);

% get mean square root error
MRSE = mrse(firingRates - (x(1) * ReactionTime + x(2)) * tuningCurves)

% get AIC/BIC



end