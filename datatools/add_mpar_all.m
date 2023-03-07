function in = add_mpar_all(in,mpar,varargin)
%add_mpar_all(IN,MPAR,EXCEPTIONS) adds all values in MPAR to the mpar-table
%
%see also add_mpar sdf_info

mpar_list = fields(mpar);

for ii = 1:length(varargin)
i_exception = strcmp(varargin{ii},mpar_list);
mpar_list(i_exception) = [];
end   
    
for ii = 1:length(mpar_list)       
   in = add_mpar(in,mpar.(mpar_list{ii}),mpar_list{ii});
end

end