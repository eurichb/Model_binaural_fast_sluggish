function [result_struct] = z_par_struct_to_table(result_struct, ...
                                               param_struct,sm)
                                           
    par_table = [sm 'par_table'];

    fields = fieldnames(param_struct);
    
    if isfield(result_struct,par_table)
        ninst = size(result_struct.(par_table), 1);
    else
        ninst = 1;
    end
    
    
    for i = 1:numel(fields)
        
        
        
        name = fields{i};
        
        if ~contains(name,z_show_par_info(result_struct,sm))
            val = param_struct.(name);
            if (isnumeric(val) && (length(val) == 1))
                % if the parameter is numeric, write it direclty
                par_data = ones(1, ninst) * val;
                result_struct = z_add_par(result_struct, par_data, ...
                    name,sm);
            else
                % If the parameter is not numeric use an index to code
                % for it
                par_data = ones(1, ninst);
                result_struct = z_add_par(result_struct, par_data, ...
                    name,sm, 'values', val, 'index', ...
                    1);
            end
        end
    end
end
