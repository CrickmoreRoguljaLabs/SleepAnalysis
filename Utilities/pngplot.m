function [ fileoutput ] = pngplot( alltraces,  subplot_plan, filename, spikecell, dir, tdtpositives)
%pngplot Plot a n trial * x data points plot with a specified subplot plan
%and predetermined episodes
%   Inputs:
%   alltraces       An n by x matrix, where n is the number of trials and x
%                   is the number of data points
%   subplot_plan    A 3 by 1 vector with the entries [total number of
%                   subplots, number of rows, number of columns]
%   timelines       A vector that specifies where timelines should be drawn
%                   This should include the last frame in addition to the
%                   frame numbers in the middle
%   filename        A string specifying the file name
%   dir             A string specifying the directory
%
%   Output:
%   fileoutput      A string specifying the output file (including dir)

if nargin<7
    markpos=0;
else
    if sum(tdtpositives)>0
        markpos=1;
    else
        markpos=0;
    end
end


if nargin<6
    dir='';
end

if nargin<5
    plotspikes=0;
else
    plotspikes=1;
end

npages=ceil(size(alltraces,1)/subplot_plan(1));
plots_left=size(alltraces,1);
nvids2=1;

for pagenum=1:npages
    figure(101)
    set(gcf,'Position',[0 0 1000 691])
    for subplot_num=1:min(subplot_plan(1),plots_left)
        subplot(subplot_plan(2),subplot_plan(3),subplot_num)
        index=(pagenum-1)*subplot_plan(1)+subplot_num;
        plot(alltraces(index,:),'-')
        yrange=get(gca,'ylim');
        hold on
        text(100,yrange(2)*0.8,['Cell ',num2str(index)])
        if markpos>0
            text(300,yrange(2)*0.8,['RFP:',num2str(tdtpositives(index))])
        end
        if plotspikes>0
            scatter(spikecell{index},0.8*yrange(2)*(spikecell{index}>-9999),'r.')
        end
        for i=1:nvids2-1
            plot([timelines(i),timelines(i)],yrange,'g')
        end
        hold off
        ylabel('Fluorescence')
        if subplot_num==min(subplot_plan(1),plots_left)
            xlabel('frames')
        end
    end
    tightfig;
    fileoutput=[dir,filename,'_',num2str(pagenum)];
    set(gcf,'Position',[0 0 1000 1000],'Color',[1 1 1])
    plots_left=plots_left-subplot_plan(1);
    saveas(101, fileoutput, 'png');
    close(101)
end

end

