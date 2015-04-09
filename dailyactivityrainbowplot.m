function [ flag ] = dailyactivityrainbowplot( ~ )
%DAILYRAINBOWPLOT Creates a daily rainbow plot using the input data
%   No input variable

%Read the setting file
settings_file = importdata('actogram2_settings.csv');
export_path = settings_file{2};
export_path = export_path(strfind(export_path, ',')+1:end);

% Use UI to get the expt .mat files
[filename,extractpath] = uigetfile([export_path,'\*.mat'],'Select a workspace file');

% Load the variables needed from the expt .mat file. Only
% 'master_data_struct' and 'genos' are currently used for now. Loaded
% others for the purpose of future expansions.
load(fullfile(extractpath,filename),'master_data_struct',...
    'genos','n_genos','n_days','filename_master');

% Select the genotypes to be analyzed
cell2show = cell(n_genos , 2);
cell2show(:,1) = num2cell(1:n_genos);
cell2show(:,2) = genos;

cell2show %#ok<NOPRT>

genos2analyze = input('Please select the genos that you want to analyze (separated by comma)=', 's');

genos2analyze = str2num(genos2analyze); %#ok<ST2NM>

n_genos2analyze = length(genos2analyze);

% Prime the daily rainbow matrices
rainbow_mat = zeros(n_days * 48, n_genos2analyze);

rainbow_mat_sem = rainbow_mat;

% Fill the rainbow matrices with data
for i = 1 : n_genos2analyze
    currentgeno = genos2analyze(i);
    current_rainbow_alive_flies = master_data_struct(currentgeno).alive_fly_indices>0;
    
    % Calculate 5-min bin mean and std. Divide by 5 to calculate per minute
    mean5_bins = mean(master_data_struct(currentgeno).data...
        (:,current_rainbow_alive_flies), 2) / 5;
    std5_bins = std(master_data_struct(currentgeno).data...
        (:,current_rainbow_alive_flies), 1, 2) / 5;
    
    % Calculate 30-min bin mean and sem. Divide by 6 to calculate per
    % minute
    mean30_bins = sum(reshape(mean5_bins,6,[]))' / 6;
    sem30bins = sqrt(sum(reshape(std5_bins,6,[]).^2)') /6....
            /sqrt(master_data_struct(currentgeno).num_alive_flies);
    
    % Put the data in the matrices
    rainbow_mat (:,i) = mean30_bins;
    rainbow_mat_sem (:,i) = sem30bins; 
end

% Create the daily rainbox plots
plotsizevec=[50,50,1200,600];%This size vector can be changed by the user to customize the plot size. Format ([X_position, Y_position, Width, Height]).
panels2print = min(n_days,9);
pages2print = 0;

while panels2print > 0
    figure(102)
    set(102,'Position',plotsizevec);

    % setting the color scheme of the rainbow plot
    set(gcf,'Colormap',cbrewer('seq','PuBuGn',9));
    set(gcf,'DefaultAxesColorOrder',cbrewer('qual','Set2',8))
    set(gcf,'DefaultLineLineWidth',1.2)

    for k=1:n_days
        subplot(3,3,k)
        mseb(1:48,rainbow_mat((k-1)*48+1:(k-1)*48+48,:)',rainbow_mat_sem((k-1)*48+1:(k-1)*48+48,:)');
        %errorbar(rainbow_mat_tape((k-1)*48+1:(k-1)*48+48,:),rainbow_mat_sem_tape((k-1)*48+1:(k-1)*48+48,:),'-o','LineWidth',1.3,'MarkerSize',2)
        axis([1,49,0,4])
        set(gca,'XTick',1:8:49);
        rainbow_tape_xlabel_cell = {'8','12','16','20','24','4','8'};
        set(gca,'XTickLabel',rainbow_tape_xlabel_cell)
        if k==n_days
            legend(genos,'Location', 'SouthEast')
            legend boxoff
        end
        xlabel('Time')
        ylabel('beamcrossing / min')
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
    
    flag = fullfile(export_path,[filename(1:end-4),'_dailyrainbow.fig']);
    
    export_fig(flag);
    
    close(102)
end

end

