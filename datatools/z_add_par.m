function [result_struct] = z_add_par(result_struct, data, ...
                                      name,sm, varargin)
%[result_struct] = z_add_par(result_struct, data, name)
%
% see also add_mpar, add_spar




par_table = [sm 'par_table'];
par_info =[sm 'par_info'];

    % Check if the meta_table exists and generate if not
    if ~isfield(result_struct, par_table)
        result_struct.(par_table) = single([]);
        meta_num = 1;
    else
        meta_num = size(result_struct.(par_table), 2) + 1;
    end

     % create meta_data cell if non exsistent
    if ~isfield(result_struct, par_info)
        result_struct.(par_info) = {};
    end

    if z_get_par_index(sm,result_struct,name) ~= -1
        error([name, ' already exist in ',sm,'par_info'])
    end
    
    if ~isnumeric(data)
    varargin(1) ={'index'};
    varargin(2) ={1};
    varargin(3) ={'values'};
    varargin(4) ={data};
    data = 1;
    end
    result_struct.(par_table)(:, meta_num) = data;
    %result_struct.(par_table) = cat(2,result_struct.(par_table),data);
    % seem to be longer

    result_struct.(par_info)(meta_num).name = name;

    if ~isempty(varargin)
        % check that there is an even number of nargins
        assert (mod(length(varargin), 2) == 0);
        n_infos = length(varargin) / 2;
        for i_info = 1:n_infos
            description = varargin{2 * i_info - 1};
            value = varargin{2 * i_info};
            if strcmp(description,'values') && ~iscell(value)
                value = {value};
            end
            result_struct.(par_info)(meta_num).(description) = value;
        end
        
        if isfield(result_struct.(par_info)(meta_num),'index') && strcmp(varargin(1),'index')
            if ~iscell(result_struct.(par_info)(meta_num).values)
            error('index values need to be of variable class/type cell')
            end
            n_index = length(result_struct.(par_info)(meta_num).index);
            n_values = length(result_struct.(par_info)(meta_num).values);
            if n_index ~= n_values
                error('number of index and values should match')            
            end
        end
        
    end

    % result_struct.(par_info).(meta_name).ids = ids;
    % result_struct.(par_info).(meta_name).id_map = id_map;
    % result_struct.(par_info).(meta_name).unit = unit;

end
