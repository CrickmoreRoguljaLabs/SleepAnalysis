function sleepextract
%sleepextract uses gui to determine which data to extract and extracts it
%from the workspace file. Written by Stephen Zhang, Dec 2014. Reworked to
%support the moving-average sleep analysis on 5/9/2016.
% This program currently assumes the sleep data are collected in 1-min bins.

% Read the setting file
settings_file = importdata('actogram2_settings.csv');
export_path = settings_file{2};
export_path = export_path(strfind(export_path, ',')+1:end);

% Hard code the interval as 1 min for now
interval = 1;

% Use UI to get the expt .mat files
[filename_expt,extractpath] = uigetfile([export_path,'\*.mat'],'Experimental file');

% Load the variables needed from the expt .mat file. Only
% 'master_data_struct' and 'genos' are currently used for now. Loaded
% others for the purpose of future expansions.
load(fullfile(extractpath,filename_expt),'master_data_struct',...
    'start_date','end_date','genos','n_genos','n_sleep_bounds','filename_master');

% Which kinds of data types can be extracted right now
datatypes = {'activity data (1 min)','sleep data (1 min)',...
    'activity data (5 min)','sleep data (5 min)',...
    'rainbow data (30min)'};

% Make the main figure
hfig = figure('position',[500,400,330,60]);

% Prime the guidata to store the user's choice
guidata(hfig,struct('genoselected',1,'datatypeselected',1));

% Make texts on the gui
h1 = uicontrol('Parent',hfig,'Style', 'text', 'Position', [10 36 80 22]);
set(h1,'string','Genotype:','FontSize',11)

h2 = uicontrol('Parent',hfig,'Style', 'text', 'Position', [10 7 80 22]);
set(h2,'string','Data type:','FontSize',11)

% Create pop-up menus for users to select
% Select genotype
uicontrol('Parent',hfig,...
    'Style', 'popup',...
    'String', genos,...
    'Position', [95 41 120 18],...
    'FontSize',10,...
    'Callback', @setgeno);

% Select data type
uicontrol('Parent',hfig,...
    'Style', 'popup',...
    'String', datatypes,...
    'Position', [95 12 120 18],...
    'FontSize',10,...
     'Callback', @setdatatype);
   
% Pushbutton for viewing the data table
uicontrol('Parent',hfig,...
    'Style', 'pushbutton',...
    'FontSize',11,...
    'String','View Data',...
    'Position', [220 33 100 26],...
    'Callback',@viewdata);

