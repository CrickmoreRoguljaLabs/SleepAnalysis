% Create a cell of anticipation indices by genotypes
anticipation_index = cell(n_genos,1);

for ii = 1 : n_genos
    % Obtain activity for each fy
    temp_activity = master_data_struct(ii).data;
    
    % Only use the alive flies
    temp_activity = temp_activity(:,master_data_struct(ii).alive_fly_indices>0);
    
    % Obtain how many flies are alive
    n_flies = master_data_struct(ii).num_alive_flies;
    
    % Reshape the data into a 3d matrix for calculation
    activity3d = reshape(temp_activity, [288, n_days, n_flies]);
    
    % Initiate anticipation matrix for one genotype: each row is a day,
    % each column a different fly
    anticipation_mat = zeros(n_days,n_flies);
    
    for i = 1 : n_flies
        % Obtain the activity of a single fly
        activity_single_fly = activity3d(:,:,i);
        
        % Obtain the total activity 3 hours prior to light on
        minus3 = sum(activity_single_fly(end-35:end,:));
        
        % Obtain the total activity 3-6 hours prior to light on
        minus6 = sum(activity_single_fly(end-71:end-36,:));
        
        % Calculate the anticipation index
        anti_ind_temp = (minus3 - minus6)./(minus3 + minus6);
        
        % Change NaNs to 0s
        nan_ind = isnan(anti_ind_temp);
        
        anti_ind_temp(nan_ind) = 0;
        
        % Put the anticipation indices of one fly into the matrix
        anticipation_mat(:,i) = anti_ind_temp;
    end
    
    % Load the anticipation matrix into the cell
    anticipation_index{ii} = anticipation_mat;
end

% Calculate max number of flies
num_flies = zeros(1,n_genos);
for i = 1:n_genos
    num_flies(i) = master_data_struct(i).num_alive_flies;
end
max_num_flies = max(num_flies);

% Create per-fly averages
avg_per_fly = zeros(max_num_flies, n_genos);
avg_per_fly(:,:) = NaN;

for i = 1:n_genos
    avg_per_fly(1:size(anticipation_index{i},2),i) = mean(anticipation_index{i})';
end

% Put data into a cell for export
average_index_cell = genos';
average_index_cell(2:max_num_flies+1, 1:n_genos) = num2cell(avg_per_fly(:,:));
    

% Write the cell data
cell2csv(fullfile(export_path,'anticipation_index.csv'),average_index_cell);

