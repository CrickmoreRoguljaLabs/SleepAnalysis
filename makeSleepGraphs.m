% If a dataset from sleep analysis is in the workspace, will generate
% graphs of commonly used sleep data: average sleep bout length (day and night), total
% sleep, day sleep, and night sleep.

%% Extract general info

genotypes = {master_data_struct.genotype};

num_genos = length(genotypes);
max_num_flies = length(master_data_struct(1).sleep);

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
    day_sleep(1:length(master_data_struct(i).sleep(:,2)),i) = master_data_struct(i).sleep(:,2);
    night_sleep(1:length(master_data_struct(i).sleep(:,3)),i) = master_data_struct(i).sleep(:,3);
    total_sleep(1:length(master_data_struct(i).sleep(:,1)),i) = master_data_struct(i).sleep(:,1);
end

day_avg = mean(nanmean(day_sleep));
night_avg = mean(nanmean(night_sleep));
total_avg = mean(nanmean(total_sleep));

% Make graphs
figure('Color', [1 1 1]); notBoxPlot(day_sleep); title('Day Sleep', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [day_avg day_avg]);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;

figure('Color', [1 1 1]); notBoxPlot(night_sleep); title('Night Sleep', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [night_avg night_avg]);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;

figure('Color', [1 1 1]); notBoxPlot(total_sleep); title('Total Sleep', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [total_avg total_avg]);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;


%% Make bout graphs

% Extract data
day_bouts = zeros(max_num_flies,num_genos);
night_bouts = zeros(max_num_flies,num_genos);

for i = 1:num_genos
    day_bouts(1:length(master_data_struct(i).sleep_bout_lengths(:,1)),i)...
        = master_data_struct(i).sleep_bout_lengths(:,1);
    night_bouts(1:length(master_data_struct(i).sleep_bout_lengths(:,2)),i)...
        = master_data_struct(i).sleep_bout_lengths(:,2);
end

day_bout_avg = mean(nanmean(day_bouts));
night_bout_avg = mean(nanmean(night_bouts));

% Make graphs
figure('Color', [1 1 1]); notBoxPlot(day_bouts); title('Sleep Bout Length - Day', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [day_bout_avg day_bout_avg]);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;

figure('Color', [1 1 1]); notBoxPlot(night_bouts); title('Sleep Bout Length - Night', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [night_bout_avg night_bout_avg]);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;

%% Make activity graph

% Extract data
day_activity = zeros(max_num_flies,num_genos);
night_activity = zeros(max_num_flies,num_genos);

for i = 1:num_genos
    day_activity(1:length(master_data_struct(i).activities(:,1)),i)...
        = master_data_struct(i).activities(:,1);
    night_activity(1:length(master_data_struct(i).activities(:,2)),i)...
        = master_data_struct(i).activities(:,2);
end

day_act_avg = mean(nanmean(day_activity));
night_act_avg = mean(nanmean(night_activity));

% Make graphs
figure('Color', [1 1 1]); notBoxPlot(day_activity); title('Day Activity', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [day_act_avg day_act_avg]);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/waking minute');
tightfig;

figure('Color', [1 1 1]); notBoxPlot(night_activity); title('Night Activity', 'FontWeight', 'bold');
hold on; line([0 num_genos+5], [night_act_avg night_act_avg]);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/waking minute');
tightfig;