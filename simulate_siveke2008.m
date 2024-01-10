%% Simulate Siveke et al. (2008) with the model as presented in Eurich & Dietz (2023, JASA)

%  Bernhard Eurich, 2022/2023

clc
clear

addpath(genpath('/home/eurich/git/modeling_temporal_binaural_processing'))
addpath(genpath('/home/eurich/git/experiment_materials'))


addpath(genpath('/home/eurich/git/gammawarp_filterbank'))

plotting = [1 2];



%% SPAR

spar = get_spar_siveke2008;

%% paths, switches

parfor_flag = 1;
spar.parfor_flag = parfor_flag;

first_split = 'stim_type'; 
second_split =  'f_mod';

third_split = [];%{'IPDnoise','mpar'}; %'flanking_phase';




%% Definitions
% pc_threshold = 0.707; % Proportion of correct responses to be defined as detection threshold
dprime_threshold = 1.28; % d' at threshold
mpar = Eurich2023mpar;


% when HWR + LP + adaptloop
mpar.bin_sigma = 22; % mega gut mit 1.4 bei 1 Filter/ERB 100...1300Hz, 70 tokens; %0.2 0.47;%2.3;
mpar.mon_sigma = 200;%2.3;

warning('model parameters have been overwritten')


dprime0 = 0;
dprime1 = 5;

mpar.end_evaluate = 40000;



% 
% base_name = [num2str(spar.itd(1)) '_-' num2str(spar.itd(end)) '_' num2str(spar.noise_mode) '_' num2str(spar.dbspl_tone(1)) ...
%     '_' num2str(spar.dbspl_tone(end)) '_' num2str(spar.rep(end)) '_' num2str(bmld_mpar.flow) '_' ...
%     num2str(bmld_mpar.fhigh) '_' num2str(bmld_mpar.GaussSigma) '_' num2str(bmld_mpar.IPDnoise) '_' num2str(bmld_mpar.d_stage.Dnoise) '_' num2str(bmld_mpar.d_stage.MPnoise)];
% plot_name = ['./plots/' base_name];
% % template_name = ['./templates/template_' base_name '.mat'];


%% processing + feature
stim_model_function = @(spar,mpar)stim_model_function_EurichDietz2023(spar,mpar);

% template
temp_f_level = spar.f_level;
spar.f_level = -inf;
model_out_reference = run_exp(spar,stim_model_function,mpar,parfor_flag);
% model_out_reference.data = squeeze(model_out_reference.data);

% stimulus
spar.f_level = temp_f_level;
model_out_stimulus = run_exp(spar,stim_model_function,mpar,parfor_flag);
% model_out_stimulus.data = squeeze(model_out_stimulus.data);

%% Decision

[level_split, levels, level_indexes] = spar_split_by_name(model_out_stimulus,'f_level');

dprime = [];

for ilevel = level_indexes
    
    sdf_temp = level_split(ilevel);
    sdf_temp.data = cat(2,sdf_temp.data, model_out_reference.data);
    sdf_temp = run_spar_space(sdf_temp,@EurichDietz2023_decision,mpar,0);
    dprime = spar_concatenate(dprime,sdf_temp);

end

% convert crossfade ratio level to SMR
flev = spar.f_level;

for fl = 1:length(flev)
    
    f_ratio = 10^(flev(fl)/20);
    testsig = randn(spar.dur*spar.fs,2);
    testsig_spl = set_dbspl(testsig,spar.spl);
    l_uncorr = get_dbspl( testsig_spl(:,1) * (1-f_ratio));
    l_mod = get_dbspl(testsig_spl(:,2) * f_ratio);
    
    spar.SMR(fl) = l_mod - l_uncorr;
end


% Evaluation
clear split_data

% extract percent correct0
% [p_correct_median] = spar_mean_unique(bmld_ou,@nanmedian);


% median
dprime = del_spar(dprime,'rep');
[dprime] = spar_mean_unique(dprime,@nanmedian);



[split_1,vals_1,idxs_1] = spar_split_by_name(dprime,first_split);

% 
% % quartiles
% [split_1_quart,vals_1_quart,idxs_1_quart] = spar_split_by_name(p_correct_quart,'noise_mode');




%     split by delay, write to array 
for a = idxs_1 % sphase
    
    %         median
    [split_2,vals_2,idxs_2] = spar_split_by_name(split_1(a),second_split);

    
    for b = idxs_2 % delay_time
        
        if ~isempty(third_split) && strcmp(third_split{2},'mpar')
            [split_3,vals_3,idxs_3] = mpar_split_by_name(split_2(b),third_split{1});
        elseif ~isempty(third_split) && strcmp(third_split{2},'spar')
            [split_3,vals_3,idxs_3] = spar_split_by_name(split_2(b),third_split{1});
        else
            idxs_3 = 1;
            split_3 = split_2(b);
        end
        
        
        for c = idxs_3 % no third_split here
            
            split_data(:,c,b,a) = squeeze(split_3(c).data); % median
            
            
            idx0 = find((squeeze(split_data(:,c,b,a))) > dprime0 & (squeeze(split_data(:,c,b,a))) < dprime1);
            idx0 = idx0(isfinite(spar.SMR(idx0)));
            
            d_eval = squeeze(log10(split_data(idx0,c,b,a)));
            
            level = spar.SMR(idx0);
