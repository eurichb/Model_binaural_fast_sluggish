%% Simulate Kollmeier & Gilkey 1990 with the model as presented in Eurich & Dietz (2023, JASA)
% Bernhard Eurich, 2022/2023
clc
clear
% close
% close allspar_split_by_name(p_correct_median,first_split);
addpath(genpath('/home/eurich/git/modeling_temporal_binaural_processing'))
addpath(genpath('/home/eurich/git/experiment_materials'))
addpath(genpath('/home/eurich/git/gammawarp_filterbank'))
addpath(genpath('/home/eurich/git/medi-basic-methods'))

addpath(genpath('/home/eurich/git/amtoolbox-code'))
% amt_start;

plotting = [1 2];

load_server_data = 0;

%% SPAR

spar = get_spar_KollmeierGilkey90;

%% paths, switches

parfor_flag = 1; % also in stim model function

% first_split = 'noise_mode';
first_split = 'nphase';
% second_split =  'innerbw';
second_split =  'delay_time';

third_split = {'noise_mode','spar'};

%% Definitions
% pc_threshold = 0.707; % Proportion of correct responses to be defined as detection threshold
dprime_threshold =1.14; %0.78; % d' at threshold
mpar = Eurich2023mpar;

%% Experiment-specific internal noise parameter set

mpar.bin_sigma = 12; %0.7; %0.3 
mpar.mon_sigma = 500; %53; %1.8; % 1.8


warning('model parameters have been overwritten')


dprime0 = 0.7; %0.4; 
dprime1 = 20; 
%This means we fit the straight line the a higher excerpt of the psychometric function
% to overcome the problem that there is always some binaural d' when the
% tone is very close to the transition point --> unwanted d' Huckel

mpar.end_evaluate = 35500;

%% processing + feature
stim_model_function = @(spar,mpar)stim_model_function(spar,mpar);

% Noise alone
temp_tone_level = spar.tone_level;
spar.tone_level = -inf;
model_out_reference = run_exp(spar,stim_model_function,mpar,parfor_flag);
% model_out_reference.data = squeeze(model_out_reference.data);

% Signal plus Noise
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
for a = idxs_1 % nphase
    
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
        
        
        for c = idxs_3 % noise_mode
            
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

%             if level
%                 level_thresh(c,b,a) = level(1); %(log10(dprime_threshold) - slope(1,c,b,a)) / slope(2,c,b,a);
%             else
%                 level_thresh(c,b,a) = NaN;
%             end
            
            if isempty(find(split_data(:,c,b,a)>=dprime_threshold))
                warning('d'' did not exceed threshold --> cannot estimate meaningful detection threshold')
               level_thresh(c,b,a) = NaN;
            end
        end
    end
end



% dprime.thresh = level_thresh;
level_thresh
    close all;


