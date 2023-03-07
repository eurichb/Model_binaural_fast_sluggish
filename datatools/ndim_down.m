function sdf = ndim_down(sdf)


if size(sdf.data,1) == 1
    
    sdf.data = permute(sdf.data,[2:7 1]);
    sdf.data_info.ndim = sdf.data_info.ndim-1;
end

end