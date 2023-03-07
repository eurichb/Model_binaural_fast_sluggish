function [dprime,mpar] = Eurich_model_2022_decision(sdf_temp,mpar)


reference_zeta = sdf_temp.data(1,2);
stimulus_zeta  = sdf_temp.data(1,1);

reference_mon = sdf_temp.data(2:end,2);
stimulus_mon  = sdf_temp.data(2:end,1);


% binaural d', Internal Noise
dprime_bin = (stimulus_zeta - reference_zeta) ./ mpar.bin_sigma;


% monuaral
delta_P = stimulus_mon - reference_mon;
% 

for filter = 1:size(stimulus_mon,2)
    feature_mon(:,filter) = (delta_P(:,filter) ./ mean([stimulus_mon(:,filter) reference_mon(:,filter)],2));
end

if isfield(mpar,'fcidx')
    feature_mon_frames_opt = feauture_mon(:,1,mpar.fcidx);
else
    feature_mon_frames_opt = sqrt(sum(feature_mon.^2,2));
end


dprime_mon = max(feature_mon_frames_opt) ./ mpar.mon_sigma;

% optimal combination of binaural and monaural pathway
dprime_mb = sqrt(dprime_bin.^2 + dprime_mon.^2);


dprime.data =  dprime_mb;

% output

dprime.data_info.ndim = 0;
dprime.data_info.name = {'dprime'}; 
dprime = add_mpar_all(dprime,mpar);


end
