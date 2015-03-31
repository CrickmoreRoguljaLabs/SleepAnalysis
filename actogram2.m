% Generate actogram from .txt monitor data
% Written by Stephen Zhang 2014-5-14

% Note: Totals for sleep bout number/length and activities assume that the
% number of day and night periods are equal. If that's not true, they'll
% end up priviledging whichever period is more numerous (i.e. if a run goes
% from 8 am to 8 pm rather than 8 am to 8 am, the bout
% length/number/activities from the day will have greater weight in the
% averaging and the total won't actually be reflective of the overall
% activity of the fly). But as long as things run for at least 24 hrs we'll
% be good!

%% Batch processing initiation
if exist('master_mode','var')==0
    master_mode=0;
end

%% Import initial data
% Get the file and start the drama
if master_mode==0
    settings_file = importdata('actogram2_settings.xlsx');
    monitor_dir = settings_file{1};
    monitor_dir = monitor_dir(strfind(monitor_dir, ',')+1:end);
    export_path = settings_file{2};
    export_path = export_path(strfind(export_path, ',')+1:end);
    [filename, pathname] = uigetfile(monitor_dir);
end


% Master data structure file, separated into textdata and data
monitor_data=importdata(fullfile(pathname,filename));

%% Separate data into desired days/times

% Find indices for dates to include
start_idx = find(strcmp(monitor_data.textdata(:,2), start_date));
end_idx = find(strcmp(monitor_data.textdata(:,2), end_date));

date_indices = start_idx(1):end_idx(end);

% Delete the unwanted days
monitor_data.data = monitor_data.data(date_indices,:);
monitor_data.textdata = monitor_data.textdata(date_indices,:);

% Select start time
start_time = '08:00:00';%input('Enter start time: (e.g. 08:00:00): ', 's');
end_time = '07:59:00';

% Edit file to start at that point
start_index = find(strcmp(monitor_data.textdata(:,3),start_time)...
    & strcmp(monitor_data.textdata(:,2),start_date));
end_index = find(strcmp(monitor_data.textdata(:,3),end_time)...
    & strcmp(monitor_data.textdata(:,2),end_date));

monitor_data.data = monitor_data.data(start_index:end_index,:);
monitor_data.textdata = monitor_data.textdata(start_index:end_index,:);



%% Extract bin information

% Use two time points to determine whether the inter-recording inverval is 0.5 or 1 min
interval=round((datenum(monitor_data.textdata{20,3})-datenum(monitor_data.textdata{19,3}))/3.472222015261650e-04)/2;

% If there's no start time, use the first time point to determine what time of the day the trial
% started
first_time_hr = str2double(start_time(1:2)); %(datenum(monitor_data.textdata{1,3})-735600)/6.9444e-04

first_time = first_time_hr * 60;

% Use the period to determine how many points should be binned
points_per_bin=round(5/interval);

% Obtain the actogram data
pared_data=monitor_data.data(:,end-31:end);

% Determine how many bins there will be
n_bins=ceil(size(pared_data,1)/points_per_bin);

% Determine how many points will be in the last bin
mod_bins=mod(size(pared_data,1),points_per_bin);
if mod_bins==0;
    mod_bins=points_per_bin;
end

% Prime the binned data matrix
binned_data=zeros(n_bins,32);

% Bin the data. Calculate the last bin separately
for i=1:n_bins-1
    binned_data(i,:)=sum(pared_data((i-1)*points_per_bin+1:i*points_per_bin,:));
end
binned_data(n_bins,:)=sum(pared_data((n_bins-1)*points_per_bin+1:(n_bins-1)*points_per_bin+mod_bins,:));

%% Separate data by days
% Determine how many bins will be on the first day
n_bins_first_day=round((1920-first_time)/points_per_bin/interval);

% Determine how many days there will be
n_days=ceil((n_bins-n_bins_first_day)/288)+1;

% Set the bounds, in terms of bins, for each day's data
mat_bounds=zeros(n_days,2);
mat_bounds(1,1)=1;
mat_bounds(1,2)=n_bins_first_day;

% If there is more than 1 day worth of data
    for i=2:n_days-1
        mat_bounds(i,1)=mat_bounds(i-1,2)+1;
        mat_bounds(i,2)=mat_bounds(i-1,2)+288;
    end
