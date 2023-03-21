 clear all; close all;
% This is the main file
% Fit the spike trains into 4 different model
% 1. gain model
% 2. shift model
% 3. tuning curve model
% then, check the MRSE in each dataset and check the result

% Question 1 what previous paper did? to prove the model is appropriate.
% AIC / BIC is useful for evaluating? check byron's paper.

status = 1;
outputFolder = "../results/20230320/";

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
%% get the mean firing rate from before 150 ms to after 50 ms GC.
% output: 
% firingRates: (ntrial, nneurons)


if status == 0
    load("../data/fake/data.mat");
elseif status == 1
    load("../data/processed/data.mat");
    firingRates = firingRates';
elseif status == 2
    load("../data/processed/suFR.mat");
    % suFR = cell(6,4); 6 days, 4 variables
    % cell(:, 1): firing rates (ntrials, nneurons)
    % cell(:, 2): direction labels (ntrials, 1)
    % cell(:, 3): reward labels (ntrials, 1)
    % cell(:, 4): reaction times (ntrials, 1)

    % combine the variables across days
    firingRates = [];
    directionLabels = [];
    rewardLabels = [];
    reactionTimes = [];

    for i = 1:6
        firingRates = cat(1, firingRates, suFR{i, 1});
        directionLabels = cat(1, directionLabels, suFR{i, 2});
        rewardLabels = cat(1, rewardLabels, suFR{i, 3});
        reactionTimes = cat(1, reactionTimes, suFR{i, 4});
    end
end

[ntrials, nneurons] = size(firingRates);
directions = unique(directionLabels); ndirections = length(directions);
rewards = unique(rewardLabels); nrewards = length(rewards);


%% get the tuning curve in each reward condition
% output: 
% meanFR: nrewards * ndirections * nneurons(double)
% tuningCurves: ntrials * 1
[meanFR, SNRs] = SNR(firingRates, rewardLabels, directionLabels);

tuningCurves = zeros(ntrials, nneurons);
for i = 1:nneurons
    for j = 1:ntrials
        tuningCurves(j, i) = meanFR(i, rewardLabels(j), directionLabels(j));
    end
end

%% in each neurons, firing rates is fitted to 3 different models
% input:
% firingRates
% reactionTimes
% tuningCurves
% output:
% parameters: nparameters * 1
% MSRE: double
% r2: double
% AIC/BIC: double

%% plot 3 * 2 different model and regression
types = ["both", "gain", "offset", "normal"];
regressions = ["ML", "MAP"];
ntypes = length(types);
nregressions = length(regressions);

Yall = zeros(nneurons, ntypes, nregressions);
R2all = zeros(nneurons, ntypes, nregressions);
Pall = zeros(nneurons, 1);
Pall2 = zeros(nneurons, 1);
for n=1:nneurons
    Y = cell(1, ntypes);
    for i = 1:1
        regression = regressions(i);
        for j = 1:ntypes
            type = types(j);
            [w, RMSE, r2, AIC] = MAPregression(firingRates(:, n), tuningCurves(:, n), reactionTimes, rewardLabels, directionLabels, type, regression);
            Y{i, j} = RMSE;
            Yall(n, j, i) = mean(RMSE);
            R2all(n, j, i) = mean(r2);
        end
    end

    % get p-value between 2 and 3 type
    [~, p] = ttest2(Y{i, 2}, Y{i, 3});
    Pall(n) = p;
    [~, p2] = ttest2(Y{i, 2}, Y{i, 1});
    Pall2(n) = p2;
    % figure;
    % for i = 1:1
    %     % subplot(1,2,i);
    %     % plot bar and error bar
    %     y = zeros(1, ntypes);
    %     yerr = zeros(1, ntypes);
    %     for j = 1:ntypes
    %         y(j) = mean(Y{i, j});
    %         yerr(j) = std(Y{i, j}) / sqrt(10); % k=10
    %     end
    %     bar(1:ntypes, y(i, :));
    %     hold on;
    %     errorbar(1:ntypes, y(i, :), yerr(i, :), 'LineStyle', 'none');
    %     xticks(1:ntypes)
    %     xticklabels(types);
    %     ylabel("root mean square error (Hz)")
    %     title(regression + " p-value: " + p);
    %     % title(regression);
    % end
    % if status == 0
    %     n = "fake";
    % end
    % set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
    % set(gcf,'position',[100,100,300,650]);
    % saveas(gcf, outputFolder+"neuron-"+n+".jpg");
    % close all;
    
end

