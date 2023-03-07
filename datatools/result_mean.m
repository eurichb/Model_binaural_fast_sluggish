function results_single = result_mean(result_multi)
% function means over all data in result_multi


if sum(size(result_multi)) >2
    
    spar_dim = result_multi(1).data_info.ndim+2;
    results_single = result_multi(1);
    
    % stack data into big matrix (data-index is first dim)
    data = cell2mat(arrayfun(@(x) permute(x.data,[spar_dim+1,1:spar_dim]), result_multi,'UniformOutput',false)');
    
    % take the mean
 
    data = nanmean(data,1);
    
    %back transformatin into data type
    results_single.data = permute(data,[2:spar_dim+1,1]);
else
    results_single = result_multi;
    
end

vals_split_by = zeros(1,size(result_multi,2));
sm = results_single.data_info.last_split_by.sm;

idx_split_by = z_get_par_index(sm,result_multi(1),results_single.data_info.last_split_by.name);

switch sm
    case 's'
        for idx_split = 1:size(result_multi,2)
            vals_split_by(1,idx_split) = result_multi(idx_split).spar_table(1,idx_split_by);
        end
        results_single.spar_info(idx_split_by) = [];
        results_single.spar_table(:,idx_split_by) = [];
        
    case 'm'
        for idx_split = 1:size(result_multi,2)
            vals_split_by(1,idx_split) = result_multi(idx_split).mpar_table(1,idx_split_by);
        end
        results_single.mpar_info(idx_split_by) = [];
        results_single.mpar_table(:,idx_split_by) = [];
        
end
if isfield(results_single.data_info,'mean_over')
    n_mean = size(results_single.data_info.mean_over,1);
else
    n_mean = 0;
end
results_single.data_info.mean_over(n_mean+1).name = results_single.data_info.last_split_by.name;
results_single.data_info.mean_over(n_mean+1).values = vals_split_by;


end