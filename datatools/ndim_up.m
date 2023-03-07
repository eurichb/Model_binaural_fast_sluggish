function sdf = ndim_up(sdf)

sdf.data = permute(sdf.data,[8 1:7]);
sdf.data_info.ndim =1;


end