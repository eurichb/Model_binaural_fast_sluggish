function par_index = z_get_par_index(sm,struct,name,warning_on)

if nargin <=3
        warning_on = 0;
end
    
par_table = [sm 'par_table'];
par_info =[sm 'par_info'];

par_index = -1;

if warning_on
    info_names = z_show_par_info(struct,sm);
        if ~contains(info_names,name)            
            disp('List of model parameters: ')
            disp(info_names)
            error([name ' is not a model parameter.'])
            return
        end
end
    
n_par = size(struct.(par_table), 2);

    for i_meta = 1:n_par
        if strcmp(name, struct.(par_info)(i_meta).name)
            par_index = i_meta;
            break
        end
    end


end