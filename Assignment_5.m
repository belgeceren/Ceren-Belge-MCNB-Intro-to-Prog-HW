%% ASSIGNMENT 5 
%% CEREN BELGE

%% 1)
load('data_assignment_5.mat');

% Rename for convenience
train_eeg      = eeg_train;    % [Ntrain x Nchannels x Ntime]
test_eeg       = eeg_test;     % [Ntest  x Nchannels x Ntime]
train_features = dnn_train;    % [Ntrain x Nfeatures]
test_features  = dnn_test;     % [Ntest  x Nfeatures]
time           = times;        % [1 x Ntime]

[Ntrain, Nfeat]   = size(train_features);
[~, Nchan, Ntime] = size(train_eeg);

% Ridge regression parameter
lambda = 10;

%% 2)
train_sizes = [250, 1000, 10000, 16540];
nSizes      = numel(train_sizes);

% Store accuracy time courses
acc_trainSize = nan(nSizes, Ntime);

%% 3)
for i = 1:nSizes
    
    nTrainCurr = min(train_sizes(i), Ntrain);    % safety
    idx = randperm(Ntrain, nTrainCurr);          % random subset
    
    Xtr = train_features(idx, :);
    Ytr = train_eeg(idx, :, :);
    
    fprintf("Training size = %d samples\n", nTrainCurr);

    acc_trainSize(i, :) = compute_timecourse_acc( ...
        Xtr, Ytr, test_features, test_eeg, lambda);
end

%% 4)
figure; hold on;
colors = lines(nSizes);

for i = 1:nSizes
    plot(time, acc_trainSize(i,:), 'LineWidth', 1.7, ...
        'DisplayName', sprintf('%d images', train_sizes(i)), ...
        'Color', colors(i,:));
end

xlabel('Time (ms)');
ylabel('Prediction accuracy (mean correlation)');
title('Effect of training data amount on EEG encoding accuracy');
legend('show', 'Location', 'best');
grid on;

function acc_time = compute_timecourse_acc(Xtr, Ytr, Xt, Yt, lambda)

    [~, Nfeat]        = size(Xtr);
    [~, Nchan, Ntime] = size(Ytr);

    acc_time = nan(1, Ntime);

    % Ridge prefix
    XtX     = Xtr' * Xtr;
    Wprefix = (XtX + lambda * eye(Nfeat)) \ Xtr';

    for t = 1:Ntime
        % Training EEG at this time point
        Ytr_t = squeeze(Ytr(:, :, t));      % [Ntrain x Nchan]
        W     = Wprefix * Ytr_t;           % [Nfeat x Nchan]

        % Test EEG: true vs predicted
        Ytrue = squeeze(Yt(:, :, t));      % [Ntest x Nchan]
        Ypred = Xt * W;                    % [Ntest x Nchan]

        % Mean correlation across channels (manual Pearson r)
        r = nan(Nchan,1);
        for ch = 1:Nchan
            r(ch) = mycorr(Ytrue(:,ch), Ypred(:,ch));
        end
        
        acc_time(t) = mean(r, 'omitnan');
    end
end

%% Manual correlation
function r = mycorr(x, y)
    % Remove NaNs
    mask = isfinite(x) & isfinite(y);
    x = x(mask);
    y = y(mask);

    if numel(x) < 2
        r = NaN;
        return;
    end

    % Subtract means
    x = x - mean(x);
    y = y - mean(y);

    % Compute Pearson correlation
    denom = sqrt(sum(x.^2) * sum(y.^2));
    if denom == 0
        r = NaN;
    else
        r = sum(x .* y) / denom;
    end
end
%I observe that prediction accuracy becomes higher and more stable as the amount of training data increases.
%Models trained with 250 or 1000 images show lower and noisier accuracy, while 10,000 and 16,540 images lead to much stronger and smoother time-courses.
%This pattern likely occurs because larger training sets help the model generalize better, reduce overfitting, and provide a clearer mapping between the DNN features and the EEG responses.

%% 5) Effect of DNN feature amount on encoding accuracy

feature_counts = [25, 50, 75, 100];
nFeatConds     = numel(feature_counts);

% Store accuracy time courses for feature conditions
acc_featCount = nan(nFeatConds, Ntime);

for i = 1:nFeatConds
    
    nFeatCurr = min(feature_counts(i), Nfeat);   % safety
    feat_idx  = 1:nFeatCurr;                     % here: first N features
    
    % Select subsets of DNN features
    Xtr_feat = train_features(:, feat_idx);      % [Ntrain x nFeatCurr]
    Xt_feat  = test_features(:,  feat_idx);      % [Ntest  x nFeatCurr]
    
    fprintf("Number of DNN features = %d\n", nFeatCurr);

    % Use the same helper function as before
    acc_featCount(i, :) = compute_timecourse_acc( ...
        Xtr_feat, train_eeg, Xt_feat, test_eeg, lambda);
end

% Plot: Effect of DNN feature amount
figure; hold on;
colors2 = lines(nFeatConds);

for i = 1:nFeatConds
    plot(time, acc_featCount(i,:), 'LineWidth', 1.7, ...
        'DisplayName', sprintf('%d features', feature_counts(i)), ...
        'Color', colors2(i,:));
end

xlabel('Time (ms)');
ylabel('Prediction accuracy (mean correlation)');
title('Effect of DNN feature amount on EEG encoding accuracy');
legend('show', 'Location', 'best');
grid on;
%I observe that using more DNN features leads to higher and more stable prediction accuracy over time.
%The model with 25 features performs the worst, while 100 features gives the highest peak and the smoothest curve.
%This pattern likely happens because having more features provides richer and more detailed visual representations, which helps the model explain more variance in the EEG data and reduces noise in the predictions.