if n_days>1
    mat_bounds(n_days,1)=mat_bounds(n_days-1,2)+1;
    mat_bounds(n_days,2)=n_bins;
end

% Calculate the bounds, in terms of time stamps, for each day's data
time_bounds=zeros(n_days,2);
time_bounds(1,1)=first_time_hr;
time_bounds(1,2)=32;
time_bounds(2:end,1)=8;
time_bounds(2:end-1,2)=32;
time_bounds(end,2)=5/60+8+(mat_bounds(n_days,2)-mat_bounds(n_days,1))*5/60;

%% Plotting data
if master_mode==0
    % The plot will be in 2 x 4 format
    subplot_plan=[2,4];
    panels_per_page=subplot_plan(1)*subplot_plan(2);
    % A placeholder variable for how many panels have been plotted
    panels_done=0;

    % k is the index number for pages
    for k=1:ceil((32/panels_per_page))
        % Set figure size
        figure(101)
        set(gcf,'Position',[0 0 1000 691])

        % j is the index number for panels
        for j=1:min(panels_per_page,32-panels_done)
            subplot(subplot_plan(1),subplot_plan(2),j);
            hold on

            % i is the index number for days
            for i=1:n_days
                bbar=bar(time_bounds(i,1):5/60:time_bounds(i,1)+(mat_bounds(i,2)-mat_bounds(i,1))*5/60,... % A weird way to determine what the actual x-values are for each point
                    binned_data(mat_bounds(i,1):mat_bounds(i,2),j+panels_done)... % The actual y-values for each point
                    /100/n_days+(n_days-i)/n_days); % Normalize against 100 and divide each panel into days
                line([8,32],[(n_days-i)/n_days,(n_days-i)/n_days],'Color',[0 0 0]); % This is a line per request of Michelle
                set(bbar,'EdgeColor',[0 0 0]) % Set the bar edge color to black. One vote for purple [153/255 102/255 204/255] from Stephen. RIP teal (2014-2014): [0 128/255 128/255].
                set(bbar,'FaceColor',[0 0 0]) % Set the bar face color to black. One vote for purple from Stephen. RIP teal (2014-2014).
                set(bbar,'BaseValue',(n_days-i)/n_days); % Elevate the bars to restrict them to their own little sub-panels
            end

            % Make the figure readable
            xlim([8,32]);
            ylim([0,1]);

            % Set X labels
            set(gca,'XTick',[8 12 16 20 24 28 32]);
            set(gca,'xticklabel',[8 12 16 20 24 4 8]);
            set(gca,'yticklabel',[]);

            % Draw a box and put on the titles
            box on
            title([monitor_data.textdata{1,2},' ',filename(1:end-4) ,' Channel ',num2str(j+panels_done)])
            hold off
        end

        % Make figures look tighter
        tightfig;

        % Resize the figures to fit on a piece of paper better (could be improved)
        set(gcf,'Position',[0 0 1400 1000],'Color',[1 1 1])

        % Export and append the pdf files
        if PC_or_not
            export_fig(fullfile(export_path,[filename(1:end-4),'_actogram.pdf']),'-append');
        else
            saveas(gcf,fullfile(export_path,[filename(1:end-4),'_actogram_', num2str(k), '.pdf']));
        end
        close 101
        panels_done=panels_done+panels_per_page;
    end
end
%% Sleep data

% Binarize binned data so that one bin of no movement counts as 5 min of
% sleep
sleep_mat = binned_data==0;

% Sleep bound calculation. ASSUME DATA STARTS AT 8 AND ENDS AT 20 OR 8.
% determine the number of sleep bounds (i.e. num day/night periods [so 2x the number of days])
n_sleep_bounds = floor(n_bins/144);

% Determine the sleep bounds
sleep_bounds = zeros(n_sleep_bounds,2);
sleep_bounds(:,2) = (1 : n_sleep_bounds) * 144;
sleep_bounds(:,1) = (1 : n_sleep_bounds) * 144 - 143;

% Calculate the sleep results accordingly
sleep_results=zeros(size(sleep_bounds,1),32);
for i=1:n_sleep_bounds
    sleep_results(i,:)=(sum(sleep_mat(sleep_bounds(i,1):sleep_bounds(i,2),:)))*5;
