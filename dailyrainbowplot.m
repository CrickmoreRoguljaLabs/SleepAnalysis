function [ flag ] = dailyrainbowplot( ~ )
%DAILYRAINBOWPLOT Creates a daily rainbow plot using the input data
%   No input variable

% Select the input data file (csv for now)
[filename, pathname] = uigetfile('C:\Users\Stephen Zhang\Documents\MATLAB\Analyzed Data\*.csv'); % This address should be changed according to the user
imported_data=importdata(fullfile(pathname,filename));

% Read the genotypes and determine the number
genos=unique(imported_data.textdata(1,:),'stable')';
n_genos=size(genos,1);

% Determine the number of bins
n_bins = (size(imported_data.data,1) - 1 )/2;

% Prime the rainbow matricies
rainbow_mat=zeros(n_bins,n_genos);
rainbow_mat_sem=zeros(n_bins,n_genos);

% Reverse engineer the total data from data, n and SEM
for i=1:n_genos
    % Find which columns of the input file contains the genotype
    genoindex = strcmp(imported_data.textdata(1,:),genos{i});
    
    % Read the data
    tempdata = imported_data.data(:,genoindex);
    
    % Convert the averages to sums and sem to std
    tempdata(2:49,:) = tempdata(2:(n_bins+1),:).*repmat(tempdata(1,:),[n_bins,1]);
    tempdata(50:97,:) = tempdata((n_bins+2):end,:).*sqrt(repmat(tempdata(1,:),[n_bins,1]));
    
    % Create the new average and SEM
    rainbow_mat(:,i) = sum(tempdata(2:(n_bins+1),:),2)/sum(tempdata(1,:));
    rainbow_mat_sem(:,i) = sqrt(sum(tempdata((n_bins+2):end,:).^2,2))/sqrt(sum(tempdata(1,:)));
end

% Create the daily rainbox plots
plotsizevec=[50,50,1200,600];%This size vector can be changed by the user to customize the plot size. Format ([X_position, Y_position, Width, Height]).
panels2print = min(ceil(n_bins/48),9);
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
        axis([1,49,0,30])
        set(gca,'XTick',1:8:49);
        rainbow_tape_xlabel_cell = {'8','12','16','20','24','4','8'};
        set(gca,'XTickLabel',rainbow_tape_xlabel_cell)
        if k==n_days
            legend(genos,'Location', 'SouthEast')
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
    export_fig(fullfile(pathname,[filename(1:end-4),'_dailyrainbow.fig']));
    flag=fullfile(pathname,[filename(1:end-4),'_dailyrainbow.fig']);
    close(102)
end

end

