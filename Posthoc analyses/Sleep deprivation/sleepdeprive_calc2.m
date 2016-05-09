%% Load experiment data and date selection

% Enter the number of hours used to calculate rebound
num_of_hours_for_rebound = 6;

% Make a plot?
plot_or_not = 1;

% Read the setting file
settings_file = importdata('actogram2_settings.csv');
export_path = settings_file{2};
export_path = export_path(strfind(export_path, ',')+1:end);

% Use UI to get the expt and control .mat files
[filename_expt, expt_path] = uigetfile([export_path,'\*.mat'],'Experimental file');
[filename_control, path_control] = uigetfile([export_path,'\*.mat'],'Control file');

% Load the variables needed from the expt .mat file
load(fullfile(expt_path,filename_expt),'master_data_struct',...
    'start_date','end_date','genos','n_genos','n_days','filename_master');

% Use ui to obtain sleep deprivation dates and times
sleepdeprive_ui
uiwait(gcf)

% Calculate on which day of the the sleep deprivation data did the
% deprivation occur
day2sleepdep = datenum(SDdate) - datenum(start_date) + 1;

% Can't choose the first or the last day
% if day2sleepdep == 1
%     disp('Please do not select the first day of data collection')
%     return
% end

%% Obtain genotype and sleep deprivation data
% Ask for the ID of the gene
disp('Please enter the ID number of the genotype to be analyzed')

ID = (1:n_genos)';

table(ID,genos)

id_selected = input('ID number=');

geno_selected = genos{id_selected};

if id_selected > n_genos
    disp('ID number out of range!')
    return
end

% Obtain the number of flies from the master file
n_flies = master_data_struct(id_selected).num_processed_flies;

% Obtain the dead fly indices from the master file
dead_flies = ~boolean(master_data_struct(id_selected).alive_fly_indices);

% Calculate the index for when the sleep deprivation starts
SD_start_ind = (day2sleepdep - 1) * 288 + SDhour1 * 12 + SDmin1/5 + 1;

% Calculate the index for when the sleep deprivation stops
SD_end_ind = (day2sleepdep - 1) * 288 + SDhour2 * 12 + SDmin2/5;

% Detect if the sleep deprivation happens over 2 dates (passing midnight).
% If so, add another day to the end date.
if SD_end_ind < SD_start_ind
    SD_end_ind = SD_end_ind + 288;
end

% Calculate the index for when the rebound starts (assume immediately after
% deprivation)
RB_start_ind = SD_end_ind + 1;

% Calculate the index for when the rebound ends
RB_end_ind = RB_start_ind + num_of_hours_for_rebound * 12 - 1;

% Calculate the sleep data during deprivation (each bin = 5 min)
SD_sleep_data = master_data_struct(id_selected).data...
    (SD_start_ind:SD_end_ind,:) == 0;

% Sum up the total number of bins of sleep during deprivation
SD_sleep_data_sum = sum(SD_sleep_data)';

% Calculate the sleep data during rebound (each bin = 5 min)
RB_sleep_data = master_data_struct(id_selected).data...
    (RB_start_ind:RB_end_ind,:) == 0;

% Sum up the total number of bins of sleep during rebound
RB_sleep_data_sum = sum(RB_sleep_data)';

%% Obtain control data for sleep deprivation
% Calculate control date (the day before experiment)
% SDdate_CT = datestr(datenum(SDdate)-1,'dd-mmm-yyyy');

% Load the variables needed from the expt .mat file
load(fullfile( path_control,filename_control),'master_data_struct',...
    'start_date','end_date','genos','n_genos','n_days');

% Find the geno id in control file
id_selected = find(strcmp(genos,geno_selected));

% Find the day to find control data
day2sleepcontrol = n_days - 1; % datenum(SDdate_CT) - datenum(start_date) + 1;

% Calculate the index for when the control (previous day) starts
CT_start_ind = (day2sleepcontrol - 1) * 288 + SDhour1 * 12 + SDmin1/5 + 1;

% Calculate the index for when the control (previous day) ends
CT_end_ind = (day2sleepcontrol - 1) * 288 + SDhour2 * 12 + SDmin2/5;

% Detect if the sleep control happens over 2 dates (passing midnight).
% If so, add another day to the end date.
if CT_end_ind < CT_start_ind
    CT_end_ind = CT_end_ind + 288;
end

% Calculate the index for when the rebound starts (assume immediately after
% deprivation)
RBCT_start_ind = CT_end_ind + 1;

