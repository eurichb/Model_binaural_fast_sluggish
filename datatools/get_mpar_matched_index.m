function i_minst_ref = get_mpar_matched_index(sub_struct,ref_struct)
% get_mpar_matched_index returns the mpar index (i_minst) of REF_STRUCT
% corresponding to the mpar order of SUB_STRUCT.
%
%I_MINST_REF = get_mpar_matched_index(SUB_STRUCT,REF_STRUCT)
%
% see also get_mpar_matched_index, sdf_info

mpar_names = {sub_struct.mpar_info(:).name};

n_minst_sub = length(mpar_names);

i_minst_ref = zeros(1,n_minst_sub);

for i_minst_sub = 1:n_minst_sub
    
   index = find(strcmp(mpar_names{i_minst_sub},{ref_struct.mpar_info(:).name}) == 1);
    
   if isempty (index)
       i_minst_ref(i_minst_sub) = nan;
   else
       i_minst_ref(i_minst_sub) = index;
   end
   
end

if isnan(i_minst_ref)
    warning('no match in mpar space')
end

end