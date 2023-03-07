function out = get_val_by_spar(sdf,name,val)

[split,vals] = spar_split_by_name(sdf,name);
out = split(vals == val).data;

end