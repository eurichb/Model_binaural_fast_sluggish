function [struct1] = stack_fields(struct1,struct2)
%
%
%

if ~isempty(struct2)

in_fields = fields(struct2);
   
   
   for i_field = in_fields'
       field_name = i_field{:};
       
       
           struct1.(field_name) = struct2.(field_name);
       
       
   end
end

end