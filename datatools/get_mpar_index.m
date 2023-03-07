function index = get_mpar_index(struct, name)
%get_mpar_index returns the index of the given NAME in mpar_info,
%-1 if NAME is not part of STRUCT.MPAR_INFO
%
%  INDEX = get_mpar_index(STRUCT, NAME)
%
%see also get_spar_index,sdf_info

index = z_get_par_index('m', struct, name);

end