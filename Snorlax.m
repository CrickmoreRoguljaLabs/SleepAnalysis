%% Snorlax (old actogram2master)

% This file enables batch processing monitor files and organize data based
% on genotypes.
% This file is completely reworked to support moving-average analysis -SXZ
% 5/9/2016

%% Initiation

% Label batch processing and read the batch processing parameter file 
master_mode = 1;
settings_file = importdata('actogram2_settings.csv');

% Load default monitor direction
monitor_dir = settings_file{1};
monitor_dir = monitor_dir(strfind(monitor_dir, ',')+1:end);

% Load export path
export_path = settings_file{2};
export_path = export_path(strfind(export_path, ',')+1:end);

% Load PC or not PC
PC_or_not = settings_file{3};
PC_or_not = PC_or_not(strfind(PC_or_not, ',')+1:end)=='Y';

% Load threshold for deadfly determination
deadflythresh = settings_file{4};
deadflythresh = str2double(deadflythresh(strfind(deadflythresh, ',')+1));

% Load whether actograms are made
actogram_or_not = settings_file{5};
actogram_or_not = actogram_or_not(strfind(actogram_or_not, ',')+1:end)=='Y';

% Load whether rainbowplots are made
rainbow_or_not = settings_file{6};
rainbow_or_not = rainbow_or_not(strfind(rainbow_or_not, ',')+1:end)=='Y';

% Load whether to do common analyses
commonanaly_or_not = settings_file{7};
commonanaly_or_not = commonanaly_or_not(strfind(commonanaly_or_not, ',')+1:end)=='Y';

% Load whether to output 30 min fly-to-fly sleep results
sleep30_or_not = settings_file{8};
sleep30_or_not = sleep30_or_not(strfind(sleep30_or_not, ',')+1:end)=='Y';

% Load input file
[filename_master, pathname]  =  uigetfile(fullfile(monitor_dir, '*.xlsx'));

%% Processing the parameter files
% Load the parameter file in to RAM
master_direction = importdata(fullfile(pathname,filename_master));

% Convert channel indices to nums (now support the legacy mode as well)
for i = 3:length(master_direction.textdata)
    if size(master_direction.data,2) > 1 % Legacy mode
        if ~strcmp(master_direction.textdata{i,1},master_direction.textdata{i-1,1})
            % If the monitor changes, then writes 1:n as channels
            master_direction.textdata{i,3} = 1 : master_direction.data(i-2,1);
        else
            % If the monitor does not change, then continue the previous
            % vector
            master_direction.textdata{i,3} = (1 : master_direction.data(i-2,1))...
                + max(master_direction.textdata{i-1,3});
        end
    else
        master_direction.textdata{i,3} = str2num(master_direction.textdata{i,3}); %#ok<ST2NM>
    end
end

% Read the start and end dates from the parameter file
start_date = master_direction.textdata{1,1};
end_date = master_direction.textdata{2,1};

% Find the unique genotypes
genos = master_direction.textdata(:,2);
genos(1:2) = '';
genos = unique(genos,'stable');

% Determine the number of unique genotypes
n_genos = size(genos,1);

% Construct the master data file (in the structure form)
master_data_struct = struct('genotype','','rainbowgroup',[],....
    'num_alive_flies',0,'num_processed_flies',0,'alive_fly_indices',[],...
    'data',[],'sleep_data',[]   ,'sleep_unbinned',[],'sleep_bout_lengths',[],'sleep_bout_numbers',[],...
    'activities',[],'delays',[]);

% Construct the master data file (in the structure form)
% master_data_struct = struct('genotype','','rainbowgroup',[],....
%     'num_alive_flies',0,'num_processed_flies',0,'alive_fly_indices',[],...
%     'data',[],'sleep',[],'sleep_unbinned',[],'sleep_bout_lengths',[],'sleep_bout_numbers',[],...
%     'activities',[],'delays',[]);

master_data_struct(1:n_genos,1) = master_data_struct;

