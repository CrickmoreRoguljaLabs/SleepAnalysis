% If a dataset from sleep analysis is in the workspace, will generate
% graphs of commonly used sleep data: average sleep bout length (day and night), total
% sleep, day sleep, and night sleep.

%% Extract general info

% Determine whether to open a file from memory or use data in the workspace
if exist('master_data_struct','var')
    
    % Create tag for saving figures
    tag = [filename_master(1:end-5),'_'];
    
    % Reformat the relevant data
    sleepData.master_data_struct = master_data_struct;
    genotypes = {master_data_struct.genotype}; 
    num_genos = length(genotypes);
    max_num_flies = max([master_data_struct.num_alive_flies]);
    
    % Determine the output location
    sleep_path = export_path;
    
else
    % Select sleep file to analyze
    [meta_file, sleep_path] = uigetfile('D:\Projects\Gal4-Screen\*.mat');
    sleepData = importdata(fullfile(sleep_path, meta_file));

    % Create tag for saving figures
    tag = [sleepData.filename_master(1:end-5),'_'];

    % Extract relevant parameters
    genotypes = {sleepData.master_data_struct.genotype};

    num_genos = length(genotypes);
    max_num_flies = max([sleepData.master_data_struct.num_alive_flies]);
end
    
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
notBoxPlot2(day_sleep); title('Day Sleep', 'FontWeight', 'bold');
hold on; er1 = line([0 num_genos+5], [day_avg day_avg], 'Color', 'k', 'linewidth', 1);
er2 = line([0 num_genos+5], [day_avg+day_std day_avg+day_std], 'Color', [0.8 0.8 0.8]);
er3 = line([0 num_genos+5], [day_avg-day_std day_avg-day_std], 'Color', [0.8 0.8 0.8]); 
er4 = line([0 num_genos+5], [day_avg+2*day_std day_avg+2*day_std], 'Color', [0.6 0.6 0.6]);
er5 = line([0 num_genos+5], [day_avg-2*day_std day_avg-2*day_std], 'Color', [0.6 0.6 0.6]); 
uistack([er1, er2, er3, er4, er5], 'bottom');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(sleep_path, [tag,'Day-Sleep.fig']));
saveas(gcf, fullfile(sleep_path, [tag,'Day-Sleep.pdf']));

notBoxPlot2(night_sleep); title('Night Sleep', 'FontWeight', 'bold');
hold on; er1 = line([0 num_genos+5], [night_avg night_avg], 'Color', 'k');
er2 = line([0 num_genos+5], [night_avg+night_std night_avg+night_std], 'Color', [0.8 0.8 0.8]);
er3 = line([0 num_genos+5], [night_avg-night_std night_avg-night_std], 'Color', [0.8 0.8 0.8]); 
er4 = line([0 num_genos+5], [night_avg+2*night_std night_avg+2*night_std], 'Color', [0.6 0.6 0.6]);
er5 = line([0 num_genos+5], [night_avg-2*night_std night_avg-2*night_std], 'Color', [0.6 0.6 0.6]); 
uistack([er1, er2, er3, er4, er5], 'bottom');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(sleep_path, [tag,'Night-Sleep.fig']));
saveas(gcf, fullfile(sleep_path, [tag,'Night-Sleep.pdf']));

notBoxPlot2(total_sleep); title('Total Sleep', 'FontWeight', 'bold');
hold on; 
er1 = line([0 num_genos+5], [total_avg total_avg], 'Color', 'k');
er2 = line([0 num_genos+5], [total_avg-total_std total_avg-total_std], 'Color', [0.8 0.8 0.8]); 
er3 = line([0 num_genos+5], [total_avg+total_std total_avg+total_std], 'Color', [0.8 0.8 0.8]); 
er4 = line([0 num_genos+5], [total_avg-2*total_std total_avg-2*total_std], 'Color', [0.6 0.6 0.6]); 
er5 = line([0 num_genos+5], [total_avg+2*total_std total_avg+2*total_std], 'Color', [0.6 0.6 0.6]); 
uistack([er1, er2, er3, er4, er5], 'bottom');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(sleep_path, [tag,'Total-Sleep.fig']));
saveas(gcf, fullfile(sleep_path, [tag,'Total-Sleep.pdf']));


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
notBoxPlot2(day_bouts); title('Sleep Bout Length - Day', 'FontWeight', 'bold');
hold on; 
er1 = line([0 num_genos+5], [day_bout_avg day_bout_avg], 'Color', 'k');
er2 = line([0 num_genos+5], [day_bout_avg+day_bout_std day_bout_avg+day_bout_std], 'Color', [0.8 0.8 0.8]); 
er3 = line([0 num_genos+5], [day_bout_avg-day_bout_std day_bout_avg-day_bout_std], 'Color', [0.8 0.8 0.8]); 
er4 = line([0 num_genos+5], [day_bout_avg+2*day_bout_std day_bout_avg+2*day_bout_std], 'Color', [0.6 0.6 0.6]); 
er5 = line([0 num_genos+5], [day_bout_avg-2*day_bout_std day_bout_avg-2*day_bout_std], 'Color', [0.6 0.6 0.6]); 
uistack([er1, er2, er3, er4, er5], 'bottom');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(sleep_path, [tag,'Day-Bout-Length.fig']));
saveas(gcf, fullfile(sleep_path, [tag,'Day-Bout-Length.pdf']));

