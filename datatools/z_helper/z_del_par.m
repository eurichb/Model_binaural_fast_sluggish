function [ struct ] = z_del_par(struct , name , sm )
% see also del_spar

par_index = z_get_par_index(sm,struct,name);


struct.([sm 'par_info'])(par_index) = [];
struct.([sm 'par_table'])(:,par_index) = [];



end 