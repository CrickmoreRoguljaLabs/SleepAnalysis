function [ flag ] = rainbowplot( ~ )
%RAINBOWPLOT Creates a rainbow plot using the input data
%   No input variable

% Select the input data file (csv for now)
[filename, pathname] = uigetfile('D:\Projects\Gal4-Screen\*.csv'); % This address should be changed according to the user
imported_data=importdata(fullfile(pathname,filename));

% Read the genotypes and determine the number
genos=unique(imported_data.textdata(1,:),'stable')';
n_genos=size(genos,1);

% Prime the rainbow matricies
rainbow_mat=zeros(48,n_genos);
rainbow_mat_sem=zeros(48,n_genos);

% Reverse engineer the total data from data, n and SEM
for i=1:n_genos
    % Find which columns of the input file contains the genotype
    genoindex=strcmp(imported_data.textdata(1,:),genos{i});
    
    % Read the data
    tempdata=imported_data.data(:,genoindex);
    
    % Convert the averages to sums and sem to std
    tempdata(2:49,:)=tempdata(2:49,:).*repmat(tempdata(1,:),[48,1]);
    tempdata(50:97,:)=tempdata(50:97,:).*sqrt(repmat(tempdata(1,:),[48,1]));
    
    % Create the new average and SEM
    rainbow_mat(:,i)=sum(tempdata(2:49,:),2)/sum(tempdata(1,:));
    rainbow_mat_sem(:,i)=sqrt(sum(tempdata(50:97,:).^2,2))/sqrt(sum(tempdata(1,:)));
end

% Create the rainbox plots
errorbar(rainbow_mat,rainbow_mat_sem,'-o','LineWidth',1.5);
axis([1,49,0,30])
set(gca,'XTick',1:8:49)
set(gca,'XTickLabel',{'8','12','16','20','24','4','8'})
legend(genos,'Location', 'SouthEast')
xlabel('Time')
ylabel('sleep per 30 min (min)')
set(gcf,'Color',[1,1,1])

% Save the fig and the data
% saveas(gcf,fullfile(pathname,[filename(1:end-4),'_rainbow.pdf']));
export_fig(fullfile(pathname,[filename(1:end-4),'_rainbow.pdf']));
% savefig(fullfile(export_path,[filename(1:end-4),'_rainbow.fig']));
flag=fullfile(pathname,[filename(1:end-4),'_rainbow.pdf']);
end