end

% Calculate the dead flies
dead_fly_vector=(sleep_results(end-1,:)+sleep_results(end,:))==1440;
dead_fly_vector=dead_fly_vector';

% Comment something here so it looks green
sleep_results=sleep_results';
avg_sleep_results=zeros(32,3);
avg_sleep_results(:,2)=mean(sleep_results(:,1:2:n_sleep_bounds),2);
avg_sleep_results(:,3)=mean(sleep_results(:,2:2:n_sleep_bounds),2);
avg_sleep_results(:,1)=avg_sleep_results(:,2)+avg_sleep_results(:,3);
avg_sleep_results(dead_fly_vector,:)=NaN;
% xlswrite(fullfile(export_path,[filename(1:end-4),'_sleep_results.xls']),avg_sleep_results);

%% Sleep bout and activity calculations
% Initialize the matrices to store sleep bout numbers, lengths and activities
sleep_bout_num=zeros(n_sleep_bounds,32);
sleep_bout_length=zeros(n_sleep_bounds,32);
activity_mat=zeros(n_sleep_bounds,32);
delay_mat=zeros(floor(n_sleep_bounds/2),32);

% For each fly loaded, do the following...
for i=1:32
    for j=1:n_sleep_bounds
        % Grab the sleep binary vector for that fly
        tempsleepvec=sleep_mat(sleep_bounds(j,1):sleep_bounds(j,2),i);
        
        % Grab the activity vector for that fly
        tempactivityvec=binned_data(sleep_bounds(j,1):sleep_bounds(j,2),i);
        
        % Use the function "chainfinder" to find sleep bouts
        % See the function description for the explanation of the function output
        tempsleepchainmat=chainfinder(tempsleepvec);
        
        % Use the sleepchain matrix to determine the sleep delay
        % If never slept, delay is not taken into account
        if ~isempty(tempsleepchainmat)
            if mod(j,2)==0
                delay_mat(j/2,i)=tempsleepchainmat(1);
            end
        else
            if mod(j,2)==0
                delay_mat(j/2,i)=NaN;
            end
        end
        
        % Obtain the number of bouts from the chainfinder results
        sleep_bout_num(j,i)=size(tempsleepchainmat,1);
        
        % If chainfinder finds no chains, the sleep bout length is 0,
        % otherwise calculate the mean bout length
        if ~isempty(tempsleepchainmat)
            sleep_bout_length(j,i)=mean(tempsleepchainmat(:,2))*5;
        else
            sleep_bout_length(j,i)=0;
        end
        
        % Calculate the average walking activity for that fly from the
        % activity vector
        activity_mat(j,i)=mean(tempactivityvec(tempsleepvec==0));
    end
end

% Output the sleep bout numbers, lengths and activities to xls
% disp('Sleep bout numbers:')
sleep_bout_num=sleep_bout_num';
avg_sleep_bout_num=zeros(32,3);
avg_sleep_bout_num(:,1)=mean(sleep_bout_num(:,1:2:n_sleep_bounds),2); %Day
avg_sleep_bout_num(:,2)=mean(sleep_bout_num(:,2:2:n_sleep_bounds),2); %Night
avg_sleep_bout_num(:,3)= avg_sleep_bout_num(:,1) + avg_sleep_bout_num(:,2); %Total
avg_sleep_bout_num(dead_fly_vector,:)=NaN;
% xlswrite(fullfile(export_path,[filename(1:end-4),'_sleep_bout_numbers.xls']),avg_sleep_bout_num);

% disp('Sleep bout lengths:')
sleep_bout_length=sleep_bout_length';
avg_sleep_bout_length=zeros(32,3);
avg_sleep_bout_length(:,1)=mean(sleep_bout_length(:,1:2:n_sleep_bounds),2); %Day
avg_sleep_bout_length(:,2)=mean(sleep_bout_length(:,2:2:n_sleep_bounds),2); %Night
avg_sleep_bout_length(:,3)= mean(avg_sleep_bout_length(:,1:2),2); %Total
avg_sleep_bout_length(dead_fly_vector,:)=NaN;
% xlswrite(fullfile(export_path,[filename(1:end-4),'_sleep_bout_lengths.xls']),avg_sleep_bout_length);

