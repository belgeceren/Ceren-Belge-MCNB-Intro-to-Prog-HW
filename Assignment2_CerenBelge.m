%CEREN BELGE
%INTRODUCTION TO PROGRAMMING COURSE
%ASSIGNMENT2

%QUESTION 1
EEGData = load("eeg_data_assignment_2 (1).mat")
%QUESTION 2
%time section at 0.1
RoundedTimes = round(EEGData.times, 3) % Round time points to 3 decimals for precision
Atonepointzeroseconds = find(RoundedTimes == 0.1) % % Find indices corresponding to 0.1 seconds
%channels
OccipitalCh = []
FrontalCh = []
for i = 1:length(EEGData.ch_names);  % Loop through all channel names
    channels = EEGData.ch_names(i);  % Extract current channel name
if contains(channels,"O","IgnoreCase",true) % If channel name contains 'O' (occipital)
   OccipitalCh(end+1) = i; % Add its index to OccipitalCh
end
if contains(channels, "F","IgnoreCase",true) % If channel name contains 'F' (frontal)
    FrontalCh(end+1) = i;   % Add its index to FrontalCh
end
end
disp(FrontalCh)
disp(OccipitalCh)
%EEGDATA.eeg
EEG = EEGData.eeg %% Store EEG 3D matrix (200x63x140) in variable EEG
OcData = EEG(:,OccipitalCh,Atonepointzeroseconds); %Extract EEG values for all conditions, occipital channels, at 0.1s
FrData = EEG(:,FrontalCh,Atonepointzeroseconds); %% Extract EEG values for all conditions, frontal channels, at 0.1s

%mean
Occipitalvoltagemean = mean(OcData, "all");  % Mean voltage over all occipital channels and conditions
Frontalvoltagemean = mean(FrData, "all"); % Mean voltage over all frontal channels and conditions

%QUESTION 3
x = EEGData.times; %Time vector for x-axis
y = mean(EEGData.eeg,[1 2]);  %Mean over all conditions (dim=1) and channels (dim=2)
y = y(:)' %% Flatten result to 1x140 vector
disp(size(x));
disp(size(y));
figure(1) 
figure(1); 
clf;
plot(x, y, 'LineWidth', 1.5); %Plot mean EEG voltage over time
xlabel('Time (s)');
ylabel('Mean EEG Voltage (\muV)');
title('Mean EEG Voltage Over Time');
saveas(figure(1), 'meanEEG_time.fig')
%INTERPRETATION
% In the graph, I can see repetitive fluctuations at equal time intervals, 
% and their amplitude decreases over time. 
%This graph shows the mean EEG voltage averaged across all channels and conditions, 
%so individual channels cannot be seen separately.
%It reflects a short oscillatory response after the stimulus that gradually fades over time.
%All channels would have a similar general pattern because they record the same brain response, 
% but their amplitudes could differ depending on electrode location.

%QUESTION 4

x2 = EEGData.times(:)';
y1 = mean(mean(EEG(:, OccipitalCh, :), 1), 2); % Mean over conditions & channels for occipital group
y2 = mean(mean(EEG(:,FrontalCh,:),1),2); % Mean over conditions & channels for frontal group
y1 = y1(:)';
y2 = y2(:)';
disp(y1);
disp(y2);

figure(2); 
clf; 
hold on;  % Keep both plots on same figure
plot(x2, y1, 'LineWidth', 1.5);
plot(x2, y2, 'LineWidth', 1.5);
yline(0,'--'); grid on;
xlabel('Time (s)');
ylabel('Mean EEG Voltage (\muV)');
title('Mean EEG Timecourses: Occipital vs Frontal (All Conditions)');
legend({'Occipital (O-containing)', 'Frontal (F-containing)'}, 'Location','best');
saveas(figure(2), 'O_vs_F_allconditions.fig');
figure(2)
%INTERPRETATION
%Both timecourses show similar timing of fluctuations
%because they reflect the same stimulus-locked EEG responses.
%However, the occipital signal has much larger amplitudes, 
% as it originates from visual areas that respond more strongly to visual stimuli,
% while the frontal channels show weaker activity 
% due to their distance from the visual sources and differences in cortical function.

%QUESTION 5
x3 = EEGData.times(:)';
y3 = mean(EEG(1, OccipitalCh, :), 2); % Mean across occipital channels for condition 1
y4 = mean(EEG(2, OccipitalCh, :), 2); % Mean across occipital channels for condition 2
y3 = y3(:)';
y4 = y4(:)';
disp(y3);
disp(y4);
figure(3);
clf;
hold on;
plot(x3, y3, 'r', 'LineWidth',1.5);
plot(x3, y4, 'g','LineWidth',1.5);
xlabel('Time (s)');
ylabel('Mean EEG Voltage (\muV)');
title('Occipital Mean Timecourse: Condition 1 (red) vs Condition 2 (green)');
legend({'Condition 1','Condition 2'}, 'Location','best');
saveas(figure(3), 'Occipital_cond1_vs_cond2.fig');
%INTERPRETATION
%Both timecourses show similar timing of peaks and troughs, 
% indicating that occipital channels respond similarly across the two image conditions.
%However, small differences in amplitude can be seen, 
% likely reflecting differences in visual stimulus properties or variability across conditions.