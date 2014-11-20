function sleepdeprive_ui

% Make main figure
figure('position',[500,400,260,80])

% Make texts
h1 = uicontrol(gcf,'Style', 'text', 'Position', [10 55 130 18]);
set(h1,'string','Sleep Deprive Date:','FontSize',10)

h2 = uicontrol(gcf,'Style', 'text', 'Position', [10 32 130 18]);
set(h2,'string','Sleep Deprive Start:','FontSize',10)

h3 = uicontrol(gcf,'Style', 'text', 'Position', [183 32 5 18]);
set(h3,'string',':','FontSize',10)

h4 = uicontrol(gcf,'Style', 'text', 'Position', [10 9 130 18]);
set(h4,'string','Sleep Deprive End:','FontSize',10)

h5 = uicontrol(gcf,'Style', 'text', 'Position', [183 9 5 18]);
set(h5,'string',':','FontSize',10)

% UI for date selection
hdate = uicontrol(gcf,'Style', 'pushbutton', 'Position', [146 55 110 18]);
set(hdate,'String','Select','FontSize',10,'Callback',@selectdate)

% UI for selecting when sleep deprivation starts
hhour1 = uicontrol(gcf,'Style', 'popupmenu' ,'String',0:23, 'Position', [146 34 35 18]);
hmin1 = uicontrol(gcf,'Style', 'popupmenu' ,'String',0:5:55, 'Position', [190 34 35 18]);

% UI for selecting when sleep deprivation ends
hhour2 = uicontrol(gcf,'Style', 'popupmenu' ,'String',0:23, 'Position', [146 11 35 18]);
hmin2 = uicontrol(gcf,'Style', 'popupmenu' ,'String',0:5:55, 'Position', [190 11 35 18]);

% UI for output data
uicontrol(gcf,'Style', 'pushbutton' ,'String','GO', 'Position', [227 6 30 47],'Callback',@calculatedata);

    % date selection function
    function selectdate(~,~)
        uicalendar('DestinationUI', {hdate, 'String'},'SelectionType',1);
    end
    
    % function for output
    function calculatedata(~,~)
        assignin('base', 'SDhour1', get(hhour1,'Value') - 1);
        assignin('base', 'SDhour2', get(hhour2,'Value') - 1);
        assignin('base', 'SDmin1', (get(hmin1,'Value') - 1) * 5);
        assignin('base', 'SDmin2', (get(hmin2,'Value') - 1) * 5);
        assignin('base', 'SDdate', get(hdate,'String'));
        close gcf
    end
end
<<<<<<< HEAD
=======

%uiwait(gcf)

%keep master_data_struct start_date end_date
>>>>>>> Stephen_dev
