% If a dataset from sleep analysis is in the workspace, will generate
% graphs of commonly used sleep data: average sleep bout length (day and night), total
% sleep, day sleep, and night sleep.

%% Extract general info

genotypes = {master_data_struct.genotype};

num_genos = length(genotypes);
max_num_flies = length(master_data_struct(1).sleep);

%% Make sleep graphs

% Extract sleep info
day_sleep = zeros(max_num_flies,num_genos);
night_sleep = zeros(max_num_flies,num_genos);
total_sleep = zeros(max_num_flies,num_genos);

for i = 1:num_genos
    day_sleep(:,i) = master_data_struct(i).sleep(:,2);
    night_sleep(:,i) = master_data_struct(i).sleep(:,3);
    total_sleep(:,i) = master_data_struct(i).sleep(:,1);
end

% Make graphs
figure('Color', [1 1 1]); notBoxPlot(day_sleep); title('Day Sleep', 'FontWeight', 'bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;

figure('Color', [1 1 1]); notBoxPlot(night_sleep); title('Night Sleep', 'FontWeight', 'bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;

figure('Color', [1 1 1]); notBoxPlot(total_sleep); title('Total Sleep', 'FontWeight', 'bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;


%% Make bout graphs

% Extract data
day_bouts = zeros(max_num_flies,num_genos);
night_bouts = zeros(max_num_flies,num_genos);

for i = 1:num_genos
    day_bouts(:,i) = master_data_struct(i).sleep_bout_lengths(:,1);
    night_bouts(:,i) = master_data_struct(i).sleep_bout_lengths(:,2);
end

% Make graphs
figure('Color', [1 1 1]); notBoxPlot(day_bouts); title('Sleep Bout Length - Day', 'FontWeight', 'bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;

figure('Color', [1 1 1]); notBoxPlot(night_bouts); title('Sleep Bout Length - Night', 'FontWeight', 'bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;

%% Make activity graph

% Extract data
day_activity = zeros(max_num_flies,num_genos);
night_activity = zeros(max_num_flies,num_genos);

for i = 1:num_genos
    day_activity(:,i) = master_data_struct(i).activities(:,1);
    night_activity(:,i) = master_data_struct(i).activities(:,2);
end

% Make graphs
figure('Color', [1 1 1]); notBoxPlot(day_activity); title('Day Activity', 'FontWeight', 'bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/waking minute');
tightfig;

figure('Color', [1 1 1]); notBoxPlot(night_activity); title('Night Activity', 'FontWeight', 'bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/waking minute');
tightfig;