function struct_out = get_mpar_by_name(struct,name,value)

[struct_split, values] = mpar_split_by_name(struct,name);        
struct_out = struct_split(values ==  value);

end