% plot the relationship between SNR and R2 of gain model
% figure;
% scatter(SNRs, squeeze(R2all(:, 2, 1)));
% xlabel("SNR");
% ylabel("R2");
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% saveas(gcf, outputFolder+"SNR-R2.jpg");
% close all;

% plot the relationship between SNR and the difference of MRSE between gain and offset model
figure;
scatter(SNRs, squeeze(Yall(:, 2, 1) - Yall(:, 3, 1)));
xlabel("SNR");
ylabel("MRSE of gain - MRSE of offset");
set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
saveas(gcf, outputFolder+"SNR-MRSE-go.jpg");
close all;

% plot the relationship between SNR and the difference of R2 between gain and offset model
figure;
scatter(SNRs, squeeze(R2all(:, 2, 1) - R2all(:, 3, 1)));
xlabel("SNR");
ylabel("R2 of gain - R2 of offset");
set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
saveas(gcf, outputFolder+"SNR-R2-go.jpg");
close all;

% plot the relationship between SNR and the difference of MRSE between gain and normal model
figure;
scatter(SNRs, squeeze(Yall(:, 2, 1) - Yall(:, 4, 1)));
xlabel("SNR");
ylabel("MRSE of gain - MRSE of normal");
set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
saveas(gcf, outputFolder+"SNR-MRSE-gn.jpg");
close all;

% plot the relationship between SNR and the difference of R2 between gain and normal model
figure;
scatter(SNRs, squeeze(R2all(:, 2, 1) - R2all(:, 4, 1)));
xlabel("SNR");
ylabel("R2 of gain - R2 of normal");
set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
saveas(gcf, outputFolder+"SNR-R2-gn.jpg");
close all;

% %% plot the mean of all neurons
% Y = zeros(1, ntypes);
% Yerr = zeros(1, ntypes);
% for i = 1:1
%     regression = regressions(i);
%     for j = 1:ntypes
%         type = types(j);
%         Y(i, j) = mean(Yall(:, j, i));
%         Yerr(i, j) = std(Yall(:, j, i)) / sqrt(nneurons);
%     end
% end
% figure;
% for i = 1:1
%     % subplot(1,2,i);
%     % plot bar and error bar
%     bar(1:ntypes, Y(i, :));
%     hold on;
%     errorbar(1:ntypes, Y(i, :), Yerr(i, :), 'LineStyle', 'none');
%     xticks(1:ntypes)
%     xticklabels(types);
%     ylabel("root mean square error (Hz)")
%     % get p-value between 2 and 3 type
%     [~, p] = ttest2(squeeze(Yall(:, 2, i)), squeeze(Yall(:, 3, i)));
%     title(regression + " p-value: " + p);
%     % title(regression);
% end
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% set(gcf,'position',[100,100,300,650]);
% saveas(gcf, outputFolder+"neuron-all.jpg");
% close all;

% % count the number of neurons that 
% % class 1: p < 0.05 and the Yall(:, 2, 1) < Yall(:, 3, 1)
% % class 2: p < 0.05 and the Yall(:, 2, 1) > Yall(:, 3, 1)
% % class 3: p > 0.05 and the Yall(:, 2, 1) < Yall(:, 3, 1)
% % class 4: p > 0.05 and the Yall(:, 2, 1) > Yall(:, 3, 1)
% class1 = sum(Pall < 0.05 & Yall(:, 2, 1) < Yall(:, 3, 1));
% class2 = sum(Pall < 0.05 & Yall(:, 2, 1) > Yall(:, 3, 1));
% class3 = sum(Pall > 0.05 & Yall(:, 2, 1) < Yall(:, 3, 1));
% class4 = sum(Pall > 0.05 & Yall(:, 2, 1) > Yall(:, 3, 1));

% % plot the counts in each class in a bar plot
% figure;
% bar([class1, class2, class3, class4]);
% xticks(1:4)
% xticklabels(["Gain", "Offset", "Nosig G", "Nosig O"]);
% ylabel("Number of neurons")
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% set(gcf,'position',[100,100,300,650]);
% saveas(gcf, outputFolder+"neuron-class.jpg");
% close all;


% % count the number of neurons that
% % class 1 Pall2 < 0.05
% % class 2 Pall2 > 0.05

% class1 = sum(Pall2 < 0.05);
% class2 = sum(Pall2 > 0.05);
% figure;
% bar([class1, class2]);
% xticks(1:2)
% xticklabels(["Sig", "Nosig"]);
% ylabel("Number of neurons")
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% set(gcf,'position',[100,100,300,650]);
% saveas(gcf, outputFolder+"neuron-class2.jpg");
% close all;

