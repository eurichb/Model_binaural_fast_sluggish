function [result_s] = add_spar(result_s, data, name, varargin)
% add_spar adds a new set of spar to the spike struct (sdf)
%
%[result_s] = add_spar(result_s, data, name)
%
%  Parameters:
%  result_s         The spike struct
%  data             A vector of IDs to be added to the spar_table
%  name             A name or description of spar
%
%  Returns:
%  result_s         The spike struct with the added spar
%
%  Example:
%  add_spar(result_s, data, 'noise_type',...
%                                     'index', [1, 2], ...
%                                    'values', {'no_noise', 'pink_noise'},...
%                                      'unit', '');
%  This would add the new spar 'noise_type' with the possible
%  ids 1 to 2 where 1 stands forno noise, 2 for pink nosie to
%  the spike struct. No unit is given as the values are textual
%
% see also add_mpar, z_check_indexed_values, sdf_info
   
[result_s] = z_add_par(result_s, data,name,'s', varargin{:});

end
