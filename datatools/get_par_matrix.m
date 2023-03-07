function [ ids ] = get_par_matrix( ids , ms , other_par_row )
%
% [ ids ] = get_par_matrix( ids , ms , other_par_row )
%
% This function reshapes your data in the ids-(ibidt data structure) format
% to a n-dimensional matrix format. You have to choose if you want your
% mpar or your spar data in a matrix . A combination is not possible. The 
% dimensions of the matrix correponds to the order in your m/s-par_table or
% better: in your ids.m/s-par_info. But only parameters with length > 1 are
% considered (for a better legibility there is a squeeze in the end)! 
% If you choose 'm' you will get a matrix with all combinations of mpar
% for every spar combination, and vice versa. All matrices are in the cell
% array data_m, which were added to your input ids.
% Important: the size of your data for each instance has to be a scalar!
%
% Parameters:
% ids -- your input struct in the ibidt data structure.
% ms -- either 'm' for mpar or 's' for spar
% other_par_row (opt) -- specific row for the other dim: example: if you
%                        want a mpar table, you can specify a spar index/row
%                        default is all rows (all spar combinations)
%
% Returns:
% ids -- your input struct plus a cell array called data_m. 
%
% Sven Herrmann, Universität Oldenburg
%
% v0.9 15.01.2020
%
% TODO:
% - get a coffee ;)
% data size scalars only...if data_matrix were a cell array there are more dims possible,
% but is the output handy?

if strcmp(ms,'m')
    sm = 's';
else
    sm = 'm';
end

s.spar_names = {ids.spar_info.name};
s.mpar_names = {ids.mpar_info.name};

param_c = cell(1,length(s.([ms 'par_names'])));
param_size = zeros(size(param_c));

for idx = 1:length(param_c)
    
    param = unique(ids.([ms 'par_table'])(:,idx));
    
    param_c{idx} = param;
    param_size(idx) = length(param);
    
end

desired_table = ids.([ms 'par_table']);
other_table = ids.([sm 'par_table']);

data_m = cell(size(other_table,1),1);
ndims = repmat({':'},1,ids.data_info.ndim);

if nargin < 3
    idx_sm_v = 1:size(other_table,1);
else
    idx_sm_v = other_par_row;
end

for idx_sm = idx_sm_v
    
    data_matrix = zeros(param_size);
    
    for idx_ms = 1:size(desired_table,1)
        
        indices = cell(size(param_c));
        
        for idx_param = 1:size(desired_table,2)
            indices{idx_param} = find(desired_table(idx_ms,idx_param) == param_c{idx_param});
        end
        
        switch ms
            case 'm'
                data_matrix(indices{:}) = ids.data(ndims{:},idx_ms,idx_sm);
            case 's'
                data_matrix(indices{:}) = ids.data(ndims{:},idx_sm,idx_ms);
        end
        
    end
    
    data_m{idx_sm} = squeeze(data_matrix);
    
end

data_m = data_m(~cellfun(@isempty, data_m));
ids.data_m = data_m;

end