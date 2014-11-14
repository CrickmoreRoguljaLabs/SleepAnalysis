function [ chainmat ] = chainfinder( inputvec )
%chainfinder reports the chains of consecutive numbers
%   Input:
%   inputvec: a vector of data to find chains within
%
%   Output:
%   chainmat: a n-by-2 matrix to report the chains found. Each row is a 
%             chain. The first column tells where each chain starts. The
%             second column tells the lengths of the chains.

% Get the number of entries in the vector
n_num=length(inputvec);

% Determine the whether the first entry is zero or not. Chain index is the index (row number) of each chain
if inputvec(1)~=0
    chainmat=[1,1];
    chain_ind=1;
else
    chainmat=[];
    chain_ind=0;
end

% Calculating chains
for i=2:n_num
    if inputvec(i)~=0
        % If the entry is not zero...
        if inputvec(i)-inputvec(i-1)~=0
            % If the entry is not the same as before, start a new chain.
            chain_ind=chain_ind+1;
            chainmat(chain_ind,1)=i;
            chainmat(chain_ind,2)=1;
        else
            % If the entry is the same as before, add 1 to the length
            chainmat(chain_ind,2)=chainmat(chain_ind,2)+1;
        end   
    end
end

end

