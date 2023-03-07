function index = get_spar_index(struct,name)
%get_spar_index returns the index of the given NAME in spar_info,
%-1 if NAME is not part of STRUCT.SPAR_INFO
%
%  INDEX = get_spar_index(STRUCT, NAME)
%
%see also get_mpar_index, sdf_info

index = z_get_par_index('s',struct,name);

end