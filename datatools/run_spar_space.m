function out = run_spar_space(in_s,fct,mpar,parfor_flag)
%run_spar_space is the same as run_exp, but you feed in  results in rdf
%
%see also run_exp

if nargin < 4
    parfor_flag = 0;
end
ndim_in = in_s.data_info.ndim;
spar_dim =  ndim_in + 2;
n_sinst = size(in_s.data,spar_dim);

in_data = in_s.data;
loop_dummy_in = [];
loop_dummy_in.data_info = in_s.data_info;

if isfield(in_s,'mpar_info')
loop_dummy_in.mpar_info = in_s.mpar_info;
loop_dummy_in.mpar_table = in_s.mpar_table;
end

switch ndim_in
    case 2
        % gen first entry spar for pre allocation
        loop_dummy_in.data = in_data(:,:,:,1);
        [out_pre, mpar] = feval(fct,loop_dummy_in,mpar);
        data = out_pre.data;
        out = out_pre;
        out.spar_table = in_s.spar_table;
        out.spar_info = in_s.spar_info;
        ndim_out = out_pre.data_info.ndim;
        clear in_s
        
        if ~parfor_flag
            pb = progressbar(n_sinst, 'exp progress');
            pb = pb.increment();
            for i_sinst = 2:n_sinst
                
                loop_dummy_in.data = in_data(:,:,:,i_sinst);
                
                out_tmp = feval(fct,loop_dummy_in,mpar);
                data = cat(ndim_out+2,data,out_tmp.data);
                pb = pb.increment();
            end
            
            
        else
            parfor_progress(n_sinst);
            parfor_progress;
            parfor i_sinst = 2:n_sinst
                
                               
                loop_dummy_in_tmp = loop_dummy_in;%parfor_helper_2ndim(loop_dummy_in,in_data,i_sinst);
                loop_dummy_in_tmp.data = in_data(:,:,:,i_sinst);
                
                out_tmp = feval(fct,loop_dummy_in_tmp,mpar);
                data(:,:,:,i_sinst) = out_tmp.data;
                parfor_progress;
            end
            parfor_progress(0);
            
        end
        
    case 3
        % gen first entry spar for pre allocation
        loop_dummy_in.data = in_data(:,:,:,:,1);
        [out_pre, mpar] = feval(fct,loop_dummy_in,mpar);
        data = out_pre.data;
        out = out_pre;
        out.spar_table = in_s.spar_table;
        out.spar_info = in_s.spar_info;
        ndim_out = out_pre.data_info.ndim;
        clear in_s
        
        if ~parfor_flag
            pb = progressbar(n_sinst, 'exp progress');
            pb = pb.increment();
            for i_sinst = 2:n_sinst
                
                loop_dummy_in.data = in_data(:,:,:,i_sinst);
                
                out_tmp = feval(fct,loop_dummy_in,mpar);
                data = cat(ndim_out+2,data,out_tmp.data);
                pb = pb.increment();
            end
            
            
        else
            parfor_progress(n_sinst);
            parfor_progress;
            parfor i_sinst = 2:n_sinst
                
                               
                loop_dummy_in_tmp = loop_dummy_in;%parfor_helper_2ndim(loop_dummy_in,in_data,i_sinst);
                loop_dummy_in_tmp.data = in_data(:,:,:,i_sinst);
                
                out_tmp = feval(fct,loop_dummy_in_tmp,mpar);
                data(:,:,:,i_sinst) = out_tmp.data;
                parfor_progress;
            end
            parfor_progress(0);
            
        end
        
    otherwise
        error('ndim-case not implemented yet')
end

out.data = data;
end