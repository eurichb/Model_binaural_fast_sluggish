function [result_s] = add_mpar(result_s, data, name, varargin)
%add_mpar adds a new set of mpar to the data struct
%
%[result_s] = add_mpar(result_s, data, name, varargin)
%
%Parameters:
%  result_s:         The data struct
%  data:             A vector of IDs to be added to the mpar_table
%  name:             A name or description of mpar
%
%Returns:
%  The data struct with the added mpar
%
%Example:
%::
%  add_mpar(result_s, data, 'fiber_type',...
%           'index', [1, 2, 3], ...
%           'values', {'LSR', 'MSR', 'HSR'},...
%           'unit', '');
%
%This would add the new mpar 'fiber_type' with the possible
%ids 1 to 3 where 1 stands for LSR, 2 for MSR and 3 for HSR to
%the data struct. No unit is given as the values are textual.
%
%see also: add_spar sdf_info
%

[result_s] = z_add_par(result_s, data,name,'m', varargin{:});

end
