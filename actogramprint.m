function [  ] = actogramprint( data2print, time_bounds, mat_bounds , n_days, export_path, filename, title_name, PC_or_not)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% The plot will be in 2 x 4 format
subplot_plan=[2,4];
panels_per_page=subplot_plan(1)*subplot_plan(2);
% A placeholder variable for how many panels have been plotted
panels_done=0;

% k is the index number for pages
for k=1:ceil((size(data2print,2)/panels_per_page))
    % Set figure size
    figure(101)
    set(gcf,'Position',[0 0 1000 691])

    % j is the index number for panels
    for j=1:min(panels_per_page,size(data2print,2)-panels_done)
        subplot(subplot_plan(1),subplot_plan(2),j);
        hold on

        % i is the index number for days
        for i=1:n_days
            bbar=bar(time_bounds(i,1):5/60:time_bounds(i,1)+(mat_bounds(i,2)-mat_bounds(i,1))*5/60,... % A weird way to determine what the actual x-values are for each point
                data2print(mat_bounds(i,1):mat_bounds(i,2),j+panels_done)... % The actual y-values for each point
                /100/n_days+(n_days-i)/n_days); % Normalize against 100 and divide each panel into days
            line([8,32],[(n_days-i)/n_days,(n_days-i)/n_days],'Color',[0 0 0]); % This is a line per request of Michelle
            set(bbar,'EdgeColor',[0 0 0]) % Set the bar edge color to black. One vote for purple [153/255 102/255 204/255] from Stephen. RIP teal (2014-2014): [0 128/255 128/255].
            set(bbar,'FaceColor',[0 0 0]) % Set the bar face color to black. One vote for purple from Stephen. RIP teal (2014-2014): [0 128/255 128/255].
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
        title(title_name)
        hold off
    end

    % Make figures look tighter
    if min(panels_per_page,size(data2print,2)-panels_done)>4
        tightfig;
    end

    % Resize the figures to fit on a piece of paper better (could be improved)
    set(gcf,'Position',[0 0 1400 1000],'Color',[1 1 1])

    % Export and append the pdf files
    if PC_or_not
        export_fig(fullfile(export_path,[filename,'_actogram.pdf']),'-append');
    else
        saveas(gcf,fullfile(export_path,[filename(1:end-4),'_actogram_', num2str(k), '.pdf']));
    end
    close 101
    panels_done=panels_done+panels_per_page;
end

end