% plotting
if ismember(1,plotting)
    
    
    figure
    
    subplot 211
    plot(spar.tone_level,squeeze(split_data(:,1,:)))


    xlabel('tone level / dB SPL')
    ylabel('$d''$')
    dt = num2str(spar.delay_time'*1000);
    lg = legend(dt,'Location','northwest','box','off');
    title(lg,'delay time / ms');
    title('psychometric functions binaural conditions')
    ylim([0 3])
    
    subplot 212
    plot(spar.tone_level,squeeze(split_data(:,2,:)))%     xlabel('delay time / ms')
    xlabel('tone level / dB SPL')
    ylabel('$d''$')
    dt = num2str(spar.delay_time'*1000);
    title('psychometric functions monaural conditions')
        ylim([0 3])


%     
%     sgtitle('Predictions for KG90')
end


if ismember(2,plotting)
    
    if load_server_data
        load('KG90_21-Oct-2022 10:55:34_0.6_1.8_0.03_thresh_spar_mpar.mat')
        fprintf('Loaded server data...\n')
    end
    
    col = colororder;

    % literature data
    panel_a_raw = load('sdf_Kollmeier_Gilkey_1990_Fig2_Panel_a_function_of_delay_time_between_offset_of_the_probe_tone_and_transition_in_the_masker.mat');
    panel_b_raw = load('sdf_Kollmeier_Gilkey_1990_Fig2_Panel_b_function_of_delay_time_between_offset_of_the_probe_tone_and_transition_in_the_masker.mat');
    panel_c_raw = load('sdf_Kollmeier_Gilkey_1990_Fig2_Panel_c_function_of_delay_time_between_offset_of_the_probe_tone_and_transition_in_the_masker.mat');
    panel_d_raw = load('sdf_Kollmeier_Gilkey_1990_Fig2_Panel_d_function_of_delay_time_between_offset_of_the_probe_tone_and_transition_in_the_masker.mat');
    panel_e_raw = load('sdf_Kollmeier_Gilkey_1990_Fig2_Panel_e_function_of_delay_time_between_onset_of_the_probe_tone_and_transition_in_the_masker.mat');
    panel_f_raw = load('sdf_Kollmeier_Gilkey_1990_Fig2_Panel_f_function_of_delay_time_between_onset_of_the_probe_tone_and_transition_in_the_masker.mat');
    panel_g_raw = load('sdf_Kollmeier_Gilkey_1990_Fig2_Panel_g_function_of_delay_time_between_onset_of_the_probe_tone_and_transition_in_the_masker.mat');
    panel_h_raw = load('sdf_Kollmeier_Gilkey_1990_Fig2_Panel_h_function_of_delay_time_between_onset_of_the_probe_tone_and_transition_in_the_masker.mat');
    
    [sdf_split_a,modes] = spar_split_by_name(panel_a_raw.sdf_out,{'configuration of masked threshold'});
    [sdf_split_b,modes] = spar_split_by_name(panel_b_raw.sdf_out,{'configuration of masked threshold'});
    [sdf_split_c,modes] = spar_split_by_name(panel_c_raw.sdf_out,{'configuration of masked threshold'});
    [sdf_split_d,modes] = spar_split_by_name(panel_d_raw.sdf_out,{'configuration of masked threshold'});
    [sdf_split_e,modes] = spar_split_by_name(panel_e_raw.sdf_out,{'configuration of masked threshold'});
    [sdf_split_f,modes] = spar_split_by_name(panel_f_raw.sdf_out,{'configuration of masked threshold'});
    [sdf_split_g,modes] = spar_split_by_name(panel_g_raw.sdf_out,{'configuration of masked threshold'});
    [sdf_split_h,modes] = spar_split_by_name(panel_h_raw.sdf_out,{'configuration of masked threshold'});

    
    f = figure;
    vylim = [-20 5];
    MarkerSize = 3;
    Markers = {'o','v','^','d'};
    
    thresh_rel(1,:,1) = squeeze(level_thresh(1,:,1) - max(level_thresh(1,:,1)));
    thresh_rel(1,:,2) = squeeze(level_thresh(1,:,2) - max(level_thresh(1,:,2)));
    thresh_rel(2,:,1) = squeeze(level_thresh(2,:,1) - max(level_thresh(2,:,1)));
    thresh_rel(2,:,2) = squeeze(level_thresh(2,:,2) - max(level_thresh(2,:,2)));
    
    subplot 211
    hold on;
    %     plot(sdf_split_a(1).spar_table(:,1)*1e3,sdf_split_a(1).data,Markers{1},'MarkerSize',MarkerSize,'MarkerFaceColor',col(1,:))
    %     plot(sdf_split_a(2).spar_table(:,1)*1e3,sdf_split_a(2).data,Markers{1},'MarkerSize',MarkerSize,'MarkerFaceColor','none')
    
    plot(sdf_split_a(1).spar_table(:,1)*1e3,sdf_split_a(1).data,'LineStyle','none','Color',col(1,:),'Marker',Markers{1},'MarkerSize',MarkerSize,'MarkerFaceColor',col(1,:))
    plot(sdf_split_a(2).spar_table(:,1)*1e3,sdf_split_a(2).data,'LineStyle','none','Color',col(1,:),'Marker',Markers{1},'MarkerSize',MarkerSize,'MarkerFaceColor','none')
    plot(sdf_split_b(1).spar_table(:,1)*1e3,sdf_split_b(1).data,'LineStyle','none','Color',col(2,:),'Marker',Markers{2},'MarkerSize',MarkerSize,'MarkerFaceColor',col(2,:))
    plot(sdf_split_b(2).spar_table(:,1)*1e3,sdf_split_b(2).data,'LineStyle','none','Color',col(2,:),'Marker',Markers{2},'MarkerSize',MarkerSize,'MarkerFaceColor','none')
    plot(sdf_split_c(1).spar_table(:,1)*1e3,sdf_split_c(1).data,'LineStyle','none','Color',col(3,:),'Marker',Markers{3},'MarkerSize',MarkerSize,'MarkerFaceColor',col(3,:))
    plot(sdf_split_c(2).spar_table(:,1)*1e3,sdf_split_c(2).data,'LineStyle','none','Color',col(3,:),'Marker',Markers{3},'MarkerSize',MarkerSize,'MarkerFaceColor','none')
    plot(sdf_split_d(1).spar_table(:,1)*1e3,sdf_split_d(1).data,'LineStyle','none','Color',col(4,:),'Marker',Markers{4},'MarkerSize',MarkerSize,'MarkerFaceColor',col(4,:))
    plot(sdf_split_d(2).spar_table(:,1)*1e3,sdf_split_d(2).data,'LineStyle','none','Color',col(4,:),'Marker',Markers{4},'MarkerSize',MarkerSize,'MarkerFaceColor','none')
    
   
    xlim([-220 215])
    ylim(vylim)
    
    % simulations
    plot(spar.delay_time*1e3,squeeze(thresh_rel(1,:,2)),'k');
    plot(spar.delay_time*1e3,squeeze(thresh_rel(2,:,2)),'k','LineStyle','--');

    
    ylabel('Threshold / dB')
    grid on;
    set(gca,'GridLineStyle',':','LineWidth',1)
    
    
    subplot 212
    hold on;
    plot(sdf_split_e(1).spar_table(:,1)*1e3,sdf_split_e(1).data,'LineStyle','none','Color',col(1,:),'Marker',Markers{1},'MarkerSize',MarkerSize,'MarkerFaceColor',col(1,:))
    plot(sdf_split_e(2).spar_table(:,1)*1e3,sdf_split_e(2).data,'LineStyle','none','Color',col(1,:),'Marker',Markers{1},'MarkerSize',MarkerSize,'MarkerFaceColor','none')
    plot(sdf_split_f(1).spar_table(:,1)*1e3,sdf_split_f(1).data,'LineStyle','none','Color',col(2,:),'Marker',Markers{2},'MarkerSize',MarkerSize,'MarkerFaceColor',col(2,:))
    plot(sdf_split_f(2).spar_table(:,1)*1e3,sdf_split_f(2).data,'LineStyle','none','Color',col(2,:),'Marker',Markers{2},'MarkerSize',MarkerSize,'MarkerFaceColor','none')
    plot(sdf_split_g(1).spar_table(:,1)*1e3,sdf_split_g(1).data,'LineStyle','none','Color',col(3,:),'Marker',Markers{3},'MarkerSize',MarkerSize,'MarkerFaceColor',col(3,:))
    plot(sdf_split_g(2).spar_table(:,1)*1e3,sdf_split_g(2).data,'LineStyle','none','Color',col(3,:),'Marker',Markers{3},'MarkerSize',MarkerSize,'MarkerFaceColor','none')
    plot(sdf_split_h(1).spar_table(:,1)*1e3,sdf_split_h(1).data,'LineStyle','none','Color',col(4,:),'Marker',Markers{4},'MarkerSize',MarkerSize,'MarkerFaceColor',col(4,:))
    plot(sdf_split_h(2).spar_table(:,1)*1e3,sdf_split_h(2).data,'LineStyle','none','Color',col(4,:),'Marker',Markers{4},'MarkerSize',MarkerSize,'MarkerFaceColor','none')
    xlim([-310 110])
    
    ylabel('Threshold / dB')
    ylim(vylim)
    xlim([-220 120])

    % simulations
    plot(spar.delay_time*1e3,squeeze(thresh_rel(1,:,1)),'k','Displayname','Model');
    plot(spar.delay_time*1e3,squeeze(thresh_rel(2,:,1)),'k','LineStyle','--');
    
    
    xlabel('delay time / ms')
    grid on;
    set(gca,'GridLineStyle',':','LineWidth',1)
    
      dir = '/home/eurich/Paper2_Plots';
    filename = [dir '/KG90_noframes_long_' datestr(datetime) '_' num2str(mpar.bin_sigma) '_' num2str(mpar.mon_sigma) '_' num2str(mpar.tau) '_' num2str(mpar.FrameLen)];
   %     eportgraphics(f,filename,'ContentType','Vector')
    %print(filename,'-dpng')

save([filename '_thresh_spar_mpar.mat'],'level_thresh','spar','mpar')
   

    style_plot_paper(f,8.2,'AxesSep',0.8,'OneLabelAxis',1,'OneTickAxis',0,'MoveTitle','none',...
        'extra_headroom_cm',0.2,'extra_footroom',1,'FigureRatio',16/20,'FontSize',9)
    
    lg = legend('subj.\,1', '2','3','4','NumColumns',4,'Box','off');

  

    lg.ItemTokenSize(1) = 5;
        lg.Position(1) = 0.6;
    lg.Position(2) = 0.95;
    

end


