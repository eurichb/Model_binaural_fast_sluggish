function [number_struct, nan_struct] = split_nan_fields(s_in)
%
%
%

nan_struct = [];
in_fields = fields(s_in);
   
   
   for i_field = in_fields'
       field_name = i_field{:};
              
       if isempty(s_in.(field_name)) || ischar(s_in.(field_name)) || isstruct(s_in.(field_name)) || isa(s_in.(field_name),'function_handle')
           
           nan_struct.(field_name) = s_in.(field_name);
       else
           number_struct.(field_name) = s_in.(field_name);
       end       
       
   end

end