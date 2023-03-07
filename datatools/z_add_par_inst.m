function [spikes] = z_add_par_inst(sm,intern_case,spikes,varargin)
%z_add_par_inst
%PLEASE USE the dummy FUNCTIONS: ADD_MPAR_INST and ADD_SPAR_INST !!!
% See also ADD_MPAR_INST, ADD_SPAR_INST

%   sm is a flag for stimulus or model parameter: 
%   intern_case is a flag for specific intern tasks due to computational speed (not touch)

    par_table = [sm 'par_table'];
    par_info =[sm 'par_info'];    
    
    if ~isempty(varargin)
        % check that there is an even number of nargins
        assert (mod(length(varargin), 2) == 0);
        n_infos = length(varargin) / 2;     
    else
        warning('no change given')
        return
    end
        
    % Check if the mpar_table exists and generate if not
    if ~isfield(spikes, par_table)                
        spikes.(par_table) = single([]);
        inst_num = 1;
    else
        inst_num = size(spikes.(par_table), 1) + 1;
        inst_length =size(spikes.(par_table), 2);
        if n_infos ~= inst_length
        % this line copies the inst line (if e.g. just a new par is defined) 
        spikes.(par_table)(inst_num,:) = spikes.(par_table)(inst_num-1,:);
        end
    end
    
    if ~isfield(spikes, par_info)
        spikes.(par_info) = struct;
    end               
        for i_info = 1:n_infos
            description = varargin{2 * i_info - 1};
            value = varargin{2 * i_info};            
                       
            if intern_case && inst_num ~= 1
                i_des = i_info;
            else
                i_des = z_get_par_index(sm,spikes,description,0);
            end
            
            if i_des < 0
              spikes =  z_add_par(spikes, value,description,sm);
            else
              spikes.(par_table)(inst_num,i_des) = value;
            end                        
        end    
end