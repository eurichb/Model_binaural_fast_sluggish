function out = stack_mpar(result_struct_in,par)

out = result_struct_in;
result_struct_in = mpar_split_by_name(result_struct_in,par);


mpar_dim = out.data_info.ndim+1;

for ii = 1:length(result_struct_in)
    
    % check if mpar table is the same for all fibers
    if all(result_struct_in(ii).mpar_table(1,:) == result_struct_in(ii).mpar_table)

    
    splitA = num2cell(result_struct_in(ii).data, [1:mpar_dim-1 mpar_dim+1] ); %split A keeping dimension 1 and 2 intact
    data = vertcat(splitA{:});
    n_stacks = size(splitA ,mpar_dim);
    
    if ii == 1
        out.data=data;
        out.mpar_table = result_struct_in(ii).mpar_table(1,:);
        
    else
        out.data = cat(mpar_dim,out.data,data);        
        out.mpar_table = cat(1,out.mpar_table,result_struct_in(ii).mpar_table(1,:));
    end
    else
        error('not same mpar table')
    end
end
out.data_info.duration = out.data_info.duration * n_stacks;

end