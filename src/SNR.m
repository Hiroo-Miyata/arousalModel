function [meanFR, SNRs] = SNR(firingRates, rewardLabels, directionLabels)


% this function calculate the tuning curve of each neurons and calculate SNR of each neuron

% calculate the tuning curve of each neurons
nneurons = size(firingRates, 2);
nrewards = length(unique(rewardLabels));
ndirections = length(unique(directionLabels));

meanFR = zeros(nneurons, nrewards, ndirections);
varFR = zeros(nneurons, nrewards, ndirections);
for i = 1:nneurons
    for j = 1:nrewards
        for k = 1:ndirections
            curInds = rewardLabels == j & directionLabels == k;
            meanFR(i, j, k) = mean(firingRates(curInds, i));
            varFR(i, j, k) = var(firingRates(curInds, i));
        end
    end
end

% calculate the signal variance and noise variance of each neuron

% signal variance
signalVar = zeros(nneurons, nrewards);
for i = 1:nneurons
    for j = 1:nrewards
        signalVar(i, j) = var(meanFR(i, j, :));
    end
end

% noise variance
noiseVar = zeros(nneurons, nrewards);
for i = 1:nneurons
    for j = 1:nrewards
        noiseVar(i, j) = mean(varFR(i, j, :));
    end
end

% calculate the SNR of each neuron
signalVar = mean(signalVar, 2);
noiseVar = mean(noiseVar, 2);
SNRs = signalVar ./ noiseVar;

isPlot = 1;

if isPlot
    figure;
    hist(SNRs, 100);
    xlabel('SNR');
    ylabel('Number of neurons');
    title('SNR distribution');
    saveas(gcf, 'SNR distribution', 'jpg');
    close gcf;
end

end
