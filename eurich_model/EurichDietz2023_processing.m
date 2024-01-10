%% model as presented in Eurich & Dietz (2023, JASA) -- processing section

% How to use:
%   - Simulations are started from the scripts "simulate_<experiment>" (e.g., simulate_Siveke2008)).
%   - There, next to experiment-specific preparations, stim_model_function is called to build and process the noise-alone and target-in-noise stimuli
%   - in _processing, a number of tokens for a template (always noise-alone) and a stimulus (noise alone or target-in noise) are compared
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


function [out,mpar] = EurichDietz2023_processing(stim,mpar)


% ==== GAMMATONE FILTERBANK ====
sFB = hohmann2002(mpar.fs,mpar.GT_flow,mpar.GT_fbase,mpar.GT_fhigh, mpar.GT_filters_per_ERBaud,'bandwidth_factor',mpar.GT_bwfactor);


%% ==== Peripheral processing for each token seperately, afterwards average ====

numtokens = size(stim.data,2)/2;


for itoken = 1:numtokens


    current_token_stim = stim.data(:,[2*itoken-1 2*itoken]);

    YBM(:,:,1) = real(hohmann2002_process(sFB,current_token_stim(:,1)));
    YBM(:,:,2) = real(hohmann2002_process(sFB,current_token_stim(:,2)));

    numChannels = size(YBM,2);


    % analytical signal for Binaural stage
    periph_sig(:,:,:,itoken) = hilbert(YBM);



    %% ==== MONAURAL PATHWAY ====

    % Envelope power sample-wise
    mMP_leftright =   abs(periph_sig(:,:,:,itoken)) .^2 / 2;

    % average between left and right
    mMP(:,:,:,itoken) = nanmean(mMP_leftright,3);



end

% averaging across tokens
mMP_tokmean = mean(mMP(:,:,:,end/2+1:end),4); 


% ==== BINAURAL PATHWAY ====
filt_left_temp  = periph_sig(:,:,1,1:end/2);
filt_right_temp = periph_sig(:,:,2,1:end/2);

filt_left_interval  = periph_sig(:,:,1,end/2+1:end);
filt_right_interval = periph_sig(:,:,2,end/2+1:end);

% instantaneous gamma/interaural signals
interaural_signal_temp = (conj(filt_left_temp) .* filt_right_temp) ./ ...
    sqrt( abs( filt_left_temp).^2) .* mean(abs( filt_right_temp).^2);

interaural_signal_interval = mean((conj(filt_left_interval) .* filt_right_interval) ./ ...
    sqrt( abs( filt_left_interval).^2 .* abs( filt_right_interval).^2),4);


% low-pass filtering of template internal representation
c_coh = exp(-1./(mpar.fs.*mpar.tau));

filtered_interaural_signal = mean((filtfilt(1-c_coh,[1 -c_coh],interaural_signal_temp))...
    ./abs(filtfilt(1-c_coh,[1 -c_coh],abs(interaural_signal_temp))),3);


filtered_interaural_signal_tokmean   = nanmean(filtered_interaural_signal,4);

% applying Fisher's z transform and limiting sensitivity (internal noise)
zeta_filtered   = atanh(mpar.rho_max .* abs(filtered_interaural_signal_tokmean)) .* exp(1i*angle(filtered_interaural_signal_tokmean));
zeta_unfiltered = atanh(mpar.rho_max .* abs(interaural_signal_interval)) .* exp(1i*angle(interaural_signal_interval));



%% Feature Extraction

range = mpar.start_evaluate:length(zeta_filtered);

% evaluate complex-valued difference between filtered template and non-filtered stimulus
feature_bin = abs(zeta_unfiltered - zeta_filtered);

% if frame-wise processing is desired (not in Eurich & Dietz 2023), the multiple-looks-based 
% representation is integrated in frames
framel = length(range);


if ~isempty(mpar.FrameLen) & mpar.FrameLen*mpar.fs < framel
    framel = mpar.FrameLen*mpar.fs;
end

for f = 1:floor(length(range)/framel)

    frame = (f-1)*framel+1:f*framel;

    comb_diff_bin_frames(f,:) = sqrt(sum(feature_bin(frame).^2));

end

% the frame with the highest differences between template and stimulus is selected (not reliably tested yet)
comb_diff_bin = max(comb_diff_bin_frames);

% ==== ROUTE DECISION VALUES TO OUTPUT ====

out.data = cat(1,squeeze(comb_diff_bin),mMP_tokmean);

% ==== OUT / INFO ====
out.data_info.fs = mpar.fs;
out.data_info.ndim = 3;
out.data_info.name = {'gamma | energy'};
out.data_info.unit = {''};

out = add_mpar_all(out,mpar);
clear intaur_sig




end

