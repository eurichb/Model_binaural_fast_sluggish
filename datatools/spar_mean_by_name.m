function [out, out_std] = spar_mean_by_name(in,name)
%spar_mean_by_name calculate mean over given name while containing all
%other dimensions
%
%   OUT = spar_mean_by_name(IN, NAME)
%
%   [OUT, OUT_STD] = spar_mean_by_name(IN, NAME)
%
%Parameters:
% IN:    struct in sdf
% NAME:  name of par
% OUT:   struct in sdf
% OUT_STD:   struct in sdf containing the std
%
%see also mpar_mean_by_name, sdf_info

[out, out_std] = z_par_mean_by_name(in, name, 's');

end