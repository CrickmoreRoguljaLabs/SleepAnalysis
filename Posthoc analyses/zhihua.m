%% Initiation

% Define when each day starts and ends (in earth time)
day_start = 8;
day_end = 20;

% Raw data's bin size (in min)
binsize_raw = 1;

% Define bin-size (in min)
binsize = 30;

% Default path
defpath = 'C:\Users\steph\Desktop\test for Stephen\test for Stephen\New folder\New folder';

% Find the file
[fn, filepath] = uigetfile(fullfile(defpath,'*.mat')...
    , 'Choose 1 .mat file to start...');

%% Preprocessing

% Generate folder directory
folderls = ls(fullfile(filepath , '*.mat'));

% Obtain the number of files
n_files = size(folderls , 1);

% Display folder directory
disp(['These ' , num2str(n_files), ' .mat files will be processed:'])
disp(folderls)

% Generate full name of the workspace
fn_full = fullfile(filepath, fn);

% Load sample data structure
load(fn_full, 'genos', 'n_genos');

% Display a cell to choose the genotype
disp([num2cell(1:n_genos)', genos])

% Let user choose genotype
genonum = input('Which genotype to choose (use number) = ');
geno_chosen = genos{genonum};

% Initiate a cell array of genotypes
geno_chosen_cell = cell(n_files, 1);
geno_num_chosen = zeros(n_files,1);

% Go through the .mat files in the folder to make sure the genotype can be
% found in all of them
for i = 1 : n_files
    disp(['Checking ', folderls(i,:), '...'])
    
    % Load new genotypes
    load(fullfile(filepath, folderls(i,:)), 'genos', 'n_genos');
    
    % Find the genotype
    geno_lookup = strcmp(geno_chosen, genos);
    
    if sum(geno_lookup) > 0
        % If can find the genotype, say so and save the index
        disp(['Found ', geno_chosen])
        geno_chosen_cell{i} = geno_chosen;
        geno_num_chosen(i) = find(geno_lookup == 1);
    else
        % If not, say so and re-choose
        disp(['Cannot find ', geno_chosen])
        disp('These are the genotypes:')
        
        % Display a cell to choose the genotype
        disp([num2cell(1:n_genos)', genos])
        
        % Let user choose genotype
        genonum = input('Which genotype to choose (use number) = ');
        geno_chosen_cell{i} = genos{genonum};
        geno_num_chosen(i) = genonum;
    end
end

%% Processing the master data structures

% An empty matrix to store total data (currently, this matrix is not pre-sized)
data_mat = [];

for i = 1 : n_files
    % Initiate processing
    disp(['Processing ', folderls(i,:), '...'])
    
    % Load the master data structure
    load(fullfile(filepath, folderls(i,:)),...
        'master_data_struct', 'n_sleep_bounds');
    
    % Extract unbinned activity data
    unbinned_data_temp = master_data_struct(i).data;
    
    % Reshape unbinned activity data
    unbinned_data_reshapen = reshape(unbinned_data_temp, ...
        [binsize/binsize_raw, 1440/(binsize/binsize_raw), ...
        n_sleep_bounds/2, size(unbinned_data_temp,2)]);
    
    % Bin the data
    binned_data = sum(unbinned_data_reshapen, 1);
    binned_data = mean(binned_data, 3);
    binned_data = squeeze(binned_data)';
    
    % Display the number of flies added
    disp(['Adding ', num2str(size(unbinned_data_temp,2)), ' flies.'])
    
    % Store the binned_data
    data_mat = [data_mat; binned_data]; %#ok<AGROW>
end

%% Generate the bar graph

% Generate mean and sem
act_mean = mean(data_mat, 1);
n_flies = size(data_mat, 1);
act_sem = std(data_mat, 1)/sqrt(n_flies);

% Rearrange mean and sem data points to start at -4 Zt/CT
act_mean2 = act_mean([37:48,1:36]);
act_sem2 = act_sem([37:48,1:36]);

night = [1:12,37:48];
day = 13:36;


figure
hold on
barnight = bar(night,act_mean2(night),1);
barday = bar(day, act_mean2(day),1);

errornight = scatter(night,act_mean2(night)+act_sem2(night));
errorday = scatter(day,act_mean2(day)+act_sem2(day));
hold off

set(barday,'FaceColor',[1 1 1]);
set(barnight,'FaceColor',[0.4 0.4 0.4]);

set(errorday,'MarkerEdgeColor',[0 0 0], 'SizeData', 12)
set(errornight,'MarkerEdgeColor',[0 0 0], 'SizeData', 12,...
    'MarkerFaceColor',[0.4 0.4 0.4])

 % Set X labels
set(gca,'XTick',[5 13 21 29 37 45]);
set(gca,'xticklabel',[4 8 12 16 20 24]);
set(gca,'YTick',[0 20 40 60]);

xlim([0.5,48.5])
ylim([0 60])