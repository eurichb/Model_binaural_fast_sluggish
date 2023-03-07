function spar = z_exclude_spar_inst_from_table(spar,spar_exclude)
% z_exclude_spar_inst_from_table excludes a sinst from the table NOT the
% DATA, usage within run_exp as helper fct


ex_fields = fields(spar_exclude);

%test for same size
d = [];
for dummy_field = ex_fields'
    d = [d length(spar_exclude.(dummy_field{:}))];    
end

if ~(length(unique(d)) == 1)
    error('exclude needs entries with same length')
end


% check all entries
for i_ent = 1:d(1)
        
    
    all_matched_index = [];
    for i_field = 1:length(ex_fields)         
        spar_index = get_spar_index(spar,ex_fields{i_field});
        entry_index = find(spar.spar_table(:,spar_index) == spar_exclude.(ex_fields{i_field})(i_ent));
        all_matched_index = cat(1,all_matched_index,entry_index);      
        
    end
         
    all_possible_index = unique(all_matched_index);

    for idx = 1:length(all_possible_index)
        c(idx) = length(find(all_possible_index(idx)==all_matched_index));
    end

    index_to_remove = all_possible_index(max(c)==c);    

    spar.spar_table(index_to_remove,:) =[];
end



end