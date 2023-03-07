function out = z_add_par_info_prefix(out,prefix,sm)


par_info =[sm 'par_info'];


n_par = size(out.(par_info),2);

for i_par = 1:n_par

    old_name = out.(par_info)(i_par).name;
    name = [prefix, old_name];
    out.(par_info)(i_par).name = name;


end
end