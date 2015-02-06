% If a dataset from sleep analysis is in the workspace, will generate
% graphs of commonly used sleep data: average sleep bout length (day and night), total
% sleep, day sleep, and night sleep.

%% Extract general info

% Select sleep file to analyze
[meta_file, sleep_path] = uigetfile('D:\Projects\Gal4-Screen\*.mat');
sleepData = importdata(fullfile(sleep_path, meta_file));

% Creat tag for saving figures
tag = regexp(meta_file,'_','split');
tag = [tag{1}, '_'];

genotypes = {sleepData.master_data_struct.genotype};

num_genos = length(genotypes);
max_num_flies = max([sleepData.master_data_struct.num_alive_flies]);

%% Make sleep graphs

% Extract sleep info

% Initialize sleep matrices
day_sleep = zeros(max_num_flies,num_genos);
day_sleep(:,:) = NaN;
night_sleep = zeros(max_num_flies,num_genos);
night_sleep(:,:) = NaN;
total_sleep = zeros(max_num_flies,num_genos);
total_sleep(:,:) = NaN;

for i = 1:num_genos
    day_sleep(1:length(sleepData.master_data_struct(i).sleep(:,2)),i) = sleepData.master_data_struct(i).sleep(:,2);
    night_sleep(1:length(sleepData.master_data_struct(i).sleep(:,3)),i) = sleepData.master_data_struct(i).sleep(:,3);
    total_sleep(1:length(sleepData.master_data_struct(i).sleep(:,1)),i) = sleepData.master_data_struct(i).sleep(:,1);
end

day_avg = nanmean(nanmean(day_sleep));
day_std = nanstd(nanmean(day_sleep));
night_avg = nanmean(nanmean(night_sleep));
night_std = nanstd(nanmean(night_sleep));
total_avg = nanmean(nanmean(total_sleep));
total_std = nanstd(nanmean(total_sleep));

% Make graphs
figure('Color', [1 1 1]); notBoxPlot(day_sleep); title('Day Sleep', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [day_avg day_avg]);
line([0 num_genos+5], [day_avg+day_std day_avg+day_std], 'Color', [0.5 0.5 0.5]);
line([0 num_genos+5], [day_avg-day_std day_avg-day_std], 'Color', [0.5 0.5 0.5]); 
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;
savefig(gcf, fullfile(sleep_path, [tag,'Day-Sleep.fig']));

figure('Color', [1 1 1]); notBoxPlot(night_sleep); title('Night Sleep', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [night_avg night_avg]);
line([0 num_genos+5], [night_avg+night_std night_avg+night_std], 'Color', [0.5 0.5 0.5]);
line([0 num_genos+5], [night_avg-night_std night_avg-night_std], 'Color', [0.5 0.5 0.5]); 
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;
savefig(gcf, fullfile(sleep_path, [tag,'Night-Sleep.fig']));

figure('Color', [1 1 1]); notBoxPlot(total_sleep); title('Total Sleep', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [total_avg total_avg]);
line([0 num_genos+5], [total_avg-total_std total_avg-total_std], 'Color', [0.5 0.5 0.5]); 
line([0 num_genos+5], [total_avg+total_std total_avg+total_std], 'Color', [0.5 0.5 0.5]); 
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;
savefig(gcf, fullfile(sleep_path, [tag,'Total-Sleep.fig']));


%% Make bout graphs

% Extract data
day_bouts = zeros(max_num_flies,num_genos);
day_bouts(:,:) = NaN;
night_bouts = zeros(max_num_flies,num_genos);
night_bouts = NaN;

for i = 1:num_genos
    day_bouts(1:length(sleepData.master_data_struct(i).sleep_bout_lengths(:,1)),i)...
        = sleepData.master_data_struct(i).sleep_bout_lengths(:,1);
    night_bouts(1:length(sleepData.master_data_struct(i).sleep_bout_lengths(:,2)),i)...
        = sleepData.master_data_struct(i).sleep_bout_lengths(:,2);
end

day_bout_avg = nanmean(nanmean(day_bouts));
day_bout_std = nanstd(nanmean(day_bouts));
night_bout_avg = nanmean(nanmean(night_bouts));
night_bout_std = nanstd(nanmean(night_bouts));

% Make graphs
figure('Color', [1 1 1]); notBoxPlot(day_bouts); title('Sleep Bout Length - Day', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [day_bout_avg day_bout_avg]);
line([0 num_genos+5], [day_bout_avg+day_bout_std day_bout_avg+day_bout_std], 'Color', [0.5 0.5 0.5]); 
line([0 num_genos+5], [day_bout_avg-day_bout_std day_bout_avg-day_bout_std], 'Color', [0.5 0.5 0.5]); 
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;
savefig(gcf, fullfile(sleep_path, [tag,'Day-Bout-Length.fig']));

figure('Color', [1 1 1]); notBoxPlot(night_bouts); title('Sleep Bout Length - Night', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [night_bout_avg night_bout_avg]);
line([0 num_genos+5], [night_bout_avg+night_bout_std night_bout_avg+night_bout_std], 'Color', [0.5 0.5 0.5]); 
line([0 num_genos+5], [night_bout_avg-night_bout_std night_bout_avg-night_bout_std], 'Color', [0.5 0.5 0.5]);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;
savefig(gcf, fullfile(sleep_path, [tag,'Night-Bout-Length.fig']));

%% Make activity graph

% Extract data
day_activity = zeros(max_num_flies,num_genos);
day_activity(:,:) = NaN;
night_activity = zeros(max_num_flies,num_genos);
night_activity(:,:) = NaN;

for i = 1:num_genos
    day_activity(1:length(sleepData.master_data_struct(i).activities(:,1)),i)...
        = sleepData.master_data_struct(i).activities(:,1);
    night_activity(1:length(sleepData.master_data_struct(i).activities(:,2)),i)...
        = sleepData.master_data_struct(i).activities(:,2);
end

day_act_avg = nanmean(nanmean(day_activity));
day_act_std = nanstd(nanmean(day_activity));
night_act_avg = nanmean(nanmean(night_activity));
night_act_std = nanstd(nanmean(night_activity));

% Make graphs
figure('Color', [1 1 1]); notBoxPlot(day_activity); title('Day Activity', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [day_act_avg day_act_avg]);
line([0 num_genos+5], [day_act_avg+day_act_std day_act_avg+day_act_std], 'Color', [0.5 0.5 0.5]); 
line([0 num_genos+5], [day_act_avg-day_act_std day_act_avg-day_act_std], 'Color', [0.5 0.5 0.5]);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/waking minute');
tightfig;
savefig(gcf, fullfile(sleep_path, [tag,'Day-Activity.fig']));

figure('Color', [1 1 1]); notBoxPlot(night_activity); title('Night Activity', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [night_act_avg night_act_avg]);
line([0 num_genos+5], [night_act_avg+night_act_std night_act_avg+night_act_std], 'Color', [0.5 0.5 0.5]); 
line([0 num_genos+5], [night_act_avg-night_act_std night_act_avg-night_act_std], 'Color', [0.5 0.5 0.5]); 
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/waking minute');
savefig(gcf, fullfile(sleep_path, [tag,'Night-Activity.fig']));
tightfig;