% Calculate the index for when the rebound ends
RBCT_end_ind = RBCT_start_ind + num_of_hours_for_rebound * 12 - 1;

% Calculate the sleep data during control (same time on the previous day)
% (each bin = 5 min)
CT_sleep_data = master_data_struct(id_selected).data...
    (CT_start_ind:CT_end_ind,:) == 0;

% Sum up the total number of bins of sleep during control
CT_sleep_data_sum = sum(CT_sleep_data)';

% Calculate the sleep data during control for rebound (same time on the 
% previous day) (each bin = 5 min)
RBCT_sleep_data = master_data_struct(id_selected).data...
    (RBCT_start_ind:RBCT_end_ind,:) == 0;

% Sum up the total number of bins of sleep during rebound control
RBCT_sleep_data_sum = sum(RBCT_sleep_data)';

%% Calculate sleep losses and rebounds
% Calculate the hours of sleep lost during deprivation, compared to
% previous day
hr_sleep_lost = CT_sleep_data_sum - SD_sleep_data_sum;

% Calculate the fraction of sleep lost during deprivation, compared to
% control of previous day
frac_sleep_lost = hr_sleep_lost ./ CT_sleep_data_sum;

% Calculate the hours of sleep rebounded after deprivation, compared to
% control of previous day
hr_sleep_rebound = RB_sleep_data_sum - RBCT_sleep_data_sum;

% Calculate the fraction of sleep rebounded after deprivation, compared to
% control of previous day
frac_sleep_rebound = (hr_sleep_rebound) ./ RBCT_sleep_data_sum;

% Calculate the fraction of sleep recovered after deprivation, compared to
% the lost sleep
frac_sleep_recovered = hr_sleep_rebound ./ hr_sleep_lost;

%% Output results

% Arrange the output matrix to contain sleep lost, sleep rebound, and sleep
% recovered
outputdata_mat = [hr_sleep_lost , hr_sleep_rebound , frac_sleep_lost , ...
    frac_sleep_rebound , frac_sleep_recovered];

% Remove dead fly rows
outputdata_mat(dead_flies,:) = NaN;

% Prime the output cell
SD_output_cell = cell(n_flies+1,6);

% Titles in the first row
SD_output_cell(1,:) = {'geno','hours of sleep lost',...
    'hours of sleep rebound','fraction of sleep lost',...
    'fraction of sleep rebound','fraction of sleep recovered'};

% Copy the genotypes to the first column (except for title)
SD_output_cell(2:end,1) = {geno_selected};

% Re-format the data to cell.
SD_output_cell(2:end,2:end) = num2cell(outputdata_mat);

% Output the data to csv
cell2csv(fullfile(export_path,['SD_',filename_master(1:end-5),'_'...
    geno_selected,'_sleep_deprive_data.csv']), SD_output_cell);

