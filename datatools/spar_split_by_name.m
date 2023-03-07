function [split_list, split_values, num] = spar_split_by_name(result_struct, name)
% spar_split_by_name splits the spike struct using unique ids.
%
%[SPLIT_LIST, SPLIT_VALUES, NUM] = spar_split_by_name(RESULT_STRUCT, NAME)
%
%  Parameters:
%  RESULT_STRUCT    The spike struct (sdf)
%  NAME             The spar name to look for
%
%  Returns:
%  SPLIT_LIST       The split spike structs
%  SPLIT_VALUES     The correspoinding unique values
%  NUM              Index list for SPLIT_VALUES
%
%  see also spar_by_name ,mpar_by_name, mpar_split_by_name, sdf_info

    [split_list, split_values] = z_par_split_by_name(result_struct, name,'s');
    num = 1:length(split_values);
end
