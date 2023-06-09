clear all; close all;
r_0 = 5;
r_max = 20;
s_max = pi / 2;
tc = @(rew, s) rew * 5 + r_0 + (r_max - r_0) * cos(s - s_max);
fr = @(rew, s, rt) max(tc(rew, s) * 0.005 * (rt - 100), 0);

rewColors = [1 0 0; 1 0.6470 0; 0 0 1];

s = [0, 1, 2, 3, 4, 5, 6, 7] * pi / 4;
ntrials = 500;
directionLabels = ones(ntrials, 1);
rewardLabels = ones(ntrials, 1);
reactionTimes = zeros(ntrials, 1);
nneurons = 150;

firingRates = zeros(ntrials, nneurons);
for i=1:ntrials
    directionLabels(i) = randi(8);
    rewardLabels(i) = randi(3);
    reactionTimes(i) = 350 + (randn * 50);
    for j=1:nneurons
        spikes = zeros(1, 1000);
        spikeN = poissrnd(fr(rewardLabels(i), (directionLabels(i) - 1) * pi / 4, reactionTimes(i)));
        spikeTimes = rand(1, spikeN);
        % convert to spike indices
        spikeIndices = ceil(spikeTimes * 1000);
        spikes(spikeIndices) = 1;
        firingRates(i, j) = mean(spikes)*1000;
    end
end

%% plot tuning curve 

figure;
for i = 1:3
    Y = zeros(8,1);
    for j = 1:8
        curInds = directionLabels == j & rewardLabels == i;
        fr = squeeze(firingRates(curInds, 1));
        Y(j) = mean(fr);
    end
    plot(1:8, Y, Color=rewColors(i, :), LineWidth=2); hold on;
end
hold off;
xlim([0.7 8.3]);
xticks(1:8);
xticklabels({'0', '45', '90', '135', '180', '225', '270', '315'});
xlabel('Direction (degrees)');
ylabel('Firing rate (Hz)');
saveas(gcf, "../results/fake/tuning_curve.png"); close all;


%% fit the data structure to simons one
save("../data/fake/data.mat", "firingRates", "reactionTimes", "directionLabels", "rewardLabels");