notBoxPlot2(night_bouts); title('Sleep Bout Length - Night', 'FontWeight', 'bold');
hold on; 
er1 = line([0 num_genos+5], [night_bout_avg night_bout_avg], 'Color', 'k');
er2 = line([0 num_genos+5], [night_bout_avg+night_bout_std night_bout_avg+night_bout_std], 'Color', [0.8 0.8 0.8]); 
er3 = line([0 num_genos+5], [night_bout_avg-night_bout_std night_bout_avg-night_bout_std], 'Color', [0.8 0.8 0.8]);
er4 = line([0 num_genos+5], [night_bout_avg+2*night_bout_std night_bout_avg+2*night_bout_std], 'Color', [0.6 0.6 0.6]); 
er5 = line([0 num_genos+5], [night_bout_avg-2*night_bout_std night_bout_avg-2*night_bout_std], 'Color', [0.6 0.6 0.6]);
uistack([er1, er2, er3, er4, er5], 'bottom');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(sleep_path, [tag,'Night-Bout-Length.fig']));
saveas(gcf, fullfile(sleep_path, [tag,'Night-Bout-Length.pdf']));

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
notBoxPlot2(day_activity); title('Day Activity', 'FontWeight', 'bold');
hold on; 
er1 = line([0 num_genos+5], [day_act_avg day_act_avg], 'Color', 'k');
er2 = line([0 num_genos+5], [day_act_avg+day_act_std day_act_avg+day_act_std], 'Color', [0.8 0.8 0.8]); 
er3 = line([0 num_genos+5], [day_act_avg-day_act_std day_act_avg-day_act_std], 'Color', [0.8 0.8 0.8]);
er4 = line([0 num_genos+5], [day_act_avg+2*day_act_std day_act_avg+2*day_act_std], 'Color', [0.6 0.6 0.6]); 
er5 = line([0 num_genos+5], [day_act_avg-2*day_act_std day_act_avg-2*day_act_std], 'Color', [0.6 0.6 0.6]);
uistack([er1, er2, er3, er4, er5], 'bottom');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/waking minute');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(sleep_path, [tag,'Day-Activity.fig']));
saveas(gcf, fullfile(sleep_path, [tag,'Day-Activity.pdf']));

notBoxPlot2(night_activity); title('Night Activity', 'FontWeight', 'bold');
hold on; 
er1 = line([0 num_genos+5], [night_act_avg night_act_avg], 'Color', 'k');
er2 = line([0 num_genos+5], [night_act_avg+night_act_std night_act_avg+night_act_std], 'Color', [0.8 0.8 0.8]); 
er3 = line([0 num_genos+5], [night_act_avg-night_act_std night_act_avg-night_act_std], 'Color', [0.8 0.8 0.8]);
er4 = line([0 num_genos+5], [night_act_avg+2*night_act_std night_act_avg+2*night_act_std], 'Color', [0.6 0.6 0.6]); 
er5 = line([0 num_genos+5], [night_act_avg-2*night_act_std night_act_avg-2*night_act_std], 'Color', [0.6 0.6 0.6]);
uistack([er1, er2, er3, er4, er5], 'bottom');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/waking minute');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
print(gcf, '-dpdf', fullfile(sleep_path, [tag,'Night-Activity.pdf']));


hold off