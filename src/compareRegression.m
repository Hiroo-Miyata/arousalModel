% This is the main file
% Fit the spike trains into 4 different model
% 1. gain model
% 2. shift model
% 3. tuning curve model
% then, check the MRSE in each dataset and check the result

% Question what previous paper did? to prove the model is appropriate.
% AIC / BIC is useful for evaluating? check byron's paper.


%% prepare the dataset
% input: filename string
% output:
% directionLabels: ntrials * 1 (int)
% rewardLabels: ntrials * 1 (int)
% ndirections: int
% nrewards: int
% directions: 8 * 1 (int)
% rewards: 3 * 1 (int)
% reactionTimes: ntrials * 1 (double)
inputFile = XXX;
load(inputFile);

%% get the mean firing rate from before 150 ms to after 50 ms GC.
% output: 
% firingRates: (ntrial, nneurons)


%% get the tuning curve in each reward condition
% output: 
% meanFR: nrewards * ndirections (double)
% tuningCurves: ntrials * 1


%% in each neurons, firing rates is fitted to 4 different models
% input:
% firingRates
% reactionTimes
% tuningCurves

% output:
% parameters: nparameters * 1
% MSRE: double
% AIC/BIC: double
