function [out_sum] = spar_sum_unique(in)
% spar_sum_unique means all unique mpar instances. 
%   [OUT_SUM] = spar_sum_unique(IN) returns data in result-data-format. 
%   IN is an input in result-data-format. 
%   OUT_SUM sum in rdf
% see also spar_mean_unique

[out_sum] = z_par_mean_unique(in, 's',0,@nansum);

end