% disp('Activities')
activity_mat=activity_mat'/5;
avg_activity_mat=zeros(32,3);
avg_activity_mat(:,1)=mean(activity_mat(:,1:2:n_sleep_bounds),2); %Day
avg_activity_mat(:,2)=mean(activity_mat(:,2:2:n_sleep_bounds),2); %Night
avg_activity_mat(:,3)= mean(avg_activity_mat(:,1:2),2); %Total
avg_activity_mat(dead_fly_vector,:)=NaN;
% xlswrite(fullfile(export_path,[filename(1:end-4),'_activities.xls']),avg_activity_mat);

% disp('Delays')
avg_delay_mat=(5*mean(delay_mat-1,1))';
avg_delay_mat(dead_fly_vector,:)=NaN;


% Construct a single output cell for the current monitor
monitor_output_cell=cell(33,13);
monitor_output_cell(1,:)={'Total sleep','Day sleep','Night sleep','Sleep bout length (day)','Sleep bout length (night)',...
    'Sleep bout length (total)','Sleep bout number (day)','Sleep bout number (night)',...
    'Sleep bout number (total)', 'Day activity','Night activity', 'Total activity', 'Sleep delay'};
monitor_output_cell(2:33,:)=num2cell([avg_sleep_results,avg_sleep_bout_length,avg_sleep_bout_num,avg_activity_mat,avg_delay_mat]);

% Output the cell to a csv file
%cell2csv(fullfile(export_path,[filename(1:end-4),'_monitor_data.csv']),monitor_output_cell);


% Output the workspace (comment out if necessary)
%
if master_mode==0
    save(fullfile(export_path,[filename(1:end-4),'_workspace.mat']));
end
%}

%% Consolidating data to the master data file
if master_mode==1
    % Start with the first genotype in the monitor
    for jj=1:n_genos_of_current_monitor
        % Read the current genotype
        current_geno=master_direction.textdata{ii+jj-1,2};
        
        % Obtain the index in the genotype list
        current_geno_index=find(strcmp(genos,current_geno));
        
        % Find the number of flies with the current genotype
        channels_of_current_geno=master_direction.textdata{ii+jj-1,3};
        
        % Calculate the number of dead flies
        n_dead_flies=sum(dead_fly_vector(channels_of_current_geno));
        
        % Write the actogram data to the master structure
        master_data_struct(current_geno_index).data=[master_data_struct(current_geno_index).data,binned_data(:,channels_of_current_geno)];
        
        % Write the sleep lengths to the mastere structure
        master_data_struct(current_geno_index).sleep=[master_data_struct(current_geno_index).sleep;avg_sleep_results(channels_of_current_geno,:)];
        
        % Write the sleep bout lengths to te master structure
        master_data_struct(current_geno_index).sleep_bout_lengths=[master_data_struct(current_geno_index).sleep_bout_lengths;avg_sleep_bout_length(channels_of_current_geno,:)];
        
        % Write the sleep bout numbers to the master structure
        master_data_struct(current_geno_index).sleep_bout_numbers=[master_data_struct(current_geno_index).sleep_bout_numbers;avg_sleep_bout_num(channels_of_current_geno,:)];
        
        % Write the activities to the master structure
        master_data_struct(current_geno_index).activities=[master_data_struct(current_geno_index).activities;avg_activity_mat(channels_of_current_geno,:)];
        
        % Write the delays to the master structure
        master_data_struct(current_geno_index).delays=[master_data_struct(current_geno_index).delays;avg_delay_mat(channels_of_current_geno,:)];
        
        % Add the number of alive flies in the master structure
        master_data_struct(current_geno_index).num_alive_flies=master_data_struct(current_geno_index).num_alive_flies+length(channels_of_current_geno)-n_dead_flies;
        
        % Write the dead fly indices to the master structure
        master_data_struct(current_geno_index).alive_fly_indices=[master_data_struct(current_geno_index).alive_fly_indices;~dead_fly_vector(channels_of_current_geno)==1];
        
        % Write the number of processed flies to the master structure
        master_data_struct(current_geno_index).num_processed_flies=master_data_struct(current_geno_index).num_processed_flies+length(channels_of_current_geno);

    end

    
end