function [out_mean, out_std, out_quart] = spar_mean_unique(in,func)
% spar_mean_unique means all unique mpar instances. 
%   [OUT_MEAN, OUT_STD] = spar_mean_unique(IN) returns data in result-data-format. 
%   IN is an input in result-data-format. 
%   OUT_MEAN mean value in rdf
%   OUT_STD std value in rdf
% see also mpar_mean_unique

[out_mean, out_std, out_quart] = z_par_mean_unique(in, 's',0,func);

end