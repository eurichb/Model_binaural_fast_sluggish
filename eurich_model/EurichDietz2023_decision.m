%% model as presented in Eurich & Dietz (2023, JASA) -- decision section

% How to use:
%   - Simulations are started from the scripts "simulate_<experiment>" (e.g., simulate_Siveke2008)).
%   - There, next to experiment-specific preparations, stim_model_function is called to build and process the noise-alone and target-in-noise stimuli
%   - for decision processing (comparing processed noise-alone and target-in-noise stimuli), Eurich_model_2022_decision is called
%   - the output is a d' for each condition
%   - Transferring d' to detection thresholds is again done in "simulate_<experiment>"


% This file is licensed unter the GNU General Public License (GPL) either 
% version 3 of the license, or any later version as published by the Free Software 
% Foundation. Details of the GPLv3 can be found in the AMT directory "licences" and 
% at <https://www.gnu.org/licenses/gpl-3.0.html>. 
% You can redistribute this file and/or modify it under the terms of the GPLv3. 
% This file is distributed without any warranty; without even the implied warranty 
% of merchantability or fitness for a particular purpose. 

% INPUT:
% - mpar (struct):                  model parameters
%     - fs:                         sampling frequency of model
%     - GT_Filters_per_ERB_aud :       spacing of peripheral filter central frequencies in ERB (only one filter involved --> default is 1)
%     - GT_low:                     lower bound of gammatone filterbank (only one filter involved --> default is 500)
%     - GT_fbase:                   one filter of gammatone filterbank will be centered here (only one filter involved --> default is 500)
%     - GT_fhigh:                   upper bound of gammatone filterbank (only one filter involved --> default is 500)
%     - gtorder:                    filter order of gammatone filters (hohmann2002); default is 4
%     - tau:                        time constant of low-pass in masker internal representation
%     - rho_max:                    maximum coherence that the model can output (internal noise)
%     - FrameLen:                   Length of backend integration (subsequent to multiple-looks encoding). 
%                                   Default is 1, i.e. no influence in Eurich & Dietz (2023) as stimuli are <1s
%     - bin_sigma:                  standard deviation of simulated internal noise for binaural backend
%    -  mon_sigma:                  standard deviation of simulated internal noise for monaural backend

% - stim (struct)
%     - data:                       matrix with with time samples as rows and n stereo-pairs of columns n tokens 

% OUTPUT:
% out (struct):
%   - data: concatenated binaural (single value) and monaural (instantaneous power) encoded representation
%   - data_info.fs = mpar.fs;
%   - data_info.ndim = 3;
%   - data_info.name = {'gamma | energy'};
%   - data_info.unit = {''};



function [dprime,mpar] = EurichDietz2023_decision(sdf_temp,mpar)


reference_zeta = sdf_temp.data(1,end/2+1:end);
stimulus_zeta  = sdf_temp.data(1,1:end/2);

reference_mon = sdf_temp.data(2:end,end/2+1:end);
stimulus_mon  = sdf_temp.data(2:end,1:end/2);


% binaural d', Internal Noise
dprime_bin_mult = abs(stimulus_zeta - reference_zeta);
dprime_bin = sqrt(sum(dprime_bin_mult.^2))./ mpar.bin_sigma;


% monuaral
range = mpar.start_evaluate:size(stimulus_mon,1);
framel = length(range);

if ~isempty(mpar.FrameLen) && mpar.FrameLen*mpar.fs < framel
    framel = mpar.FrameLen*mpar.fs;
end


for f = 1:floor(length(range)/framel)

    frame = (f-1)*framel+1:f*framel;

    delta_P_frames = stimulus_mon(frame) - reference_mon(frame);

    for filter = 1:size(stimulus_mon,2)
        feature_mon_frame(:,filter) = (delta_P_frames(:,filter) ./ reference_mon(frame,filter));
    end

feature_mon_opt(f) = sqrt(sum(feature_mon_frame.^2));


end

% well, doesn't work multichannel yet, probably not necessary
feature_mon = max(feature_mon_opt,[],2);



%dprime_mon = (feature_mon_frames_opt) ./ mpar.mon_sigma;
dprime_mon = feature_mon ./ mpar.mon_sigma;


% optimal combination of binaural and monaural pathway
dprime_mb = sqrt(dprime_bin.^2 + dprime_mon.^2);


dprime.data = dprime_mb;

% output

dprime.data_info.ndim = 0;
dprime.data_info.name = {'dprime'}; 
dprime = add_mpar_all(dprime,mpar);


end
