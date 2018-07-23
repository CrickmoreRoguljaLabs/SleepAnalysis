function [  ] = actogramprint( data2print, time_bounds, mat_bounds , n_days, export_path, filename, title_name, PC_or_not)
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
        set(gca,'YTickLabel','')
        set(gca,'XTickLabel','')
        hold on
        clear ax
        % i is the index number for days
        for i=1:n_days
            
            ax(i) = axes; %#ok<AGROW>
            subplot(subplot_plan(1),subplot_plan(2),j,ax(i));
            
            % Set the X range right
            set(ax(i),'XLim',[8 32]);
                        
            bbar=bar(ax(i),time_bounds(i,1):5/60:time_bounds(i,1)+(mat_bounds(i,2)-mat_bounds(i,1))*5/60,... % A weird way to determine what the actual x-values are for each point
                data2print(mat_bounds(i,1):mat_bounds(i,2),j+panels_done)... % The actual y-values for each point
                /100/n_days+(n_days-i)/n_days); % Normalize against 100 and divide each panel into days
%             line([8,32],[(n_days-i)/n_days,(n_days-i)/n_days],'Color',[0 0 0]); % This is a line per request of Michelle
            set(bbar,'EdgeColor',[0 0 0]) % Set the bar edge color to black. One vote for purple [153/255 102/255 204/255] from Stephen. RIP teal (2014-2014): [0 128/255 128/255].
            set(bbar,'FaceColor',[0 0 0]) % Set the bar face color to black. One vote for purple from Stephen. RIP teal (2014-2014): [0 128/255 128/255].
            set(bbar,'BaseValue',(n_days-i)/n_days); % Elevate the bars to restrict them to their own little sub-panels
            
            % Set the X label right
            set(ax(i),'XTick',[8 14 20 26 32]);
            set(ax(i),'XTickLabel',{'8','14','20','2','8'});
            
            % Remove Y labels
            set(ax(i),'YTickLabel','');
            
            if i > 1
                axis off 
            end
        end
        hold off
        
        % Make the figure readable
        
        linkaxes(ax)
        set(ax,'YLim',[0,1]);
        
        

        % Draw a box and put on the titles
        box on
        title(title_name)
        
    end


    % Export and append the pdf files
    if PC_or_not
        export_fig(fullfile(export_path,[filename,'_actogram.pdf']),'-append');
    else
        saveas(gcf,fullfile(export_path,[filename,'_actogram_', num2str(k), '.pdf']));
    end
    close 101
    panels_done=panels_done+panels_per_page;
end

end

