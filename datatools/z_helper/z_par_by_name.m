function [data, par_index] = z_par_by_name(result_struct, name,sm,warning_on)
%see also spar_by_name, mpar_by_name, sdf_info
    if nargin <=3
        warning_on = 0;
    end

    par_table = [sm 'par_table'];
    par_info =[sm 'par_info'];

      
    par_index = z_get_par_index(sm,result_struct,name, warning_on);
    
    if par_index==-1
        error([name,' is not part of ',par_info]) 
    end
 
    data = result_struct.(par_table)(:, par_index);
   
end
