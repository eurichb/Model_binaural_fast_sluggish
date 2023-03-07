function i_sinst_ref = get_spar_matched_index(sub_struct,ref_struct)
% get_spar_matched_index returns the spar index (i_sinst) of REF_STRUCT
% corresponding to the spar-order of SUB_STRUCT.
%
%I_SINST_REF = get_spar_matched_index(SUB_STRUCT,REF_STRUCT)
%
% see also get_mpar_matched_index, sdf_info

spar_names = {sub_struct.spar_info(:).name};

n_sinst_sub = length(spar_names);

i_sinst_ref = zeros(1,n_sinst_sub);

for i_sinst_sub = 1:n_sinst_sub
    
   index = find(strcmp(spar_names{i_sinst_sub},{ref_struct.spar_info(:).name}) == 1);
    
   if isempty (index)
       i_sinst_ref(i_sinst_sub) = nan;
   else
       i_sinst_ref(i_sinst_sub) = index;
   end
   
end

end
