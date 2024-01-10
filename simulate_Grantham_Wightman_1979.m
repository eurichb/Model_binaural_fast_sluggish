%% Simulate Grantham & Wightman (1979) with the model as presented in Eurich & Dietz (2023, JASA)

clc
clear
% close
% close allspar_split_by_name(p_correct_median,first_split);
addpath(genpath('/home/eurich/git/modeling_temporal_binaural_processing'))
addpath(genpath('/home/eurich/git/experiment_materials'))
addpath(genpath('/home/eurich/git/amtoolbox-code'))
addpath(genpath('/home/eurich/git/gammawarp_filterbank'))

plotting = [1 2];

% amt_start;

%% SPAR

spar = get_spar_Grantham_Wightman_1979;

%% paths, switches

parfor_flag = 1; % also in stim model function

% first_split = 'noise_mode';
first_split = 'mod_sign';
% second_split =  'innerbw';
second_split =  'f_mod';

third_split = [];%{'IPDnoise','mpar'}; %'flanking_phase';




%% Definitions
% pc_threshold = 0.707; % Proportion of correct responses to be defined as detection threshold
dprime_threshold =0.78; % d' at threshold
mpar = Eurich2022mpar;

mpar.bin_sigma = 20; %1.4; %0.3 
mpar.mon_sigma = 350; % 1.8

warning('model parameters have been overwritten')


mpar.end_evaluate = 48000;


%dprime0 = max(dprime_threshold - dprime_range/2,0.1);
%dprime1 = dprime_threshold + dprime_range/2;
dprime0 = 0;
dprime1 = 10;
% 
% base_name = [num2str(spar.itd(1)) '_-' num2str(spar.itd(end)) '_' num2str(spar.noise_mode) '_' num2str(spar.dbspl_tone(1)) ...
%     '_' num2str(spar.dbspl_tone(end)) '_' num2str(spar.rep(end)) '_' num2str(bmld_mpar.flow) '_' ...
%     num2str(bmld_mpar.fhigh) '_' num2str(bmld_mpar.GaussSigma) '_' num2str(bmld_mpar.IPDnoise) '_' num2str(bmld_mpar.d_stage.Dnoise) '_' num2str(bmld_mpar.d_stage.MPnoise)];
% plot_name = ['./p lots/' base_name];
% % template_name = ['./templates/template_' base_name '.mat'];

%% processing + feature
stim_model_function = @(spar,mpar)stim_model_function(spar,mpar);

% template
temp_tone_level = spar.tone_level;
spar.tone_level = -inf;
model_out_reference = run_exp(spar,stim_model_function,mpar,parfor_flag);
% model_out_reference.data = squeeze(model_out_reference.data);

% stimulus
spar.tone_level = temp_tone_level;
model_out_stimulus = run_exp(spar,stim_model_function,mpar,parfor_flag);
% model_out_stimulus.data = squeeze(model_out_stimulus.data);

%% Decision

[level_split, levels, level_indexes] = spar_split_by_name(model_out_stimulus,'tone_level');

dprime = [];

for ilevel = level_indexes 
    sdf_temp = level_split(ilevel);
    sdf_temp.data = cat(2,sdf_temp.data, model_out_reference.data);
    sdf_temp = run_spar_space(sdf_temp,@Eurich_model_2022_decision,mpar,0);
    dprime = spar_concatenate(dprime,sdf_temp);
end
% Evaluation
clear split_data

% % extract percent correct0
% model_out = del_spar(model_out,'rep');
% 
% [p_correct_mean] = spar_mean_unique(model_out,@nanmedian);

% median
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
            
            
            %             idx0 = find(log10(squeeze(split_data(:,c,b,a))) > dprime0);
             idx0 = find((squeeze(split_data(:,c,b,a))) > dprime0 & (squeeze(split_data(:,c,b,a))) < dprime1);
            
            d_eval = squeeze(log10(split_data(idx0,c,b,a)));
            
            p0 = 20e-6;
            level = spar.tone_level(idx0);
            %             level(:,c,b,a) = (p0 * 10.^(spar.dbspl_tone(idx0) / 20)) ./ val; %
            
            %             fit regression line
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
level_thresh_snr = level_thresh - spar.spl

    close all;

