function out = stack_spar(result_struct_in,par)

out = result_struct_in;
result_struct_in = spar_split_by_name(result_struct_in,par);


spar_dim = out.data_info.ndim+2;

for ii = 1:length(result_struct_in)
    
    % check if spar table is the same for all fibers
    if all(result_struct_in(ii).spar_table(1,:) == result_struct_in(ii).spar_table)

    
    splitA = num2cell(result_struct_in(ii).data, [1:spar_dim-1 spar_dim+1] ); %split A keeping dimension 1 and 2 intact
    data = vertcat(splitA{:});
    n_stacks = size(splitA ,spar_dim);
    
    if ii == 1
        out.data=data;
        out.spar_table = result_struct_in(ii).spar_table(1,:);
        
    else
        out.data = cat(1,out.data,data);        
        out.spar_table = cat(1,out.spar_table,result_struct_in(ii).spar_table(1,:));
    end
    else
        error('not same spar table')
    end
end
out.data_info.duration = out.data_info.duration * n_stacks;

end