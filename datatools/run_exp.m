function [result,mpar] = run_exp(spar, fct, mpar, parfor_flag,show_flag)
%run_exp runs FCT() with all 'possible' spar instances (loop over n_sinst).
%Retuns RESULT in sdf (structured data format)
%
%   RESULT = run_exp(SPAR, FCT, MPAR)   
%
%   RESULT = run_exp(SPAR, FCT, MPAR, PARFOR_FLAG, SHOW_FLAG) 
%
%Parameters:
%   SPAR: struct containing all stimulus parameter (variations).
%         To select fixed spar combinations use 
%         spar.combi.spar1 = [] and 
%         spar.combi.spar2 = []  
%         All combi fields need the same number of entries.
%
%   FCT:  is a function which transforms a spar input of a single 
%         spar instance into a result (result-data-format). 
%   MPAR: is a struct containing all parameters for the FCT apart from SPAR
%   PARFOR_FLAG:  is 0 (default), if 1 runs a parfor loop.
%   SHOWFLAG:     is 1 (default), if 0 no progress-bar is shown
%
%for data type
%see also sdf_info, run_spar_space
%
%Example:
%::
%  %JUST FOR UNDERSTANDING
%  %(not working, since my_fct doesn't return result-data-format)
%  my_spar.a = [.1, .2, .3];
%  my_spar.b = [2, 3];
%  my_fct = @(stim) stim.a * 2 + stim.b;
%  my_result = run_exp(my_spar,my_fct,[]);
%

if nargin < 4; parfor_flag = 0; end
if nargin < 5; show_flag = 1; end


% all this lines handle the combination of spar
[spar,combi,exclude] = order_input_struct(spar);

% seperate all nan fields from combination generation, this field will be
% part of every model call
[spar, nan_struct] = split_nan_fields(spar);
[all_inst_spar, inst_matrix, n_combi] = set_spar_table(spar,combi,exclude);

if show_flag
disp([num2str(n_combi),' stim presentations'])
if parfor_flag
    parfor_progress(n_combi);
    parfor_progress;
else
    pb = progressbar(n_combi, 'exp progress');
    pb = pb.increment();
end
end

% check n_dim (for computational time reasons)

spar_inst = all_inst_spar(1); 
spar_inst = stack_fields(spar_inst,nan_struct);
[result,info_cell,mpar] = loop_body(spar_inst,fct,mpar);
n_dim = result.data_info.ndim;
r_data = zeros([size(result.data),n_combi ],'single');
if n_dim == length(size(result.data))
   r_data = zeros([size(result.data),1,n_combi ]);
end

switch n_dim
    
    case 0   
        r_data = zeros(size(result.data,1),n_combi);
        r_data(:,1) = result.data;
        % decision parfor or for loop
        if parfor_flag   
            parfor i_spar = 2:n_combi   
                spar_inst = all_inst_spar(i_spar); 
                spar_inst = stack_fields(spar_inst,nan_struct);
                [r_data(:,i_spar)] = loop_body_raw(spar_inst,fct,mpar);
                if show_flag; parfor_progress; end
            end
            if show_flag; parfor_progress(0); end
        else
            for i_spar = 2:n_combi    
                spar_inst = all_inst_spar(i_spar); 
                spar_inst = stack_fields(spar_inst,nan_struct);
                [r_data(:,i_spar)] = loop_body_raw(spar_inst,fct,mpar);        
                if show_flag; pb = pb.increment(); end
            end
        end 
        
    case 1      
        r_data(:,:,1) = result.data;
        % decision parfor or for loop
        if parfor_flag   
            parfor i_spar = 2:n_combi    
                spar_inst = all_inst_spar(i_spar); 
                spar_inst = stack_fields(spar_inst,nan_struct);
                [r_data(:,:,i_spar)] = loop_body_raw(spar_inst,fct,mpar);
                if show_flag; parfor_progress; end
            end
            if show_flag; parfor_progress(0); end
        else
            for i_spar = 2:n_combi     
                spar_inst = all_inst_spar(i_spar); 
                spar_inst = stack_fields(spar_inst,nan_struct);
                [r_data(:,:,i_spar)] = loop_body_raw(spar_inst,fct,mpar);        
                if show_flag; pb = pb.increment(); end
            end
        end    
               
    case 2
        r_data(:,:,:,1) = result.data;
        % decision parfor or for loop
            if parfor_flag   
                parfor i_spar = 2:n_combi        
                    [r_data(:,:,:,i_spar)] = loop_body_raw(all_inst_spar(i_spar),fct,mpar);
                     if show_flag; parfor_progress; end
                end
                if show_flag; parfor_progress(0); end
            else
                for i_spar = 2:n_combi        
                    [r_data(:,:,:,i_spar)] = loop_body_raw(all_inst_spar(i_spar),fct,mpar);        
                     if show_flag; pb = pb.increment(); end
                end
            end    
            
            
    case 3
        r_data(:,:,:,:,1) = result.data;
        % decision parfor or for loop
        if parfor_flag
            parfor i_spar = 2:n_combi
                [r_data(:,:,:,:,i_spar)] = loop_body_raw(all_inst_spar(i_spar),fct,mpar);
                if show_flag; parfor_progress; end
            end
            if show_flag; parfor_progress(0); end
        else
            for i_spar = 2:n_combi
                [r_data(:,:,:,:,i_spar)] = loop_body_raw(all_inst_spar(i_spar),fct,mpar);
                if show_flag; pb = pb.increment(); end
            end
        end
end
     
    % stack the data for all n_sinst
    % spar_table + data
   
    result = z_add_par_inst('s',1,result, info_cell{:}); % HIER MIT TABLE 17, INFO 16 RAUSGEKOMMEN
    result.spar_table = inst_matrix;
    result.data = r_data;   
    

    result = check_ndim(result);

end

% local fct called by parfor or for loop
function [data,info_cell,mpar_out] = loop_body(spar_inst,fct,mpar)
        
        [out,mpar_out] = feval(fct,spar_inst,mpar);
        info_cell = gen_info_with_par_and_vals(spar_inst);
        data =  out;        
        
end
function [data] = loop_body_raw(spar_inst,fct,mpar)
        
        out = feval(fct,spar_inst,mpar);
        data =  out.data;        
        
end

