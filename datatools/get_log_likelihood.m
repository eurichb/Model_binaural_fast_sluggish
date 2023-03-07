function log_likelihood = get_log_likelihood(subject, model, idx_col_spar)
% get_log_likelihood returns the log-likelihood for all mpar instances on
% basis of all given spar instances
%
% LOG_LIKELIHOOD = get_log_likelihood(SUBJECT, MODEL, IDX_COL_SPAR)
% SUBJECT, MODEL    data structs (sdf)
% IDX_COL_SPAR      (optional) index to match spar in MODEL and SUBJECT
%
% see also mbd_llh sdf_info


n_minst = size(model.mpar_table,1);

log_likelihood = zeros(n_minst,1);

% translate used spars to indicies in model.spar_table
if nargin < 3
    idx_col_spar = get_spar_matched_index(subject,model);    
end

[~,v_i_spar] = ismembertol(subject.spar_table,model.spar_table(:,idx_col_spar),eps,'byrows',true);

% pull out model and subject data from struct to speed up calculations
m_data = squeeze(model.data);
s_data = subject.data;

for i_minst = 1:n_minst
    
    model_data = m_data(i_minst,v_i_spar) * 0.99 + 0.005;
    
    log_likelihood(i_minst) = sum(s_data.*log(model_data) + (1-s_data).*log(1-model_data));

end


end