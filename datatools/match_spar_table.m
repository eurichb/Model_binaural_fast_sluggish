function [struct] = match_spar_table(struct,ref_struct)
% match_spar_table matchs spar table of the STRUCT according to the
% REF_STRUCT. STRUCT could contain more entires, so only the entries from
% REF_STRUCT will be returned.
% [STRUCT] = match_spar_table(STRUCT,REF_STRUCT)
% REF_STRUCT     reference struct (sdf) this will provide spar info
% STRUCT        struct (sdf) this will match the spar to REF_STRUCT
%
% see also get_mpar_matched_index, sdf_info

if ref_struct.data_info.ndim ~= struct.data_info.ndim
    error('ndim needs to be same, other cases not yet implemented')
elseif size(ref_struct.data) ~= size(struct.data)
    error('data are not the same size')
end

%check for same spar_info
[spar_order_clm] = get_spar_matched_index(ref_struct,struct);
%check if each spar entry is unique
if length(unique(spar_order_clm)) ~= length(spar_order_clm)
   error('spar_info contains unique values')    
end

% sort spar_table colums
struct.spar_info(spar_order_clm) = struct.spar_info;
struct.spar_table = struct.spar_table(:,spar_order_clm);




% sort sinst (spar instances) spar_table rows
% [~,spar_order_rows] = ismember(ref_struct.spar_table,struct.spar_table,'rows');
[~,spar_order_rows] = ismembertol(ref_struct.spar_table,struct.spar_table,5e-8,'byrows',true);

if min(spar_order_rows) <= 0
    error('not all rows are found in the ref_struct.spar_tables')
end

struct.spar_table = struct.spar_table(spar_order_rows,:);



%sort data   ONLY FOR NDIM == 1
    if ref_struct.data_info.ndim <= 1

    struct.data = struct.data(:,spar_order_rows);

    else
        error('ndim case not yet implemented')
    end
end