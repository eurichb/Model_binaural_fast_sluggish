function [all_inst_par, inst_m_out, n_combi_out, sdf_s] = set_spar_table(spar,spar_combi, spar_exclude)
% set_spar_table arranges the spar table with all combinations in PAR
% combined with the list in SPAR_COMBI
%
%[ALL_INST_PAR, INST_M, N_COMBI, SDF_S] = set_spar_table(SPAR, SPAR_COMBI)
%SPAR           spar struct , all vectorized entires are used to build
%               different combinations
%SPAR_COMBI     spar struct, vectorized entries should have same number of
%               values, this fixed combinations are combined with all
%               combinations from PAR
%ALL_INST_PAR   struct with combination entrys, each containing par for one inst
%INST_M         matrix with dim N_COMBI x n_par, Spar table with all combinations
%N_COMBI        number of combinations
%SDF_S          struct with spar_info + spar_table
%
% see also get_all_combinations, sdf_info

[all_inst_par, inst_m_in] = get_all_combinations(spar);

if nargin >= 2 && ~isempty(spar_combi)

spars = fields(spar_combi);

% build spar tabel
n_combi_par = length(spars);
n_combis = length(spar_combi.(spars{1}));

n_par_in = size(inst_m_in,2);
n_par_out = n_par_in + n_combi_par;
n_inst_in = size(inst_m_in,1);
n_inst_out = n_inst_in * n_combis ;
i_inst_out = 1;

inst_m_out = zeros(n_inst_out,n_par_out);

for i_combi = 1:n_combis
    for i_inst_in = 1:n_inst_in
        
        inst_m_out(i_inst_out,1:n_par_in) = inst_m_in(i_inst_in,:);
        
        for i_combi_par = 1:n_combi_par
            
            inst_m_out(i_inst_out,n_par_in+i_combi_par) = spar_combi.(spars{i_combi_par})(i_combi);
        end
                
        i_inst_out = i_inst_out+1;
        
    end
end
inst_cell = num2cell(inst_m_out);


% build spar info
list_par = fields(all_inst_par(1));
for i_combi_par = 1:n_combi_par            
     list_par{n_par_in+i_combi_par} = spars{i_combi_par};
end

all_inst_par = cell2struct(inst_cell,list_par,2);

else    
    inst_m_out = inst_m_in;
    
end

sdf_s = spar_struct_to_table([],all_inst_par(1));
    sdf_s.spar_table = inst_m_out;
  
    
    
% to exclude spar combis    
if nargin == 3 && ~isempty(spar_exclude)   
    sdf_s = z_exclude_spar_inst_from_table(sdf_s,spar_exclude);
    inst_m_out = sdf_s.spar_table;
    inst_cell = num2cell(inst_m_out );
    all_inst_par = cell2struct(inst_cell,list_par,2);
    
end
    
n_combi_out = length(all_inst_par);
end









