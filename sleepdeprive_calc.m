%% Load data and date selection

% Enter the number of hours used to calculate rebound
num_of_hours_for_rebound = 6;

% Keep the variables needed
keep master_data_struct start_date end_date genos n_genos n_days...
    export_path num_of_hours_for_rebound filename_master

% Use ui to obtain sleep deprivation dates and times
sleepdeprive_ui
uiwait(gcf)

% Calculate on which day of the the sleep deprivation data did the
% deprivation occur
day2sleepdep = datenum(SDdate) - datenum(start_date) + 1;

% Can't choose the first or the last day
if day2sleepdep == 1 || day2sleepdep == n_days
    disp('Please do not select the first day of data collection')
    return
end

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

% Calculate the index for when the control (previous day) starts
CT_start_ind = SD_start_ind - 288;

% Calculate the index for when the control (previous day) ends
CT_end_ind = SD_end_ind - 288;

% Calculate the index for when the control (previous day) starts
CTRB_start_ind = RB_start_ind - 288;

% Calculate the index for when the control (previous day) ends
CTRB_end_ind = RB_end_ind - 288;

%% Genotype selection and data extraction
% Ask for the ID of the gene
disp('Please enter the ID number of the genotype to be analyzed')

ID = (1:n_genos)';

table(ID,genos)

id_selected = input('ID number=');

if id_selected > n_genos
    disp('ID number out of range!')
    return
end

% Calculate the sleep data during deprivation (each bin = 5 min)
SD_sleep_data = sum(master_data_struct(id_selected).data...
    (SD_start_ind:SD_end_ind,:) == 0)';

% Calculate the sleep data during rebound (each bin = 5 min)
RB_sleep_data = sum(master_data_struct(id_selected).data...
    (RB_start_ind:RB_end_ind,:) == 0)';

% Calculate the sleep data during control (same time on the previous day)
% (each bin = 5 min)
CT_sleep_data = sum(master_data_struct(id_selected).data...
    (CT_start_ind:CT_end_ind,:) == 0)';

% Calculate the sleep data during control for rebound (same time on the 
% previous day) (each bin = 5 min)
RBCT_sleep_data = sum(master_data_struct(id_selected).data...
    (CTRB_start_ind:CTRB_end_ind,:) == 0)';

% Calculate the fraction of sleep lost during deprivation, compared to
% control of previous day
frac_sleep_lost = (CT_sleep_data - SD_sleep_data) ./ CT_sleep_data;

% Calculate the fraction of sleep rebounded after deprivation, compared to
% control of previous day
frac_sleep_rebound = (RB_sleep_data - RBCT_sleep_data) ./ RBCT_sleep_data;

% Calculate the fraction of sleep recovered after deprivation, compared to
% the lost sleep
frac_sleep_recovered = (RB_sleep_data - RBCT_sleep_data) ./ (CT_sleep_data - SD_sleep_data);

%% Output results
% Obtain the number of flies from the master file
n_flies = master_data_struct(id_selected).num_processed_flies;

% Obtain the dead fly indices from the master file
dead_flies = ~boolean(master_data_struct(id_selected).alive_fly_indices);

% Arrange the output matrix to contain sleep lost, sleep rebound, and sleep
% recovered
outputdata_mat = [frac_sleep_lost,frac_sleep_rebound,frac_sleep_recovered];

% Remove dead fly rows
outputdata_mat(dead_flies,:) = NaN;

% Prime the output cell
SD_output_cell = cell(n_flies+1,4);

% Titles in the first row
SD_output_cell(1,:) = {'geno','fraction of sleep lost','fraction of sleep rebound','fraction of sleep recovered'};

% Copy the genotypes to the first column (except for title)
SD_output_cell(2:end,1) = {master_data_struct(id_selected).genotype};

% Re-format the data to cell.
SD_output_cell(2:end,2:end) = num2cell(outputdata_mat);

% Output the data to csv
cell2csv(fullfile(export_path,['SD_',filename_master(1:end-5),'_'...
    master_data_struct(id_selected).genotype,'_sleep_deprive_data.csv']),SD_output_cell);
