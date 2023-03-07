function  par = z_get_par(result, sm)
% function that gets out names and values of used 's' or 'm' parameters

n_inst = size(result(1).([sm 'par_info']),2);

for i_inst = 1: n_inst 

    par_name = result.([sm 'par_info'])(i_inst).name;
    par.(par_name) = sort(unique(result.([sm 'par_table'])(:,i_inst)))';

end

end