%% Make a plot of deprivation and rebound
if plot_or_not ==1 
    % Convert SD bins to number and eliminate dead flies
    SD_sleep_data = double(SD_sleep_data) * 5;
    SD_sleep_data(:,dead_flies) = NaN;
    
    % Convert RB bins to number and eliminate dead flies
    RB_sleep_data = double(RB_sleep_data) * 5;
    RB_sleep_data(:,dead_flies) = NaN;
    
    % Convert CT bins to number and eliminate dead flies
    CT_sleep_data = double(CT_sleep_data) * 5;
    CT_sleep_data(:,dead_flies) = NaN;
    
    % Convert RBCT bins to number and eliminate dead flies
    RBCT_sleep_data = double(RBCT_sleep_data) * 5;
    RBCT_sleep_data(:,dead_flies) = NaN;
    
    % Default 30 min bins for plot (as as rainbow plot)
    plot_bin_size = 30;
    
    % Calculate the number of binds for sleep deprivation (same fo CT)
    n_bins_SD = size(SD_sleep_data,1);
    
    % Calculate the number of binds for rebound (same fo RBCT)
    n_bins_RB = num_of_hours_for_rebound * 12;
        
    % Calculate the number of binds for sleep deprivation (same fo CT)
    n_bins_SD_plot = n_bins_SD / (plot_bin_size/5);
    
    % Calculate the number of binds for rebound (same fo RBCT)
    n_bins_RB_plot = n_bins_RB / (plot_bin_size/5);
    
    % Re-bin the SD sleep data
    SD_sleep_data_rebinned = reshape(SD_sleep_data,[plot_bin_size/5,...
        n_bins_SD_plot,n_flies]);
    SD_sleep_data_rebinned = squeeze(sum(SD_sleep_data_rebinned))';
    
    % Re-bin the CT sleep data
    CT_sleep_data_rebinned = reshape(CT_sleep_data,[plot_bin_size/5,...
        n_bins_SD_plot,n_flies]);
    CT_sleep_data_rebinned = squeeze(sum(CT_sleep_data_rebinned))';
    
    % Re-bin the RB sleep data
    RB_sleep_data_rebinned = reshape(RB_sleep_data,[plot_bin_size/5,...
        n_bins_RB_plot,n_flies]);
    RB_sleep_data_rebinned = squeeze(sum(RB_sleep_data_rebinned))';
    
    % Re-bin the RBCT sleep data
    RBCT_sleep_data_rebinned = reshape(RBCT_sleep_data,[plot_bin_size/5,...
        n_bins_RB_plot,n_flies]);
    RBCT_sleep_data_rebinned = squeeze(sum(RBCT_sleep_data_rebinned))';
    
    % Calculate the mean and SEM of SD sleep data
    SD_sleep_data_rebinned_mean = nanmean(SD_sleep_data_rebinned);
    SD_sleep_data_rebinned_SEM = nanstd(SD_sleep_data_rebinned) ./ sqrt(sum(~dead_flies));
    
    % Calculate the mean and SEM of SD sleep data
    CT_sleep_data_rebinned_mean = nanmean(CT_sleep_data_rebinned);
    CT_sleep_data_rebinned_SEM = nanstd(CT_sleep_data_rebinned) ./ sqrt(sum(~dead_flies));
    
    % Calculate the mean and SEM of RB sleep data
    RB_sleep_data_rebinned_mean = nanmean(RB_sleep_data_rebinned);
    RB_sleep_data_rebinned_SEM = nanstd(RB_sleep_data_rebinned) ./ sqrt(sum(~dead_flies));
    
    % Calculate the mean and SEM of RB sleep data
    RBCT_sleep_data_rebinned_mean = nanmean(RBCT_sleep_data_rebinned);
    RBCT_sleep_data_rebinned_SEM = nanstd(RBCT_sleep_data_rebinned) ./ sqrt(sum(~dead_flies));
    
    % Make the plot
    errorbar([SD_sleep_data_rebinned_mean,RB_sleep_data_rebinned_mean;...
        CT_sleep_data_rebinned_mean,RBCT_sleep_data_rebinned_mean]',...
        [SD_sleep_data_rebinned_SEM,RB_sleep_data_rebinned_SEM;...
        CT_sleep_data_rebinned_SEM,RBCT_sleep_data_rebinned_SEM]','-o','LineWidth',1.5);
    
    % Mark when sleep deprivation ends
    hold on
    plot([n_bins_SD_plot + 1,n_bins_SD_plot + 1],[0,30],'LineWidth',1,'Color',[1,0,0])
    hold off
    
    % Set the x tick marks
    x_tick_interval = 2;
    x_axis_vector = SDhour1 + SDmin1 / 60 : x_tick_interval :...
        SDhour1 + SDmin1 / 60 + (n_bins_SD_plot + n_bins_RB_plot) / 2;
    
    % Transform the time back to normal time
    x_axis_vector = x_axis_vector + 8;
    ind_4_trans = find( x_axis_vector >= 24);
    x_axis_vector( ind_4_trans ) = x_axis_vector( ind_4_trans ) - 24;
    
    % Set the x tick mark to be 24 hour cycle
    x_axis_vector_v1 = x_axis_vector;
    x_axis_vector_v2 = x_axis_vector - 24;
    x_axis_vector_v1(x_axis_vector_v1 > 24) = 0;
    x_axis_vector_v2(x_axis_vector_v2 < 0) = 0;
    
    x_axis_vector = num2cell(x_axis_vector_v1 + x_axis_vector_v2);
    
    % Change the axes
    axis([1,n_bins_SD_plot+n_bins_RB_plot,0,30])
    set(gca,'XTick',1:x_tick_interval*2:(n_bins_SD_plot+n_bins_RB_plot))
    set(gca,'XTickLabel',x_axis_vector)
    xlabel('Time')
    ylabel('sleep per 30 min (min)')
    
    % Write legend and figure background color
    legend({'SleepDeprive','Control'},'Location', 'SouthEast')
    set(gcf,'Color',[1,1,1])
    
    % Save the figure
    savefig(fullfile(export_path,['SD_',filename_master(1:end-5),'_'...
    geno_selected,'_sleep_deprive.fig']));

    disp('Figure saved')
end