% Pushbutton for copying the data table (to excel)
uicontrol('Parent',hfig,...
    'Style', 'pushbutton',...
    'FontSize',11,...
    'String','Copy Data',...
    'Position', [220 4 100 26],...
    'Callback',@copydata);
   
    % Function when a genotype is selected
    function setgeno(hObject,~)
        choicedata = guidata(hObject);
        choicedata.genoselected = get(hObject,'Value');
        guidata(hObject, choicedata);
    end
   
    % Function when a data type is selected
    function setdatatype(hObject,~)
        choicedata = guidata(hObject);
        choicedata.datatypeselected = get(hObject,'Value');
        guidata(hObject, choicedata);
    end
    
    % Function to allow viewing data table
    function viewdata(hObject,~)
        % Dump out the choice data
        choicedata = guidata(hObject);
        datatypeselected = choicedata.datatypeselected;
        genoselected = choicedata.genoselected;
        
        % Based on what user selects as the datatype, calculate the
        % corresponding output data files.
        switch datatypeselected
            case 1
                outputdata = getrawdata(master_data_struct,genoselected);
            case 2
                outputdata = get1minsleep(master_data_struct,genoselected);
            case 3
                outputdata = get5minactivity(master_data_struct,genoselected);
            case 4
                outputdata = get5minsleep(master_data_struct,genoselected);
            case 5
                outputdata = getrainbow(master_data_struct,genoselected);
        end
        
        % Suppress dead fly data
        outputdata(:,~master_data_struct(genoselected).alive_fly_indices) = NaN;
        
        % Make a data table
        datatable = figure('Position',[100 100 1000 500]);
        uitable('Parent', datatable, 'Position', [20 20 960 460],'Data',outputdata);
    end
    
    % Copy the data to clipboard
    function copydata(hObject,~)
        % Dump out the choice data
        choicedata = guidata(hObject);
        datatypeselected = choicedata.datatypeselected;
        genoselected = choicedata.genoselected;
        
        % Based on what user selects as the datatype, calculate the
        % corresponding output data files.
        switch datatypeselected
            case 1
                outputdata = getrawdata(master_data_struct,genoselected);
            case 2
                outputdata = get1minsleep(master_data_struct,genoselected);
            case 3
                outputdata = get5minactivity(master_data_struct,genoselected);
            case 4
                outputdata = get5minsleep(master_data_struct,genoselected);
            case 5
                outputdata = getrainbow(master_data_struct,genoselected);
        end
        
        % Suppress dead fly data
        outputdata(:,~master_data_struct(genoselected).alive_fly_indices) = NaN;
        
        % Copy the data to clip board
        mat2clip(outputdata)
    end

    % Extract raw actiity data (in 1-min bins). Each column is a different
    % fly. Each row is the number of beam crossing in 1 min, hence 1440 rows
    % per day.
    function outputdata = getrawdata(master_data_struct,genoselected)
        outputdata = master_data_struct(genoselected).data;
    end

    % Extract activity data (in 5-min bins). Each column is a different
    % fly. Each row is the number of min's of sleep in that 5-min bin,
    % hence 288 rows per day.
    function outputdata = get5minactivity(master_data_struct,genoselected)
        % Use the getrawdata function to obtain 1-min sleep data
        activitydata = getrawdata(master_data_struct,genoselected);
        
        % Get the number of 1-min bins
        n_bins = size(activitydata,1);
        
        % Get the number of flies;
        n_flies = size(activitydata,2);
        
        % Calculate the 30-min sleep data
        activitydata5 = sum(reshape(activitydata,...
            [5/interval, n_bins/(5/interval), n_flies]),1);
        
        % squeeze the data
        outputdata = squeeze(activitydata5);
    end

    % Extract sleep data (in 1-min bins). Each column is a different fly.
    % Each row is the min's that the fly sleeps in 1 min, hence 1440 rows
    % per day.
    function outputdata = get1minsleep(master_data_struct,genoselected)
        outputdata = master_data_struct(genoselected).sleep_data;
    end

    % Extract sleep data (in 5-min bins). Each column is a different
    % fly. Each row is the number of min's of sleep in that 5-min bin,
    % hence 288 rows per day.
    function outputdata = get5minsleep(master_data_struct,genoselected)
        % Use the get1minsleep function to obtain 1-min sleep data
        sleepdata = get1minsleep(master_data_struct,genoselected);
        
        % Get the number of 1-min bins
        n_bins = size(sleepdata,1);
        
        % Get the number of flies;
        n_flies = size(sleepdata,2);
        
        % Calculate the 30-min sleep data
        sleepdata5 = sum(reshape(sleepdata,...
            [5/interval, n_bins/(5/interval), n_flies]),1);
        
        % squeeze the data
        outputdata = squeeze(sleepdata5);
    end

    % Extract rainbow data (in 30-min bins). Each column is a different
    % fly. Each row is the number of min's of sleep in that 30-min bin,
    % hence 48 rows per day.
    function outputdata = getrainbow(master_data_struct,genoselected)
        % Use the get1minsleep function to obtain 1-min sleep data
        sleepdata = get1minsleep(master_data_struct,genoselected);
        
        % Get the number of 1-min bins
        n_bins = size(sleepdata,1);
        
        % Get the number of flies;
        n_flies = size(sleepdata,2);
        
        % Calculate the 30-min sleep data
        sleepdata30 = sum(reshape(sleepdata,...
            [30/interval, n_bins/(30/interval), n_flies]),1);
        
        % squeeze the data
        outputdata = squeeze(sleepdata30);
    end
   
end

