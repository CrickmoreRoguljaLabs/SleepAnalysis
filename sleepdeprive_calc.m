%% Load data and date selection

% Enter the number of hours used to calculate rebound
num_of_hours_for_rebound = 6;

keep master_data_struct start_date end_date genos n_genos n_days export_path

sleepdeprive_ui

uiwait(gcf)

day2sleepdep = datenum(SDdate) - datenum(start_date) + 1;

if day2sleepdep == 1 || day2sleepdep == n_days
    disp('Please do not select the first day of data collection')
    return
end

% Calculate the index for when the sleep deprivation starts
SD_start_ind = (day2sleepdep - 1) * 288 + SDhour1 * 12 + SDmin1/5 + 1;

% Calculate the index for when the sleep deprivation stops
SD_end_ind = (day2sleepdep - 1) * 288 + SDhour2 * 12 + SDmin2/5;

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

% Detect if the sleep deprivation happens over 2 dates (passing midnight).
% If so, add another day to the end date.
if SD_end_ind < SD_start_ind
    SD_end_ind = SD_end_ind + 288;
end

%% Genotype selection and data extraction
disp('Please enter the ID number of the genotype to be analyzed')

ID = (1:n_genos)';

table(ID,genos)

id_selected = input('ID number=');

if id_selected > n_genos
    disp('ID number out of range!')
    return
end

SD_sleep_data = master_data_struct(id_selected).data...
    (SD_start_ind:SD_end_ind) == 0;

RB_sleep_data = master_data_struct(id_selected).data...
    (RB_start_ind:RB_end_ind) == 0;

CT_sleep_data = master_data_struct(id_selected).data...
    (CT_start_ind:CT_end_ind) == 0;

CTRB_sleep_data = master_data_struct(id_selected).data...
    (CTRB_start_ind:CTRB_end_ind) == 0;

frac_sleep_lost = (CT_sleep_data - SD_sleep_data) / CT_sleep_data;

frac_sleep_rebound = (RB_sleep_data - RBCT_sleep_data) / RBCT_sleep_data;

frac_sleep_regained = (RB_sleep_data - RBCT_sleep_data) / (CT_sleep_data - SD_sleep_data);

%% Output results

SD_output_cell = cell(1,13);