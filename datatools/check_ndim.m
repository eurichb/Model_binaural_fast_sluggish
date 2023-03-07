function ids = check_ndim(ids)

if length(size(ids.data)) ==3 && size(ids.data,1) == 1

ids.data = permute(ids.data,[2,3,1]);
ids.data_info.ndim = 0;

end





end