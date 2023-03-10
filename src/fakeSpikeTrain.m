clear all; close all;
r_0 = 30;
r_max = 50;
s_max = pi / 2;
tc = @(rew, s) rew * 10 + r_0 + (r_max - r_0) * cos(s - s_max);
fr = @(rew, s, rt) tc(rew, s) * 0.005 * (rt - 100);

rewColors = [1 0 0; 1 0.6470 0; 0 0 1];

s = [0, 1, 2, 3, 4, 5, 6, 7] * pi / 4;
ntrials = 1600;
spikes = zeros(ntrials, 1000);
directionLabels = ones(ntrials, 1);
rewardLabels = ones(ntrials, 1);
reactionTimes = zeros(ntrials, 1);

for i=1:ntrials
    directionLabels(i) = randi(8);
    rewardLabels(i) = randi(3);
    reactionTimes(i) = 350 + (randn * 50);
    spikeN = poissrnd(fr(rewardLabels(i), (directionLabels(i) - 1) * pi / 4, reactionTimes(i)));
    spikeTimes = rand(1, spikeN);
    % convert to spike indices
    spikeIndices = ceil(spikeTimes * 1000);
    spikes(i, spikeIndices) = 1;
end

firingRates = mean(spikes, 2)*1000;

%% plot tuning curve 

figure;
for i = 1:3
    Y = zeros(8,1);
    for j = 1:8
        curInds = directionLabels == j & rewardLabels == i;
        Y(j) = mean(firingRates(curInds));
    end
    plot(1:8, Y, Color=rewColors(i, :), LineWidth=2); hold on;
end
hold off;
xlim([0.7 8.3]);

%% fit the data structure to simons one
save("../data/fake/data.mat", "firingRates", "reactionTimes", "directionLabels", "rewardLabels");
