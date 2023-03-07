function [out, out_std] = z_par_mean_by_name(in,name,sm)
% see also spar_mean_by_name mpar_mean_by_name

switch sm
    case 's'
        split = spar_split_by_name(in,name);
       
    case 'm'
        split = mpar_split_by_name(in,name);              
end

out = result_mean(split);    
out_std = result_std(split);

end