% Label the genotypes and rainbow indices on the master data structure
for i = 1:n_genos
    % Label genotypes
    master_data_struct(i).genotype = genos{i};
    
    % Find which rows in the parameter file contain the the genotype
    temp_rows_of_geno = strcmp(master_direction.textdata(:,2),genos{i});
    
    % Eliminate the first two rows (the have no numbers)
    temp_rows_of_geno(1:2) = [];
    
    % Determine which rainbow group the current genotype is in (ignore NaN and use the max group value
    % if multiple group numbers were entered (don't do it!))
    master_data_struct(i).rainbowgroup = nanmax(master_direction.data(temp_rows_of_geno,end));   
end

% Determine how many lines to read from the parameter file. Each genotype
% can be read multiple times if appear multiple times in the parameter
% file.
master_lines_to_read = size(master_direction.textdata,1);

%% Processing the monitor files
% Initiate the waitbar
h  =  waitbar(3/master_lines_to_read,'Processing');

% Read from the 3rd line (the first two lines are dedicated to initiation and end dates)
ii = 3;
while ii<= master_lines_to_read
    % Determine which line of the parameter file to read
    current_line_to_read = ii-2;
    
    % Obtain the monitor name
    current_monitor_name = master_direction.textdata{ii,1};
    filename = [current_monitor_name,'.txt'];
    
    % Adjust the waitbar progress
    waitbar(ii/master_lines_to_read,h,['Processing: ', current_monitor_name]);
        
    % Determine the number of genoypes to read from the current monitor
    % file
    n_genos_of_current_monitor = sum(strcmp(master_direction.textdata(:,1),current_monitor_name));
    
    % Use the actogram2 code to read the monitor
    actogram2;
    
    % Determine which line to read next from the next monitor file
    ii = ii+n_genos_of_current_monitor;
end
close(h)

%% Calculate periodicity
%{
for ii = 1 : n_genos
    % Use the CircadianFT function to calculate the periodicity of the
    % animals
    master_data_struct(ii).periodicity = CircadianFT(master_data_struct(ii).data...
        (:,master_data_struct(ii).alive_fly_indices), 0);
end
%}

%% Output files: average sleep data
% Prime the cell to write data in
% Can skip during debugging

average_output_cell = cell(n_genos+1,16);

average_output_cell(1,:) = {'geno','# loaded','# alive','total sleep MA',...
    'day sleep MA','night sleep MA',...
    'day bout length','night bout length','total bout length',...
    'day bout number','night bout number','total bout number',...
    'day activity','night activity','total activity','delays'};


for ii = 1:n_genos
    % 1st column shows the genotypes
    average_output_cell{ii+1,1} = genos{ii};
    
    % 2nd column shows how many flies loaded
    average_output_cell{ii+1,2} = master_data_struct(ii).num_processed_flies;
    
    % 3rd column shows how many flies remained alive at the end
    average_output_cell{ii+1,3} = master_data_struct(ii).num_alive_flies;
    
    % 4th column shows average total sleep per genotype
    % average_output_cell{ii+1,4} = nanmean(master_data_struct(ii).sleep(:,1));
    
    % 5th column shows average day-time sleep per genotype
    % average_output_cell{ii+1,5} = nanmean(master_data_struct(ii).sleep(:,2));
    
    % 6th column shows average night-time sleep per genotype
    % average_output_cell{ii+1,6} = nanmean(master_data_struct(ii).sleep(:,3));
    
    % 4th column shows average total sleep per genotype using moving
    % average analysis
    average_output_cell{ii+1,4} = nanmean(master_data_struct(ii).sleep_unbinned(:,1));
    
    % 5th column shows average day-time sleep per genotype using moving
    % average analysis
    average_output_cell{ii+1,5} = nanmean(master_data_struct(ii).sleep_unbinned(:,2));
    
    % 6th column shows average night-time sleep per genotype using moving
    % average analysis
    average_output_cell{ii+1,6} = nanmean(master_data_struct(ii).sleep_unbinned(:,3));
    
    % 7th column shows average day-time sleep bout length per genotype
    average_output_cell{ii+1,7} = nanmean(master_data_struct(ii).sleep_bout_lengths(:,1));
    
    % 8th column shows average night-time sleep bout length per genotype
    average_output_cell{ii+1,8} = nanmean(master_data_struct(ii).sleep_bout_lengths(:,2));
    
    % 9th column shows average total sleep bout length per genotype
    average_output_cell{ii+1,9} = nanmean(master_data_struct(ii).sleep_bout_lengths(:,3));
    
    % 10th column shows average day-time sleep bout number per genotype
    average_output_cell{ii+1,10} = nanmean(master_data_struct(ii).sleep_bout_numbers(:,1));
    
    % 11th column shows average night-time sleep bout number per genotype
    average_output_cell{ii+1,11} = nanmean(master_data_struct(ii).sleep_bout_numbers(:,2));
    
    % 12th column shows average total sleep bout number per genotype
    average_output_cell{ii+1,12} = nanmean(master_data_struct(ii).sleep_bout_numbers(:,3));
    
    % 13th column shows average day-time activity per genotype
    average_output_cell{ii+1,13} = nanmean(master_data_struct(ii).activities(:,1));
    
    % 14th column shows average night-time activity per genotype
    average_output_cell{ii+1,14} = nanmean(master_data_struct(ii).activities(:,2));
    
    % 15th column shows average night-time activity per genotype
    average_output_cell{ii+1,15} = nanmean(master_data_struct(ii).activities(:,3));
    
    % 16th column shows average night-time delay per genotype
    average_output_cell{ii+1,16} = nanmean(master_data_struct(ii).delays);
    

    
end

% Write the cell data
cell2csv(fullfile(export_path,[filename_master(1:end-5),'_average_sleep_data.csv']),average_output_cell);


%% Output files: concatenated sleep data (per fly)
% Can sleep during debugging

% Initialize the cell & add column headers
sleep_output_cell = cell(sum([master_data_struct.num_processed_flies])+1,14);

sleep_output_cell(1,:) = {'Genotype', 'Total sleep MA', 'Day sleep MA',...
    'Night sleep MA', 'Day sleep bout length', 'Night sleep bout length',...
    'Total sleep bout length', 'Day sleep bout number',...
    'Night sleep bout number', 'Total sleep bout number', 'Day activity',...
    'Night activity', 'Total activity', 'Sleep delays'};

% Establish counter to keep track of row position in cell
idx = 2;

for i = 1:n_genos
    
    % Populate genotype
    for k = idx:idx+master_data_struct(i).num_processed_flies-1
        sleep_output_cell{k,1} = master_data_struct(i).genotype;        
    end
    
    % Populate sleep data
    sleep_output_cell(idx:idx+master_data_struct(i).num_processed_flies-1,2:4) =...
        num2cell(master_data_struct(i).sleep_unbinned(:,:));
    
    % Populate bout length data
    sleep_output_cell(idx:idx+master_data_struct(i).num_processed_flies-1,5:7) =...
        num2cell(master_data_struct(i).sleep_bout_lengths(:,:));
    
    % Populate bout number data
    sleep_output_cell(idx:idx+master_data_struct(i).num_processed_flies-1,8:10) =...
        num2cell(master_data_struct(i).sleep_bout_numbers(:,:));
    
    % Populate activity data
    sleep_output_cell(idx:idx+master_data_struct(i).num_processed_flies-1,11:13) =...
        num2cell(master_data_struct(i).activities(:,:));
    
    % Populate Delay data
    sleep_output_cell(idx:idx+master_data_struct(i).num_processed_flies-1,14) =...
        num2cell(master_data_struct(i).delays(:,:));
    
    % Iterate index
    idx = idx + master_data_struct(i).num_processed_flies;

end

% Write the cell data
cell2csv(fullfile(export_path,[filename_master(1:end-5),'_sleep_data.csv']),sleep_output_cell);

%% Output 30-min sleep data
if sleep30_or_not
    % Prime the cell
    sleep30_output_cell = cell(n_reads/30*interval+1, sum([master_data_struct.num_processed_flies])+1);

    % Establish counter to keep track of row position in cell
    idx = 1;

    for i = 1:n_genos

        % Populate genotype
        for k = idx:idx+master_data_struct(i).num_processed_flies-1
            sleep30_output_cell{1,k} = master_data_struct(i).genotype;        
        end

        % Bin the data into 30 mins
        temp_sleep_mat = master_data_struct(i).sleep_data();
        temp_sleep_mat = squeeze(sum(reshape(temp_sleep_mat,[30/interval, n_reads/30*interval, ...
            master_data_struct(i).num_processed_flies]),1));

        % Get rid of dead flies
        temp_sleep_mat(:,~master_data_struct(i).alive_fly_indices) = NaN;

        % Populate sleep data
        sleep30_output_cell(2:end,idx:idx+master_data_struct(i).num_processed_flies-1) =...
            num2cell(temp_sleep_mat);

        % Iterate index
        idx = idx + master_data_struct(i).num_processed_flies;

    end

    cell2csv(fullfile(export_path,[filename_master(1:end-5),'_30_min_sleep_data.csv']),sleep30_output_cell);
end

%% Output files: other stuff and actogram
% Can skip during debugging

% Save the work space
save(fullfile(export_path,[filename_master(1:end-5),'_workspace.mat']));

% Determine whether to make actograms
if actogram_or_not
    % Save the actograms
    for ii = 1:n_genos
        % generate temporary binned data for actogram (5 min bins)
        actogramdata_temp = reshape(master_data_struct(ii).data,...
            [5/interval, n_reads/(5/interval), ...
            master_data_struct(ii).num_processed_flies]);

        % sum the transformed activity matrix
        actogramdata_temp = squeeze(sum(actogramdata_temp, 1));

        % Calculate the bounds, in terms of time stamps, for each day's data
        % This matrix now assumes each day's data starts at 8 am
        time_bounds = repmat([first_time_hr, 32], [n_sleep_bounds/2, 1]);

        % Calculate the matrix boundries for each day's data
        mat_bounds = ones(n_sleep_bounds/2, 1);
        mat_bounds(:,2) = 288 * (1:n_sleep_bounds/2);
        mat_bounds(2:end,1) = mat_bounds(1:end-1,2) + 1;

        % Generate the actogram
        actogramprint(actogramdata_temp, time_bounds, mat_bounds ,...
            n_sleep_bounds/2, export_path, [filename_master(1:end-5),'_',genos{ii}],...
            [monitor_data.textdata{1,2}, ' ',genos{ii}],PC_or_not)
    end
end
%% Rainbow plots

if rainbow_or_not
    % If user decides to make rainbow plot
    
    % Construct a vector of rainbow groups corresponding to the genotypes
    rainbowgroups_vector = cell2mat({master_data_struct.rainbowgroup})';

    % Determine the unique rainbow groups (ignoring the NaNs) and their count
    rainbowgroups_unique = unique(rainbowgroups_vector(rainbowgroups_vector>-99999),'stable');
    rainbowgroups_unique = rainbowgroups_unique(rainbowgroups_unique~=0); %Group 0 reserved for universal controls
    rainbowgroups_n = length(rainbowgroups_unique);

    for j = 1:rainbowgroups_n
        % Find how many and which genotypes are of the current rainbow group
        geno_indices_of_the_current_rainbowgroup = [find(rainbowgroups_vector == rainbowgroups_unique(j));find(rainbowgroups_vector == 0)]; % Plot the current group and Group 0
        n_geno_of_the_current_rainbowgroup = length(geno_indices_of_the_current_rainbowgroup);

        % Prime the rainbow data matrix
        rainbow_mat = zeros(48,n_geno_of_the_current_rainbowgroup);
        rainbow_mat_sem = zeros(48,n_geno_of_the_current_rainbowgroup);
        rainbow_mat_tape = zeros(size(master_data_struct(1).data,1)/30/interval,n_geno_of_the_current_rainbowgroup);
        rainbow_mat_sem_tape = zeros(size(master_data_struct(1).data,1)/30/interval,n_geno_of_the_current_rainbowgroup);

        % Prime the output rainbow cells
        rainbow_cell = cell(98,n_geno_of_the_current_rainbowgroup);
        % dailyrainbow_cell = cell(n_reads/30+1, n_geno_of_the_current_rainbowgroup);
        
        for i = 1:n_geno_of_the_current_rainbowgroup
            % Calculate the average and std/sem sleep per 5 min and 30 min of one genotype
            % Also calculate the day-by-day rainbow data (tape, inspired by the Turing machine)
            % (Ignoring dead flies)

            % Variables requested by people
            current_rainbow_geno = geno_indices_of_the_current_rainbowgroup(i);
            current_rainbow_alive_flies = master_data_struct(current_rainbow_geno).alive_fly_indices>0;

    %         % 5 min bins - both mean and SEM
    %         temp_average_sleep_per_5_min_tape = mean(master_data_struct(current_rainbow_geno).data...
    %             (:,current_rainbow_alive_flies) == 0,2)*5;
    %         temp_std_sleep_per_5_min_tape = std((master_data_struct(current_rainbow_geno).data...
    %             (:,current_rainbow_alive_flies) == 0)*5,1,2);
    %         temp_average_sleep_per_5_min = mean(reshape(master_data_struct(current_rainbow_geno).data...
    %             (:,current_rainbow_alive_flies) == 0,288,[]),2)*5;
    %         temp_std_sleep_per_5_min = std(reshape(master_data_struct(current_rainbow_geno).data...
    %             (:,current_rainbow_alive_flies) == 0,288,[])*5,1,2);
    %         
    %         % 30 min bins - both mean and SEM
    %         temp_average_sleep_per_30_min_tape = sum(reshape(temp_average_sleep_per_5_min_tape,6,[]))';
    %         temp_sem_sleep_per_30_min_tape = sqrt(sum(reshape(temp_std_sleep_per_5_min_tape,6,[]).^2)')...
    %             /sqrt(master_data_struct(current_rainbow_geno).num_alive_flies);
    %         temp_average_sleep_per_30_min = sum(reshape(temp_average_sleep_per_5_min,6,[]))';
    %         temp_sem_sleep_per_30_min  =  sqrt(sum(reshape(temp_std_sleep_per_5_min,6,[]).^2)')...
    %             /sqrt(master_data_struct(current_rainbow_geno).num_alive_flies);

            % Generate rainbow data from raw sleep data
            % Extract the data
            temp_sleep_data_unbinned = master_data_struct(current_rainbow_geno).sleep_data;
            
            % Remove deadflies
            temp_sleep_data_unbinned = temp_sleep_data_unbinned(:,current_rainbow_alive_flies);
            
            % Bin to 30 min, continuous across days
            % This is the individual fly taped rainbow data in case for future usage
            temp_sleep_data_30_min_tape = reshape(temp_sleep_data_unbinned,...
                [30, n_reads/30/interval, master_data_struct(current_rainbow_geno).num_alive_flies]);
            temp_sleep_data_30_min_tape = squeeze(sum(temp_sleep_data_30_min_tape, 1));

            % 30-min mean and SEM data, continuous across days, averaged
            % across flies
            temp_average_sleep_per_30_min_tape = mean(temp_sleep_data_30_min_tape,2);
            temp_sem_sleep_per_30_min_tape = std(temp_sleep_data_30_min_tape,1,2)/...
                sqrt(master_data_struct(current_rainbow_geno).num_alive_flies);

            % Bin to 30 min, averaged across days
            % This is the individual fly rainbow data in case for future usage
            temp_sleep_data_30_min = reshape(temp_sleep_data_30_min_tape,...
                [48, n_reads/30/interval/48, master_data_struct(current_rainbow_geno).num_alive_flies]);
            temp_sleep_data_30_min = squeeze(mean(temp_sleep_data_30_min, 2));

            % 30-min mean and SEM data, averaged across days
            temp_average_sleep_per_30_min = mean(temp_sleep_data_30_min,2);
            temp_sem_sleep_per_30_min = std(temp_sleep_data_30_min, 1, 2) /...
                sqrt(master_data_struct(current_rainbow_geno).num_alive_flies);

            % Construct rainbow data cell
            rainbow_cell{1,i} = genos{current_rainbow_geno};
            rainbow_cell{2,i} = master_data_struct(current_rainbow_geno).num_alive_flies;
            rainbow_cell(3:50,i) = num2cell(temp_average_sleep_per_30_min);
            rainbow_cell(51:98,i) = num2cell(temp_sem_sleep_per_30_min);

            % Put the data in the rainbow matrices
            rainbow_mat(:,i) = temp_average_sleep_per_30_min;
            rainbow_mat_sem(:,i) = temp_sem_sleep_per_30_min;
            rainbow_mat_tape(:,i) = temp_average_sleep_per_30_min_tape;
            rainbow_mat_sem_tape(:,i) = temp_sem_sleep_per_30_min_tape;
        end

        % Create the rainbox plots
        figure('Color', [1 1 1 ]);

        % setting the color scheme of the rainbow plot
        set(gcf,'Colormap',cbrewer('seq','PuBuGn',9));
        set(gcf,'DefaultAxesColorOrder',cbrewer('qual','Set2',8))
        set(gcf,'DefaultLineLineWidth',1.2)

        % Plotting
        mseb(1:48,rainbow_mat',rainbow_mat_sem');
        axis([1,49,0,30])
        set(gca,'XTick',1:8:49)
        set(gca,'XTickLabel',{'8','12','16','20','24','4','8'})
        legend({master_data_struct(geno_indices_of_the_current_rainbowgroup).genotype},'Location', 'SouthEast')
        xlabel('Time')
        ylabel('sleep per 30 min (min)')

        % Save the fig and the data
        saveas(gcf, fullfile(export_path,[filename_master(1:end-5),'_',num2str(rainbowgroups_unique(j)),'_rainbow.pdf']));
        savefig(fullfile(export_path,[filename_master(1:end-5),'_',num2str(rainbowgroups_unique(j)),'_rainbow.fig']));
        cell2csv(fullfile(export_path,[filename_master(1:end-5),'_',num2str(rainbowgroups_unique(j)),'_rainbowdata.csv']),rainbow_cell)
        close gcf

        % Create the daily rainbox plots
        plotsizevec=[50,50,1200,600];%This size vector can be changed by the user to customize the plot size. Format ([X_position, Y_position, Width, Height]).
        panels2print = min(n_sleep_bounds/2,9);
        pages2print = 0;
        while panels2print > 0
            figure(102)
            set(102,'Position',plotsizevec);

            % setting the color scheme of the rainbow plot
            set(gcf,'Colormap',cbrewer('seq','PuBuGn',9));
            set(gcf,'DefaultAxesColorOrder',cbrewer('qual','Set2',8))
            set(gcf,'DefaultLineLineWidth',1.2)

            for k = 1 : n_sleep_bounds/2
                subplot(3,3,k)
                mseb(1:48,rainbow_mat_tape((k-1)*48+1:(k-1)*48+48,:)',rainbow_mat_sem_tape((k-1)*48+1:(k-1)*48+48,:)');
                %errorbar(rainbow_mat_tape((k-1)*48+1:(k-1)*48+48,:),rainbow_mat_sem_tape((k-1)*48+1:(k-1)*48+48,:),'-o','LineWidth',1.3,'MarkerSize',2)
                axis([1,49,0,30])
                set(gca,'XTick',1:8:49);
                rainbow_tape_xlabel_cell = {'8','12','16','20','24','4','8'};
                set(gca,'XTickLabel',rainbow_tape_xlabel_cell)
                if k == n_sleep_bounds/2
                    legend({master_data_struct(geno_indices_of_the_current_rainbowgroup).genotype},'Location', 'SouthEast')
                    legend boxoff
                end
                xlabel('Time')
                ylabel('sleep per 30 min (min)')
                set(gcf,'Color',[1,1,1])

                % Get rid of that silly box
                set(gca, 'box', 'off');

            end
            if panels2print > 6
                tightfig;
            end
            set(102,'Position',plotsizevec);
            panels2print=panels2print-9;
            pages2print=pages2print+1;
            saveas(102, fullfile(export_path,[filename_master(1:end-5),'_',num2str(rainbowgroups_unique(j)),'_',num2str(pages2print),'_dailyrainbow.pdf']));
            savefig(fullfile(export_path,[filename_master(1:end-5),'_',num2str(rainbowgroups_unique(j)),'_',num2str(pages2print),'_dailyrainbow.fig']));
            close(102)
        end
    end
end
%% Make graphs of sleep data
if commonanaly_or_not
    makeSleepGraphs
end