% Eurich 2022 binaural model

% function implementing an effective binaural auditory processing model
% Bernhard Eurich, 2022

% INPUT:
% - mpar (struct):                  model parameters
%     - fs:                         sampling frequency of model
%     - Filters_per_ERB_aud :       spacing of peripheral filter central frequencies in ERB
%     - flow:                       lower bound of gammatone filterbank
%     - fhigh:                      higher bound of gammatone filterbank
%     - gtorder:                    filter order of gammatone filters (hohmann2002)
%     - IPDnoise:                   Internal noise affecting the IPD extraction
%     - Dnoise:                     Internal noise affecting the Decision stage
%     - GaussSigma:                 std of Gaussian across-channel smoothing
%     - iKernelThresh               treshold above which a value of the Gaussian filter window is used (below := 0)
%     - n_hcbins                    number of bins to be used in IPD distribution computation via histcounts
%
% - stim:                           four-channel vector containing stimulus (column 1,2) and template (column 3,4); created by calling
%                                   BMLDmodel_stimuli or within the framework by gen_stim_bmld.m

% OUTPUT:
% modelOut (struct) contains:
%


function [out,mpar] = Eurich2022_model_processing(stim,mpar)


% ==== GAMMATONE FILTERBANK ====
sFB = hohmann2002(mpar.fs,mpar.GT_flow,mpar.GT_fbase,mpar.GT_fhigh, mpar.GT_filters_per_ERBaud,'bandwidth_factor',mpar.GT_bwfactor);


%% ==== Peripheral processing for each token seperately, afterwards average ====

numtokens = size(stim.data,2)/2;


for itoken = 1:numtokens
    
    
    
    current_token_stim = stim.data(:,[2*itoken-1 2*itoken]);
    
    % apply gammawarp filterbank on stimulus
    % I changed the filters' center frequencies from 80...8000Hz to 400...600Hz; get center freq with gwarp_CenterFreq
    %     [YBM(:,:,1), ~] = gwarp_CochlearFilter(current_token_stim(:,1),[0 0 0 0 0 0], mpar.GW_num_filters, 65, mpar.fs, 1);
    %     [YBM(:,:,2), ~] = gwarp_CochlearFilter(current_token_stim(:,2),[0 0 0 0 0 0], mpar.GW_num_filters, 65, mpar.fs, 1);
    %
    YBM(:,:,1) = real(hohmann2002_process(sFB,current_token_stim(:,1)));
    YBM(:,:,2) = real(hohmann2002_process(sFB,current_token_stim(:,2)));
    
    numChannels = size(YBM,2);

    %     YBM = permute(YBM,[1 3 2]);
    
    %     YBM = YBM(:,2,:);
    % HWR
%     YBM = max(YBM,0);
    
    % LP
%     [b_coeff,a_coeff] = butter(mpar.hc_lp_n,mpar.hc_lp_fc/(mpar.fs/2));
%     YBM = filter(b_coeff,a_coeff,YBM);
    
    
    % adaptation loops
%     YBM = adaptloop(YBM,mpar.fs,'adt_breebaart2001');
    
    
% analytical signal for Binaural stage
    periph_sig(:,:,itoken) = hilbert(YBM);

    
    % ==== BINAURAL PATHWAY ====

    
    %% ==== MONAURAL PATHWAY ====
    % Envelope power sample-wise
    mMP_leftright = squeeze(  abs(periph_sig(:,:,itoken)) .^2 / 2);
%         mMP_leftright = squeeze(  abs(periph_sig) .^2 / 2);

    % average between left and right
    mMP(:,:,itoken) = nanmean(mMP_leftright,2);
    %% binaural Processing

  

end


filt_left_temp  = periph_sig(:,1,1:end/2);
filt_right_temp = periph_sig(:,2,1:end/2);

filt_left_interval  = periph_sig(:,1,end/2+1:end);
filt_right_interval = periph_sig(:,2,end/2+1:end);

interaural_signal_temp    = (conj(filt_left_temp) .* filt_right_temp) ./ ...
    sqrt( abs( filt_left_temp).^2 .* abs( filt_right_temp).^2);

interaural_signal_interval = mean((conj(filt_left_interval) .* filt_right_interval) ./ ...
    sqrt( abs( filt_left_interval).^2 .* abs( filt_right_interval).^2),3);
    
c_coh = exp(-1./(mpar.fs.*mpar.tau));


filtered_interaural_signal = (filtfilt(1-c_coh,[1 -c_coh],interaural_signal_temp))...
    ./abs(filtfilt(1-c_coh,[1 -c_coh],abs(interaural_signal_temp)));
% % 
filtered_interaural_signal_tokmean   = nanmean(filtered_interaural_signal,3);

zeta_filtered   = atanh(mpar.rho_max .* abs(filtered_interaural_signal_tokmean)) .* exp(1i*angle(filtered_interaural_signal_tokmean));
zeta_unfiltered = atanh(mpar.rho_max .* abs(interaural_signal_interval)) .* exp(1i*angle(interaural_signal_interval));


mMP_tokmean = mean(mMP,3); %(:,1,end/2+1:end)



    

%% Feature Extraction

range_to_evaluate = [1000:length(zeta_unfiltered)]; % 

% binaural
feature_bin = abs(zeta_unfiltered - zeta_filtered);
longest_diff_vector = 2.*max(feature_bin(range_to_evaluate,:));

% monaural
% feature_mon = max(mMP_tokmean - mMP_template_tokmean);


% ==== ROUTE DECISION VALUES TO OUTPUT ====

% [binaural; monaural]
out.data = cat(1,squeeze(longest_diff_vector),mMP_tokmean);
% out.data = gamma_all;

% ==== OUT / INFO ====
out.data_info.fs = mpar.fs;
out.data_info.ndim = 3;
out.data_info.name = {'gamma | energy'};
out.data_info.unit = {''};
% out.data_info.filter_frequencies = sFB.center_frequencies_hz;

out = add_mpar_all(out,mpar);
clear intaur_sig




end

