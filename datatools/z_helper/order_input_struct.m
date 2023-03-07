function [spar,combi,exclude] = order_input_struct(spar)

if ~isfield(spar,'combi')
combi = [];
else
combi = spar.combi;
spar = rmfield(spar,'combi');
end
if ~isfield(spar,'exclude')
exclude = [];
else
exclude = spar.exclude;
spar = rmfield(spar,'exclude');
end

if isfield(spar,'afc')
    spar = rmfield(spar,'afc');
end

end