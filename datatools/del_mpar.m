function struct = del_mpar(struct,name)
%del_mpar delets a stimulus parameter (spar) 
%STRUCT = del_mpar(STRUCT,NAME)
%STRUCT     in sdf
% NAME      string
%
% see also sdf_info del_spar


[ struct ] = z_del_par(struct , name , 'm' );

end