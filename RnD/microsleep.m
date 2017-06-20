geno2do = 3;

data_R0 = master_data_struct(geno2do).data;
sleep_5 = master_data_struct(geno2do).sleep_data;

data_R1 = data_R0 + sleep_5;
microsleep_mat = zeros(4, size(data_R1,2));

%%
for i = 1: size(data_R1,2);
chain_sleep_micro = chainfinder(data_R1(:,i)==0);

for j = 1 : 4
    microsleep_mat(j,i) = sum(chain_sleep_micro(:,2)==j) * j;
end

end

%%
deadflyind = master_data_struct(geno2do).alive_fly_indices == 0;
microsleep_mat(:,deadflyind) = NaN;
