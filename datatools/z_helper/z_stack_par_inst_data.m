function [spikes] = z_stack_par_inst_data(spikes1,spikes2,sm)

    if isempty(fields(spikes1))
        spikes = spikes2;
    else
    
   
    par_table = [sm 'par_table'];
    par_info =[sm 'par_info'];
    par_dim = spikes1.data_info.ndim+1;
    ms = 's';
    if strcmp(sm,'s')
        par_dim = par_dim +1;
        ms = 'm';
    end
    
    size_sp1 = size(spikes1);    
    size_sp2 = size(spikes2);
    
    
    if ~isequal(size_sp1(1:spikes1.data_info.ndim),size_sp2(1:spikes2.data_info.ndim))
       warning('not same entries in result dimensions')       
        spikes = spikes1;
        return
    end
    
    
    if length(size_sp1) ~= length(size_sp2)
       warning('dimensions are not consistent')       
        spikes = spikes1;
        return
    end
    
    if ~isequal(spikes1.(par_info),spikes2.(par_info))
        warning([sm,'par-tables are not consistent (need more complex helper function)'])        
        spikes = spikes1;
        return
    end
      
    spikes.data = cat(par_dim, spikes1.data,spikes2.data);
    spikes.(par_table) = cat(1,spikes1.(par_table),spikes2.(par_table));
    
    spikes.([ms,'par_table']) = spikes1.([ms,'par_table']);
    spikes.mpar_info = spikes1.mpar_info;
    spikes.spar_info = spikes1.spar_info;
    spikes.data_info = spikes1.data_info;
    end
end