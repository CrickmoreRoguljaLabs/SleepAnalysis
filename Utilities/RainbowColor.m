%% Default values
% Use the same color for border (as line): 1 = yes, 0 = no
Border_Color_As_Line = 1;

% If border uses the same color and line, set border transparency here
BorderAlpha = 0.5;

% Use default shade transparency: 1 = yes, 0 = no
Use_Def_shade_alpha = 1;

% Default shade transparency
Def_shade_alpha = 0.2;

%% Loading figure and parameters
% Load figure file
[filename, pathname] = uigetfile('*.fig', 'Choose a figure to edit');
hfig = openfig(fullfile(pathname, filename));

% Determine how many panels there are
npanels = length(findall(hfig,'Type','Axes'));

% Find lines
lines = findall(hfig,'Type','Line');
nlines = length(lines) / 5;

% Determine the number of borders
nborders = length(lines) / 5 * 4;

% Find patches/shades
patches = findall(hfig,'Type','Patch');
npatches = length(patches);

% Determine the number of genotypes
ngenos = npatches/npanels;

% Determine how often the line indices cycle from panel to panel
linecycle = ngenos * 5;

% Determine how often the patch indices cycle from panel to panel
patchcycle = ngenos;

% Initialize a construct describing the color parameter
ColorStruct = struct('geno','','LineInd',[],'LineColor',[],'PatchInd',[],...
    'PatchColor',[], 'PatchAlpha',[],'BorderInd',[],'BorderColor',[]);
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
    % lineind_tmp = i + (0 : (npanels-1)) * linecycle;
    % lineind_tmp = repmat([i; ngenos+2*i-1; ngenos+2*i; 3*ngenos+2*i-1; 3*ngenos+2*i],...
    %     [1 npanels]) + repmat((0 : (npanels-1)) * linecycle, [5 1]);
    
    % Load line indices
    ColorStruct(i).LineInd = i + (0 : (npanels-1)) * linecycle;
    
    % Load patch indices (including the weird index reversal - oh well)
    ColorStruct(i).PatchInd = (ngenos+1-i) : patchcycle : npatches;
    
    % Load border indices
    borderind_tmp = [3*ngenos-2*i+1; 3*ngenos-2*i+2; 5*ngenos-2*i+1; 5*ngenos-2*i+2]*...
        ones(1, npanels) + ones(4,1)*(0 : (npanels-1)) * linecycle;
    ColorStruct(i).BorderInd = borderind_tmp(:);
    
    % Load border colors
    ColorStruct(i).BorderColor = lines(borderind_tmp(1)).Color;
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
    borderindices = ColorStruct(geno2choose).BorderInd;
    
    % Use the matlab UI to choose color. May not be ideal
    chosenlinecolor = uisetcolor(['Line color: ', ColorStruct(geno2choose).geno]);
    
    % Use line color for border color unless Border_Color_As_Line = 0
    if Border_Color_As_Line == 0
        chosenbordercolor = uisetcolor(['Border color: ', ColorStruct(geno2choose).geno]);
    else
        chosenbordercolor = chosenlinecolor * BorderAlpha + ones(1,3) * (1 - BorderAlpha);
    end
    
    % Determine if using the default shade transparency
    if Use_Def_shade_alpha == 1
        chosenalpha = Def_shade_alpha;
    else
        % Choose shade transparency
        chosenalpha = input('Shade transparency (0 = transparent; 1 = opaque): ');
    end
        
    % Change the line colors
    for i = 1 : nlines/ngenos
        lines(lineindices(i)).Color = chosenlinecolor;
    end
    
    % Change the border colors
    for i = 1 : nborders/ngenos
        lines(borderindices(i)).Color = chosenbordercolor;
    end
    
    % Change the shade colors (current the same as line's, just more
    % transparent
    for i = 1: npatches/ngenos
        patches(patchindices(i)).FaceColor = chosenlinecolor;
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