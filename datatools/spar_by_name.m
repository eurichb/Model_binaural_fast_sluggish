function [data, spar_index] = spar_by_name(struct, name)%
%spar_by_name finds and returns all values of name in spar_table
%
%   [data, spar_index] = spar_by_name(struct, name)
%
%Parameters:
%  struct: The struct
%  name: The name to look for
%  data: The corresbonding values from the spar_info table
%  spar_index: The colum_index in the spar_table
%
%see also spar_split_by_name, mpar_by_name, sdf_info

   [data, spar_index] = z_par_by_name(struct, name,'s',1);
end
