genoind = 3;
nflies2test = master_data_struct(genoind).num_alive_flies;
flies2test = find(master_data_struct(genoind).alive_fly_indices > 0);
avgchain=cell(nflies2test,1);

max_chainlength = zeros(nflies2test,1);

for ii = 1 : nflies2test

    wakedata = master_data_struct(genoind).data(:,flies2test(ii));
    wakebinary = master_data_struct(genoind).sleep_data(:,flies2test(ii)) == 0;
    wakechains = chainfinder(wakebinary);

    max_chainlength(ii) = max(wakechains(:,2));
    n_chains = size(wakechains,1);
    
    chainends = [wakechains(:,1),wakechains(:,1)+wakechains(:,2)-1];
    chains = ones(max_chainlength(ii),n_chains).*NaN;

    for i = 1 : n_chains
        seglength = wakechains(i,2);
        chains(1:seglength,i) = wakedata(chainends(i,1):chainends(i,2));
    end
    
    avgchain{ii,1} = nanmean(chains,2);
end


total_avgchain = ones(max(max_chainlength),nflies2test) .* NaN;

for ii = 1 : nflies2test
    total_avgchain(1: max_chainlength(ii),ii) = avgchain{ii,1};
end

wakecurve = nanmean(total_avgchain,2);