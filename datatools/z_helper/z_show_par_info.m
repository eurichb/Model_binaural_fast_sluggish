function out = z_show_par_info(struct,sm)

    out ={};
    
    par_info =[sm 'par_info'];
    
    if ~isfield(struct,par_info)
        if ~isfield(struct,(par_info))
            
    return
        end
    end
    
  
            n_meta = size(struct.(par_info),2);
           

            for i_meta = 1:n_meta

                out{i_meta,1} = struct.(par_info)(i_meta).name;

            end

        

end