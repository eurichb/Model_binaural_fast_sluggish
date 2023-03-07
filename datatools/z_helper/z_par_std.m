function data = z_par_std(result_multi,sm)

switch sm
    case 's'
        add_dim = 2;
    case 'm'
        add_dim = 1;
    otherwise
        warning('invalid function call');
end

if sum(size(result_multi)) >2
    
    spar_dim = result_multi(1).data_info.ndim+add_dim;
    
    data = cell2mat(arrayfun(@(x) std(x.data,[],spar_dim),result_multi,'UniformOutput',false)');

end




end