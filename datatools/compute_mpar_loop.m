function [result, mpar] = compute_mpar_loop(stim, fct, mpar)
% compute_mpar_loop runs FCT()  with all 'possible' mpar instances. (loop over n_minst)
%   RESULT = compute_mpar_loop(STIM, FCT, MPAR) returns data in result-data-format.
%   STIM is an input in result-data-format.
%   FCT is a function wich transforms an input in result-data-format for a single
%   mpar instance  into a result (result-data-format).
%   MPAR is a struct containing all model parameter (variations).
%
% for data type
% see also sdf_info
%
% EXAMPLE:  JUST FOR UNDERSTANDING
% (not working, since gen_my_stim and my_model is not a function)
%
%  my_mpar.a = [.1 .2 .3];
%  my_mpar.b = [2 3];
%
%  my_stim = gen_my_stim();
%
%  my_result = compute_mpar_loop(my_stim, @my_model, mpar);

    
%    mpar_fields = fields(mpar);
%    
%    mpar_dim = 0;
%    for mpar_field = mpar_fields'
%        field_name = mpar_field{:};
%        if isstruct(mpar.(field_name))
%            mpar_parent = mpar;
%            mpar_dim = 1;
%            mpar = mpar.(field_name);
%            break
%        end
%    end
   
   
   [mpar, nan_struct] = split_nan_fields(mpar);
   
   [all_inst_par, inst_matrix, n_combi] = get_all_combinations(mpar);

mpar_fields = fields(mpar);

% mpar_dim = 0;
for mpar_field = mpar_fields'
    field_name = mpar_field{:};
    if isstruct(mpar.(field_name))
        mpar_parent = mpar;
        mpar_dim = 1;
        mpar = mpar.(field_name);
        break
    end
end


[mpar, nan_struct] = split_nan_fields(mpar);

[all_inst_par, inst_matrix, n_combi] = get_all_combinations(mpar);

if isfield(mpar, 'neurons_per_cf')
    mpar_step = mpar.neurons_per_cf;
else
    mpar_step = 1;
end



mpar_dim = 0; % because the section this refers to is outcommented
if mpar_dim
    mpar_inst = mpar_parent;
    mpar_inst.(field_name) = all_inst_par(1);
    mpar_inst.(field_name) = stack_fields(mpar_inst.(field_name),nan_struct);
else
    mpar_inst = all_inst_par(1);
    mpar_inst = stack_fields(mpar_inst,nan_struct);
end



% check n_dim (for computational time reasons)
% stim0 = stim;
% stim0.data = stim.data(:,:,1);
result = feval(fct,stim,mpar_inst);
n_dim = result.data_info.ndim;
mpar_table = result.mpar_table;
n_mpar = size(mpar_table,1);
mpar_step = mpar_step * n_mpar;
n_neurons = n_combi * mpar_step;
% loop over mpar instances
switch n_dim
    case {0,1}
        r_data = zeros([size(result.data,1),n_neurons ]);
        r_data(1:mpar_step) = result.data;
        for i_mpar = 2:n_combi
            mpar_inst_t = all_inst_par(i_mpar);
            mpar_inst_t = stack_fields(mpar_inst_t,nan_struct);
            if mpar_dim
                mpar_inst = mpar_parent;
                mpar_inst.(field_name) = mpar_inst_t;
            else
                mpar_inst = mpar_inst_t;
            end
            
            out = feval(fct,stim,mpar_inst);
            r_data(i_mpar) = out.data;
        end
                r_data(:,:,1:mpar_step,:) = result.data;

    case {2,3}
        r_data = zeros([size(result.data,1),size(result.data,2),n_neurons,size(result.data,3)]);
        r_data(:,:,1:mpar_step,:) = result.data;
        for i_mpar = 2:n_combi
            mpar_inst_t = all_inst_par(i_mpar);
            mpar_inst_t = stack_fields(mpar_inst_t,nan_struct);
            if mpar_dim
                mpar_inst = mpar_parent;
                mpar_inst.(field_name) = mpar_inst_t;
            else
                mpar_inst = mpar_inst_t;
            end
            
            % if an mpar is changed that affected the stimulus used here, this makes sure that the right stim is used
%             if size(stim.data,3) > 1
%                 stim.data = stim.data(:,:,i_mpar);
%             end
            out = feval(fct,stim,mpar_inst);
            start_i = (i_mpar-1)*mpar_step+1;
            end_i = start_i-1 + mpar_step;
            r_data(:,:,start_i:end_i) = out.data;
            mpar_table = cat(1,mpar_table,out.mpar_table);
        end
        
   
end

result.mpar_table = mpar_table;
%     result.mpar_table = inst_matrix;
%     nan_fields = fields(nan_struct);
%     for nan_f = nan_fields
%         result = add_mpar(result, 1, 'fiber_type', 'values', fiber_types, ...
%                  'index', [1, 2, 3]);
%
%     end
%
mpar_t = stack_fields(mpar,nan_struct);

if mpar_dim
    mpar = mpar_parent;
    mpar.(field_name) = mpar_t;
else
    mpar = mpar_t;
end

result.data = r_data;

end