% plotting
if ismember(1,plotting)

    figure
% hold on;
    split_data1 = split_data(:,1,:,1);
    split_data2 = split_data(:,1,:,2);

    subplot 211
    plot(spar.tone_level,squeeze(split_data1))
    hold on;
    plot(spar.tone_level,squeeze(split_data2))

    xlabel('tone level / dB SPL')
    ylabel('$d''$')
    dt = num2str(spar.f_mod');
    lg = legend(dt,'Location','northwest','box','off');
    title(lg, '$f_{mod}$ / Hz' );
    title('psychometric functions')
    
    subplot 212
    
    plot(spar.f_mod,squeeze(level_thresh(1,:,1)))
    hold on;
%     plot(spar.f_mod,squeeze(level_thresh(1,:,2)),'--')

    xlabel('$f_{mod}$ / Hz')
    ylabel('Threshold level / dB SPL')
    title('Detection thresholds for $S\pi$ in noise with oscillating $\rho$')
    
    sgtitle('Predictions for Grantham \& Wightman 1979, Fig.\,8')
end
    
if ismember(2,plotting)
    
%     close all;
    % literature data
    load('home/eurich/git/experiment_materials/Grantham_Wightman1979/sdf_Grantham_and_Wightman_1979_fig8_500Hz')
    [sdf_split,modes] = spar_split_by_name(sdf_out,{'subject and interaural correlation'});

    f = figure;
    col = colororder;
    markers = {'square','o','^'};
    for iplot = 1:size(sdf_split,2)/2
        d(iplot) = plot(sdf_split(2*iplot-1).data,markers{iplot},'Color',col(iplot,:));
        d(iplot).MarkerFaceColor = col(iplot,:);
        d(iplot).MarkerSize = 3;
        hold on;
        e = plot(sdf_split(2*iplot).data,markers{iplot},'Color',col(iplot,:));
        %         e.MarkerSize = 10;
    end
    
    % simulations
    g = plot([1:5],squeeze(level_thresh_snr(1,:,2)),'Color',[0 0 0],'LineStyle','-');
    plot([1:5],squeeze(level_thresh_snr(1,:,1)),'Color',[0 0 0],'LineStyle',':');
    
    xlabel('Modulation Frequency / Hz')
    ylabel('Threshold SNR / dB')
    
    xticks([1 2 3 4 5])
    xticklabels({'0', '0.5','1','2','4'})
    xlim([0.6 5.4])
    
    style_plot_paper(f,8.2,'AxesSep',0.1,'OneLabelAxis',1,'OneTickAxis',1,'MoveTitle','none',...
        'extra_headroom_cm',0.2,'FigureRatio',16/10,'FontSize',8)
    

    lg = legend([d(1), d(2), d(3),g], 'subj.\,KO', 'WG','PK', 'model','Location','Southeast', 'NumColumns',4,'FontSize',8,'Box','off');

%     set(gca,'xscale','log')
    grid on;
    set(gca,'GridLineStyle',':','LineWidth',1)
    % 'Predictions, single-channel','Predictions, incl. interference'
    %     legend boxoff
    %     lg.Position(1) = 0.4;
    %     lg.Position(2) = 0.65;
    lg.ItemTokenSize(1) = 10;
    
    dir = '/home/eurich/Paper2_Plots';
    filename = [dir '/GW79_noframes_' datestr(datetime) '_' num2str(mpar.bin_sigma) '_' num2str(mpar.mon_sigma) '.pdf'];
      %  exportgraphics(f,filename,'ContentType','Vector')
%     print(filename,'-dpng')

%     save([filename '_thresh'],'level_thresh')

%   save([filename '_thresh_spar_mpar.mat'],'level_thresh','spar','mpar')

    
end

