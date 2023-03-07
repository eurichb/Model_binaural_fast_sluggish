function [out_mean, out_std, out_quart] = z_par_mean_unique(in, sm, output, func)
%
%  see also mpar_mean_unique or spar_mean_unique

if nargin < 3
    output = 0;
    func = @nanmedian;
end

par_table = [sm 'par_table'];
par_info =[sm 'par_info'];

if strcmp(sm,'s')
    par_dim = 2;
elseif strcmp(sm,'m')
    par_dim = 1;
end

n_dim = in.data_info.ndim;
working_dim = n_dim + par_dim;


[all_par_table_entries_matrix,i_unique_data ]= uniquetol(in.(par_table),'byrows',true);

nr_diff_entries = size(all_par_table_entries_matrix,1);


out_data_m = [];
out_data_std = [];
out_data_quart25 = [];
out_data_quart75 = [];

ks_results = [];

for i_spi = 1:nr_diff_entries
    
    i_tmp_matrix = ismember(in.(par_table),all_par_table_entries_matrix(i_spi,:),'rows');
    
    
    if n_dim == 2 && par_dim == 1        
        
        tmp_matrix = in.data(:,:,i_tmp_matrix,:);
                
    elseif n_dim == 1 && par_dim == 1
        tmp_matrix = in.data(:,i_tmp_matrix,:);
        
    elseif n_dim == 0 && par_dim == 1
        tmp_matrix = in.data(i_tmp_matrix,:);  
    
    elseif n_dim == 0 && par_dim == 2
        tmp_matrix = in.data(:,i_tmp_matrix);  
        
    elseif n_dim == 1 && par_dim == 2
        tmp_matrix = in.data(:,:,i_tmp_matrix);
        
    elseif n_dim == 2 && par_dim == 2
        tmp_matrix = in.data(:,:,:,i_tmp_matrix);
        
    elseif n_dim == 3 && par_dim == 2
        tmp_matrix = in.data(:,:,:,:,i_tmp_matrix); 
    else
        error('case not implemented yet')
        
    end
    
    number(i_spi) = size(tmp_matrix,working_dim);
    tmp_data_mean = feval(func,tmp_matrix,working_dim);
    
    tmp_data_quart25 = quantile(tmp_matrix,0.25);
    tmp_data_quart75 = quantile(tmp_matrix,0.75);
    tmp_data_std = nanstd(tmp_matrix,[],working_dim);
    
    
    if tmp_data_std == 0
        if output == 1
            warning('std of data is 0, no ks test done')
        end
    else
        norm_d = (tmp_matrix-tmp_data_mean)./tmp_data_std;
%         h0 = kstest(norm_d);
%         
%         ks_results = [ks_results,h0];
    end

    
    out_data_m = cat(working_dim,out_data_m,tmp_data_mean);
    out_data_std = cat(working_dim,out_data_std,tmp_data_std);
    out_data_quart25 = cat(working_dim,out_data_quart25,tmp_data_quart25);
    out_data_quart75 = cat(working_dim,out_data_quart75,tmp_data_quart75);

    
end

   out_mean = in;
   
   out_mean.(par_table) = in.(par_table)(i_unique_data,:);
   out_mean.data = out_data_m;
    
   out_mean = add_spar(out_mean,number,'n_mean');
   
   out_std = out_mean;
   out_std.data = out_data_std;
   
   out_quart = out_mean;
   out_quart.data = [out_data_quart25; out_data_quart75];
   
%    out_data_quart = 
   
%    if sum(ks_results) ~= 0
%        if output == 1
%            warning('Used data was NOT normal distributed.')
%        end
%    end
%    

end