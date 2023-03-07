function [all_inst_par, inst_matrix ,n_combi] = get_all_combinations(par)
% get_all_combinations returns all combinations of par
%[ALL_INST_PAR, N_COMBI, INST_MATRIX] = get_all_combinations(PAR)
%PAR            par struct
%
%ALL_INST_PAR   struct with N_COMBI entrys, each containing par for one inst
%INST_MATRIX    matrix with dim N_COMBI x n_par, par table with all combinations
%N_COMBI        number of combinations
%
% for data type
% see also sdf_info


par_cell = struct2cell(par);
combinations = cell(size(par_cell));
[combinations{:}] = ndgrid(par_cell{:});
combinations = cellfun(@(x) x(:), combinations,'uniformoutput',false);
inst_cell = num2cell([combinations{:}]);
inst_matrix = single(cell2mat(combinations'));
list_par = fields(par);

all_inst_par = cell2struct(inst_cell,list_par,2);
n_combi = length(all_inst_par);



end