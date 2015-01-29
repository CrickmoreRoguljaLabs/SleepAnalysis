function sleepextract
%sleepextract uses gui to determine which data to extract and extracts it
%from the workspace file. Written by Stephen Zhang, Dec 2014.


%Read the setting file
settings_file = importdata('actogram2_settings.csv');
export_path = settings_file{2};
export_path = export_path(strfind(export_path, ',')+1:end);

% Use UI to get the expt .mat files
[filename_expt,extractpath] = uigetfile([export_path,'\*.mat'],'Experimental file');

% Load the variables needed from the expt .mat file. Only
% 'master_data_struct' and 'genos' are currently used for now. Loaded
% others for the purpose of future expansions.
load(fullfile(extractpath,filename_expt),'master_data_struct',...
    'start_date','end_date','genos','n_genos','n_days','filename_master');

% Which kinds of data types can be extracted right now
datatypes = {'activity data (5 min)','sleep data (5 min)',...
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
                outputdata = get5minsleep(master_data_struct,genoselected);
            case 3
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
                outputdata = get5minsleep(master_data_struct,genoselected);
            case 3
                outputdata = getrainbow(master_data_struct,genoselected);
        end
        
        % Suppress dead fly data
        outputdata(:,~master_data_struct(genoselected).alive_fly_indices) = NaN;
        
        % Copy the data to clip board
        mat2clip(outputdata)
    end

    % Extract raw actiity data (in 5-min bins). Each column is a different
    % fly. Each row is the number of beam crossing in 5 min, hence 288 rows
    % per day.
    function outputdata = getrawdata(master_data_struct,genoselected)
        outputdata = master_data_struct(genoselected).data;
    end

    % Extract sleep data (in 5-min bins). Each column is a different fly.
    % Each row is the min's that the fly sleeps in 5 min, hence 288 rows
    % per day.
    function outputdata = get5minsleep(master_data_struct,genoselected)
        tempdata = master_data_struct(genoselected).data;
        outputdata = 5 * double(tempdata == 0);
    end

    % Extract rainbow data (in 30-min bins). Each column is a different
    % fly. Each row is the number of min's of sleep in that 30-min bin,
    % hence 48 rows per day.
    function outputdata = getrainbow(master_data_struct,genoselected)
        % Use the get5minsleep function to obtain 5-min sleep data
        sleepdata = get5minsleep(master_data_struct,genoselected);
        
        % Get the number of 5-min bins
        n_bins = size(sleepdata,1);
        
        % Calculate the 30-min sleep data
        sleepdata30 = sum(reshape(sleepdata,6,[]))';
        
        % Reformat the matrix so that each column is a fly
        outputdata = reshape(sleepdata30, n_bins/6,[]);
    end
   
end