%             level = spar.f_level(idx0);
            
            % fit regression line
            d_eval(~isfinite(d_eval)) = NaN;
            level1 = [ones(size(level')) level'];
            slope(:,c,b,a) = level1 \ d_eval;
            d_fit = level1 * slope(:,c,b,a);
            level_thresh(c,b,a) = (log10(dprime_threshold) - slope(1,c,b,a)) / slope(2,c,b,a);
            
            if isempty(find(split_data(:,c,b,a)>=dprime_threshold))
                warning('d'' did not exceed threshold --> cannot estimate meaningful detection threshold')
               level_thresh(c,b,a) = NaN;
            end
            
%             
% figure
% hold on;
% plot(level,d_eval,'o')
% plot(level,zeros(size(level)),'--')
% plot(level,d_fit)
% xlabel('Target Level / dB SPL')
% ylabel('log $d''$')
        end
    end
end


% dprime.thresh = level_thresh;

level_thresh
close all;
    
% plotting
if ismember(1,plotting)
    
    figure
    
    vylim = [0 2];
    squeezed_split_data = squeeze(split_data);
    
    subplot 211
    plot(spar.SMR,squeeze(squeezed_split_data(:,:,1)));
    %ylim(vylim)
    xlabel('SMR / dB')
    ylabel('$d''$')
    lgstr = num2str(spar.f_mod');
    lg = legend(lgstr,'Location','northwest','box','off');
    title(lg,'$f_m$ / Hz')
    title('Psychometric functions Oscor')
    
    subplot 212
    plot(spar.SMR,squeeze(squeezed_split_data(:,:,2)));
    xlabel('SMR / dB')
    ylabel('$d''$')
    %ylim(vylim)
    lgstr = num2str(spar.f_mod');
    lg = legend(lgstr,'Location','northwest','box','off');
    title(lg,'$f_m$ / Hz')
    title('Psychometric functions Phasewarp')
%     plot(spar.f_mod,level_thresh)
%     xlabel('$f_m$ / Hz')
%     ylabel('SMR / dB')
%     xlim([spar.f_mod(1) spar.f_mod(end)])
%     sgtitle('Predictions Siveke $et\ al$ 2008, Oscor')
%     title('Modulation detection thresholds')
end

if ismember(2,plotting)

    
    col = colororder;

    
    f = figure;
    % literature data
    load('home/eurich/git/experiment_materials/Siveke_et_al2008/sdf_Siveke_et_al._-_2008_Fig2_Panel_A.mat')
    % [split_litdata,vals_litdata,idxs_litdata] = spar_split_by_name(sdf_out,first_split);
    [sdf_split,modes] = spar_split_by_name(sdf_out,'Stimulus Type');
    Phasewarp_data = sdf_split(2).data;
    Oscor_data = sdf_split(3).data;
    fm_all = 2.^[3:10];
    semilogx( fm_all(1:5),Oscor_data,'o','MarkerSize',4)
    hold on;
    semilogx( fm_all,Phasewarp_data,'x','MarkerSize',5)
    xticks(fm_all)
    xlim([6 100])
    xlabel('$f_m$ / Hz')
    ylabel('threshold SMR / dB')
    
    % simulations
    plot(spar.f_mod,squeeze(level_thresh(1,:,1)),'color',col(1,:));
    plot(spar.f_mod,squeeze(level_thresh(1,:,2)),'color',col(2,:));

    
    %
    
    style_plot_paper(f,8.2,'AxesSep',0.1,'OneLabelAxis',1,'OneTickAxis',1,'MoveTitle','none',...
        'extra_headroom_cm',0.2,'FigureRatio',16/10,'FontSize',9)
    
    
    lg =legend('Oscor','Phasewarp','location','NorthWest','Box','Off');

    grid on;
    set(gca,'GridLineStyle',':','LineWidth',1)
    % 'Predictions, single-channel','Predictions, incl. interference'
%     legend boxoff
%     lg.Position(1) = 0.4;
%     lg.Position(2) = 0.65;
    lg.ItemTokenSize(1) = 10;
    
    dir = '/home/eurich/Paper2_Plots';
    filename = [dir '/Siveke_noframes_' datestr(datetime) '_' num2str(mpar.bin_sigma) '_' num2str(mpar.mon_sigma) '_' num2str(mpar.FrameLen)];
%     exportgraphics(f,filename,'ContentType','Vector')
% print(filename,'-dpng')
% save([filename '_thresh_spar_mpar_xtended.mat'],'level_thresh','spar','mpar')

    
end

