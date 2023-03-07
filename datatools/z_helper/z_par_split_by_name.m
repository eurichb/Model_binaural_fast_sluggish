function [split_list, split_values, num] = z_par_split_by_name(result_struct, name,sm)
%[meta, data, meta_num] = meta_split_by_name(result_struct, name)
%
%Split the spike struct using unique ids.
%
%  Parameters:
%  result_struct -- The spike struct
%  name -- The name to look for
%
%  Returns:
%  split_list -- The split spike structs
%  split_values -- The correspoinding metadata values
%
    
    result_struct.data_info.last_split_by.name = name;
    result_struct.data_info.last_split_by.sm = sm;
    
    par_table = [sm 'par_table'];

    [data, ~] = z_par_by_name(result_struct, name,sm,1);

    unique_vals = unique(data);
    split_list = [];
    split_values = [];

    for i_id = 1:length(unique_vals)
        new_spikes = result_struct;

        c_val = unique_vals(i_id);
        c_val_mask = data == c_val;

        % overwrite data in new struct with selected subset
        ndim_total = result_struct.data_info.ndim+2;
        i_par_dim = result_struct.data_info.ndim + 1;

        if strcmp('s',sm)
            i_par_dim = i_par_dim +1;
        end


        % Permute the result data so that the par dimension is the
        % first dimension
        permute_vector = 1:ndim_total;
        permute_vector(i_par_dim) = 1;
        permute_vector(1) = i_par_dim;
        permuted_data = permute(result_struct.data, ...
                                permute_vector);

        % extend the mask to fit the dimensions of the permuted
        % data and use it as an index
        all_dims = size(permuted_data);
        all_dims(1) = 1;
        c_val_matrix = repmat(c_val_mask, all_dims);
        sel_data = permuted_data(c_val_matrix);

        % reshape the results to the correct dimension and reverse permutation
        all_dims(1) = sum(c_val_mask);
        sel_data = reshape(sel_data, all_dims);
        sel_data = permute(sel_data, permute_vector);

        new_spikes.data = sel_data;% permute(sel_data, permute_vector);
        new_spikes.(par_table) = result_struct.(par_table)(c_val_mask, :);

        split_list = cat(2,split_list, new_spikes);
        split_values = cat(2,split_values, c_val);
    end
    split_values = double(split_values);
    num = 1:length(split_values);
end
