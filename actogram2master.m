% This file enables batch processing monitor files and organize data based
% on genotypes.

%% Initiation

% Label batch processing and read the batch processing parameter file 
master_mode = 1;
settings_file = importdata('actogram2_settings.csv');
monitor_dir = settings_file{1};
monitor_dir = monitor_dir(strfind(monitor_dir, ',')+1:end);
export_path = settings_file{2};
export_path = export_path(strfind(export_path, ',')+1:end);
PC_or_not = settings_file{3};
PC_or_not = PC_or_not(strfind(PC_or_not, ',')+1:end)=='Y';

[filename_master, pathname]  =  uigetfile(monitor_dir); % This address should be changed according to the user

%% Processing the parameter files
% Load the parameter file in to RAM
master_direction = importdata(fullfile(pathname,filename_master));

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
master_data_struct = struct('genotype','','rainbowgroup',[],'num_alive_flies',0,'num_processed_flies',0,'alive_fly_indices',[],'data',[],'sleep',[],'sleep_bout_lengths',[],'sleep_bout_numbers',[],'activities',[],'delays',[]);
master_data_struct(1:n_genos,1) = master_data_struct;

% Label the genotypes and rainbow indices on the master data strcuture
for i = 1:n_genos
    % Label genotypes
    master_data_struct(i).genotype = genos{i};
    
    % Find which rows in the parameter file contain the the genotype
    temp_rows_of_geno = strcmp(master_direction.textdata(:,2),genos{i});
    
    % Eliminate the first two rows (the have no numbers)
    temp_rows_of_geno(1:2) = [];
    
    % Determine which rainbow group the current genotype is in (ignore NaN and use the max group value
    % if multiple group numbers were entered (don't do it!))
    master_data_struct(i).rainbowgroup = nanmax(master_direction.data(temp_rows_of_geno,2));   
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

%% Output files
% Prime the the cell to write data in
master_output_cell = cell(n_genos+1,13);
master_output_cell(1,:) = {'geno','# loaded','# alive','total sleep','day sleep',...
    'night sleep','day bout length','night bout length','day bout number',...
    'night bout number','day activity','night activity','delays'};

for ii = 1:n_genos
    % First column shows the genotypes
    master_output_cell{ii+1,1} = genos{ii};
    
    % Second column shows how many flies loaded
    master_output_cell{ii+1,2} = master_data_struct(ii).num_processed_flies;
    
    % Third column shows how many flies remained alive at the end
    master_output_cell{ii+1,3} = master_data_struct(ii).num_alive_flies;
    
    % Forth column shows average total sleep per genotype
    master_output_cell{ii+1,4} = nanmean(master_data_struct(ii).sleep(:,1));
    
    % Fifth column shows average day-time sleep per genotype
    master_output_cell{ii+1,5} = nanmean(master_data_struct(ii).sleep(:,2));
    
    % Sixth column shows average night-time sleep per genotype
    master_output_cell{ii+1,6} = nanmean(master_data_struct(ii).sleep(:,3));
    
    % Seventh column shows average day-time sleep bout length per genotype
    master_output_cell{ii+1,7} = nanmean(master_data_struct(ii).sleep_bout_lengths(:,1));
    
    % Eighth column shows average night-time sleep bout length per genotype
    master_output_cell{ii+1,8} = nanmean(master_data_struct(ii).sleep_bout_lengths(:,2));
    
    % Ninth column shows average day-time sleep bout number per genotype
    master_output_cell{ii+1,9} = nanmean(master_data_struct(ii).sleep_bout_numbers(:,1));
    
    % Tenth column shows average night-time sleep bout number per genotype
    master_output_cell{ii+1,10} = nanmean(master_data_struct(ii).sleep_bout_numbers(:,2));
    
    % Eleventh column shows average day-time activity per genotype
    master_output_cell{ii+1,11} = nanmean(master_data_struct(ii).activities(:,1));
    
    % Twelfth column shows average night-time activity per genotype
    master_output_cell{ii+1,12} = nanmean(master_data_struct(ii).activities(:,2));
    
    % Thirteenth column shows average night-time delay per genotype
    master_output_cell{ii+1,13} = nanmean(master_data_struct(ii).delays);
end


% Write the cell data
cell2csv(fullfile(export_path,[filename_master(1:end-5),'_output.csv']),master_output_cell);

% Save the work space
save(fullfile(export_path,[filename_master(1:end-5),'_workspace.mat']));

% Save the actograms
for ii = 1:n_genos
    actogramprint(master_data_struct(ii).data, time_bounds, mat_bounds , n_days, export_path, [filename_master(1:end-5),'_',genos{ii}], [monitor_data.textdata{1,2}, ' ',genos{ii}],PC_or_not)
end

%% Rainbow plots
% Construct a vector of rainbow groups corresponding to the genotypes
rainbowgroups_vector = cell2mat({master_data_struct.rainbowgroup})';

% Determine the unique rainbow groups (ignoring the NaNs) and their count
rainbowgroups_unique = unique(rainbowgroups_vector(rainbowgroups_vector>-99999),'stable');
rainbowgroups_unique=rainbowgroups_unique(rainbowgroups_unique~=0); %Group 0 reserved for universal controls
rainbowgroups_n = length(rainbowgroups_unique);

% Define colormap
thiscolormap = ...
mat2gray([31,120,180;...
51,160,44;...
227,26,28;...
255,127,0;...
106,61,154;...
177,89,40;...
166,206,227;...
178,223,138;...
251,154,153;...
253,191,111;...
202,178,214;...
255,255,153]);



for j = 1:rainbowgroups_n
    % Find how many and which genotypes are of the current rainbow group
    geno_indices_of_the_current_rainbowgroup = [find(rainbowgroups_vector == rainbowgroups_unique(j));find(rainbowgroups_vector == 0)]; % Plot the current group and Group 0
    n_geno_of_the_current_rainhowgroup = length(geno_indices_of_the_current_rainbowgroup);
    
    % Prime the rainbow data matrix
    rainbow_mat = zeros(48,n_geno_of_the_current_rainhowgroup);
    rainbow_mat_sem = zeros(48,n_geno_of_the_current_rainhowgroup);
    rainbow_mat_tape = zeros(size(master_data_struct(1).data,1)/6,n_geno_of_the_current_rainhowgroup);
    rainbow_mat_sem_tape = zeros(size(master_data_struct(1).data,1)/6,n_geno_of_the_current_rainhowgroup);
    
    % Prime the output rainbow cell
    rainbow_cell = cell(98,n_geno_of_the_current_rainhowgroup);
        
    for i = 1:n_geno_of_the_current_rainhowgroup
        % Calculate the average and std/sem sleep per 5 min and 30 min of one genotype
        % Also calculate the day-by-day rainbow data (tape, inspired by the Turing machine)
        % (Ignoring dead flies)
        temp_average_sleep_per_5_min_tape = mean(master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).data(:,master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).alive_fly_indices>0) == 0,2)*5;
        temp_std_sleep_per_5_min_tape = std((master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).data(:,master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).alive_fly_indices>0) == 0)*5,1,2);
        temp_average_sleep_per_5_min = mean(reshape(master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).data(:,master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).alive_fly_indices>0) == 0,288,[]),2)*5;
        temp_std_sleep_per_5_min = std(reshape(master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).data(:,master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).alive_fly_indices>0) == 0,288,[])*5,1,2);
        
        temp_average_sleep_per_30_min_tape = sum(reshape(temp_average_sleep_per_5_min_tape,6,[]))';
        temp_sem_sleep_per_30_min_tape = sqrt(sum(reshape(temp_std_sleep_per_5_min_tape,6,[]).^2)')/sqrt(master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).num_alive_flies);
        temp_average_sleep_per_30_min = sum(reshape(temp_average_sleep_per_5_min,6,[]))';
        temp_sem_sleep_per_30_min  =  sqrt(sum(reshape(temp_std_sleep_per_5_min,6,[]).^2)')/sqrt(master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).num_alive_flies);
        
        rainbow_cell{1,i} = genos{geno_indices_of_the_current_rainbowgroup(i)};
        rainbow_cell{2,i} = master_data_struct(geno_indices_of_the_current_rainbowgroup(i)).num_alive_flies;
        rainbow_cell(3:50,i) = num2cell(temp_average_sleep_per_30_min);
        rainbow_cell(51:98,i) = num2cell(temp_sem_sleep_per_30_min);
        % Put the data in the rainbow matrices
        rainbow_mat(:,i) = temp_average_sleep_per_30_min;
        rainbow_mat_sem(:,i) = temp_sem_sleep_per_30_min;
        rainbow_mat_tape(:,i) = temp_average_sleep_per_30_min_tape;
        rainbow_mat_sem_tape(:,i) = temp_sem_sleep_per_30_min_tape;
    end
    
    % Create the rainbox plots
    errorbar(rainbow_mat,rainbow_mat_sem,'-o','LineWidth',1.5);
    colormap(gcf,thiscolormap);
    axis([1,49,0,30])
    set(gca,'XTick',1:8:49)
    set(gca,'XTickLabel',{'8','12','16','20','24','4','8'})
    legend({master_data_struct(geno_indices_of_the_current_rainbowgroup).genotype},'Location', 'SouthEast')
    xlabel('Time')
    ylabel('sleep per 30 min (min)')
    set(gcf,'Color',[1,1,1])
    
    % Save the fig and the data
    % saveas(fullfile(export_path,[filename_master(1:end-5),'_',num2str(rainbowgroups_unique(j)),'_rainbow.pdf']));
    savefig(fullfile(export_path,[filename_master(1:end-5),'_',num2str(rainbowgroups_unique(j)),'_rainbow.fig']));
    cell2csv(fullfile(export_path,[filename_master(1:end-5),'_',num2str(rainbowgroups_unique(j)),'_rainbowdata.csv']),rainbow_cell)
    close gcf
    
    % Create the daily rainbox plots
    plotsizevec=[50,50,1200,600];%This size vector can be changed by the user to customize the plot size. Format ([X_position, Y_position, Width, Height]).
    panels2print = min(n_days,9);
    pages2print = 0;
    while panels2print > 0
        figure(102)
        set(102,'Position',plotsizevec);
        for k=1:n_days
            subplot(3,3,k)
            errorbar(rainbow_mat_tape((k-1)*48+1:(k-1)*48+48,:),rainbow_mat_sem_tape((k-1)*48+1:(k-1)*48+48,:),'-o','LineWidth',1.3,'MarkerSize',2);
            colormap(102,thiscolormap);
            axis([1,49,0,30])
            set(gca,'XTick',1:8:49);
            rainbow_tape_xlabel_cell = {'8','12','16','20','24','4','8'};
            set(gca,'XTickLabel',rainbow_tape_xlabel_cell)
            if k==n_days
                legend({master_data_struct(geno_indices_of_the_current_rainbowgroup).genotype},'Location', 'SouthEast')
            end
            xlabel('Time')
            ylabel('sleep per 30 min (min)')
            set(gcf,'Color',[1,1,1])
        end
        if panels2print > 6
            tightfig;
        end
        set(102,'Position',plotsizevec);
        panels2print=panels2print-9;
        pages2print=pages2print+1;
        savefig(fullfile(export_path,[filename_master(1:end-5),'_',num2str(rainbowgroups_unique(j)),'_',num2str(pages2print),'_dailyrainbow.fig']));
        close(102)
    end
end

%% Periodicity (testing)
%{
test = master_data_struct(4).data;
test2 = mean(test,2);
x = test2;
fs  =  12;                % Sample frequency (bin/hour)
m  =  length(x);          % Window length
n  =  pow2(nextpow2(m));  % Transform length
y  =  fft(x,n);           % DFT
f  =  (0:n-1)*(fs/n);     % Frequency range
power  =  y.*conj(y)/n;   % Power of the DFT
plot(1./f(5:n/2),power(5:n/2))
ylim = get(gca,'YLim');
hold on
plot([12 12],ylim,'r')
hold off
xlabel('Period (hour)')
ylabel('Power')
title('{\bf Periodogram}')
%}

