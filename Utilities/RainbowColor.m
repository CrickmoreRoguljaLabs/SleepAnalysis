%% Loading figure and parameters
% Load figure file
[filename, pathname] = uigetfile('*.fig', 'Choose a figure to edit');
hfig = openfig(fullfile(pathname, filename));

% Determine how many panels there are
npanels = length(findall(hfig,'Type','Axes'));

% Find lines
lines = findall(hfig,'Type','Line');
nlines = length(lines);

% Find patches/shadows
patches = findall(hfig,'Type','Patch');
npatches = length(patches);

% Determine the number of genotypes
ngenos = npatches/npanels;

% Determine how often the line indices cycle from panel to panel
linecycle = ngenos * 5;

% Determine how often the patch indices cycle from panel to panel
patchcycle = ngenos;

% Initialize a construct describing the color parameter
ColorStruct = struct('geno','','LineInd',[],'LineColor',[],'PatchInd',[],'PatchColor',[], 'PatchAlpha',[]);
ColorStruct(1:ngenos) = ColorStruct;


for i = 1 : ngenos
    % Load the current genotype
    ColorStruct(i).geno = lines(i).DisplayName;
    
    % Load line color
    ColorStruct(i).LineColor = lines(i).Color;
    
    % Load patch color and alpha
    ColorStruct(i).PatchColor = patches(i).FaceColor;
    ColorStruct(i).PatchAlpha = patches(i).FaceAlpha;

    % Determine the line indices of each genotype. The messy index
    % algorithm comes from a weird index reversal in generating the figure
    % (not my code). There is no fix for that
    lineind_tmp = repmat([i; 3*ngenos-2*i+1; 3*ngenos-2*i+2; 5*ngenos-2*i+1; 5*ngenos-2*i+2],...
        [1 npanels]) + repmat((0 : (npanels-1)) * linecycle, [5 1]);
    % lineind_tmp = repmat([i; ngenos+2*i-1; ngenos+2*i; 3*ngenos+2*i-1; 3*ngenos+2*i],...
    %     [1 npanels]) + repmat((0 : (npanels-1)) * linecycle, [5 1]);
    
    % Load line indices
    ColorStruct(i).LineInd = lineind_tmp(:);
    
    % Load patch indices (including the weird index reversal - oh well)
    ColorStruct(i).PatchInd = (ngenos+1-i) : patchcycle : npatches;
end

%% Edit the figures
% Show genotypes
disp('======================================================')
disp('Genotypes are:')
{ColorStruct.geno}'

% Choose which genotype to edit
disp('Which genotype to edit? (Use number; 0 = exit)')
geno2choose = input('Index to choose: ');
    
% Keep looping through until the user quits (by entering 0)
while geno2choose ~= 0
    % Load the line and patch indices
    lineindices = ColorStruct(geno2choose).LineInd;
    patchindices = ColorStruct(geno2choose).PatchInd;
    
    % Use the matlab UI to choose color. May not be ideal
    chosencolor = uisetcolor;
    
    % Choose shadow transparency
    chosenalpha = input('Shade transparency (0 = transparent; 1 = opaque): ');
    
    % Change the line colors
    for i = 1 : nlines/ngenos
        lines(lineindices(i)).Color = chosencolor;
    end
    
    % Change the shadow colors (current the same as line's, just more
    % transparent
    for i = 1: npatches/ngenos
        patches(patchindices(i)).FaceColor = chosencolor;
        patches(patchindices(i)).FaceAlpha = chosenalpha;
    end
    
    % Show genotypes
    disp('=============================================')
    disp('Genotypes are:')
    {ColorStruct.geno}'

    % Choose which genotype to edit
    disp('Which genotype to edit? (Use number; 0 = exit)')
    geno2choose = input('Index to choose: ');
end