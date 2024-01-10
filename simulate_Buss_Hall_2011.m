%% Simulate Buss & Hall (2011) with the model as presented in Eurich & Dietz (2023, JASA)

%  Bernhard Eurich, 2022/2023
clc
clear
% close
% close allspar_split_by_name(p_correct_median,first_split);
addpath(genpath('/home/eurich/git/modeling_temporal_binaural_processing'))
addpath(genpath('/home/eurich/git/experiment_materials'))
addpath(genpath('/home/eurich/git/amtoolbox-code'))
addpath(genpath('/home/eurich/git/gammawarp_filterbank'))
% amt_start;

plotting = 2;



%% SPAR

spar = get_spar_Buss_Hall_2011;

%% paths, switches

parfor_flag = 1; % also in stim model function

% first_split = 'noise_mode';
first_split = 'sphase';
% second_split =  'innerbw';
second_split =  'gap_interval';

third_split = {'unsymm','spar'};%{'IPDnoise','mpar'}; %'flanking_phase';




%% Definitions
% pc_threshold = 0.707; % Proportion of correct responses to be defined as detection threshold
dprime_threshold =1.61; % d' at threshold
mpar = Eurich2022mpar;

warning('model parameters have been overwritten')

% mit nur GT
mpar.bin_sigma = 20; %40; %1.6;
mpar.mon_sigma = 200;%1.3;%2.41;


% dprime0 = 0;
% dprime1 = 1;

dprime_range = 20;

dprime0 = max(dprime_threshold - dprime_range/2,0.1);
dprime1 = dprime_threshold + dprime_range/2;

mpar.end_evaluate = mpar.fs;


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

mpar.end_evaluate = mpar.fs;


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

    
    for b = idxs_2 % gap_interval
        
        if ~isempty(third_split) && strcmp(third_split{2},'mpar')
            [split_3,vals_3,idxs_3] = mpar_split_by_name(split_2(b),third_split{1});
        elseif ~isempty(third_split) && strcmp(third_split{2},'spar')
            [split_3,vals_3,idxs_3] = spar_split_by_name(split_2(b),third_split{1});
        else
            idxs_3 = 1;
            split_3 = split_2(b);
        end
        
        
        for c = idxs_3 % unsym
            
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
level_thresh

    
% plotting
close all;
if ismember(1,plotting)
    
    figure
    
    subplot 211 
    
    plot(spar.tone_level,squeeze(split_data(:,1,:,2)))
    hold on;
    plot(spar.tone_level,squeeze(split_data(:,2,:,2)))
    plot(spar.tone_level,squeeze(split_data(:,3,:,2)))

    xlabel('tone level / dB SPL')
    ylabel('$d''$')
    dt = num2str(spar.gap_interval'*1000);
    lg = legend(dt,'Location','northwest','box','off');
    title(lg,'first half dip duration / ms');
    title('psychometric functions $N0S0$')
    
    subplot 212
    plot(spar.tone_level,squeeze(split_data(:,1,:,1)))
    hold on;
    plot(spar.tone_level,squeeze(split_data(:,2,:,1)))
    plot(spar.tone_level,squeeze(split_data(:,3,:,1)))


    xlabel('tone level / dB SPL')
    ylabel('$d''$')
    dt = num2str(spar.gap_interval'*1000);
    lg = legend(dt,'Location','northwest','box','off');
    title(lg,'first half dip duration / ms');
    title('psychometric functions $N0S\pi$')
    
    sgtitle('Predictions for Buss \& Hall 2011, Exp. 1')
    
end
if ismember(2,plotting)
    

    
    % literature data
    
    f = figure;
    col = colororder;
    markers = {'o','^','v','o','d'};
    sNoSpi = load('home/eurich/git/experiment_materials/Buss_Hall2011/sdf_Buss_Hall2011_fig2_NoSpi');
    sNoSo  = load('home/eurich/git/experiment_materials/Buss_Hall2011/sdf_Buss_Hall2011_fig2_NoSo');
    
    [sdf_split_NoSpi,modes] = spar_split_by_name(sNoSpi.sdf_out,{'signal symmetry'});
    [sdf_split_NoSo,modes] = spar_split_by_name(sNoSo.sdf_out,{'signal symmetry'});
    
    if find(spar.sphase == 1)
        
        % NOSO
        subplot 211
        hold on;
        for iplot = 1:size(sdf_split_NoSo,2)
            d(iplot) = plot(sdf_split_NoSo(iplot).spar_table(:,1)*1e3, sdf_split_NoSo(iplot).data,markers{iplot},'Color',col(iplot,:));
            d(iplot).MarkerFaceColor = col(iplot,:);
            d(iplot).MarkerSize = 3;
            
        end
        
        % simulations
    g1 = plot(spar.gap_interval*1e3,squeeze(level_thresh(1,:,2)),'LineStyle','-','Color',col(1,:));
    g2 = plot(spar.gap_interval*1e3,squeeze(level_thresh(2,:,2)),'LineStyle','-','Color',col(2,:));
    g3 = plot(spar.gap_interval*1e3,squeeze(level_thresh(3,:,2)),'LineStyle','-','Color',col(3,:));
        %
        xlabel('Minimum signal/masker interval / ms')
        ylabel('Threshold / dB SPL')
        
        xlim([-10 210])
        
        grid on;
        set(gca,'GridLineStyle',':','LineWidth',1)
        
        
        subplot 212
    end
    
    
    % N0Spi
    for iplot = 1:size(sdf_split_NoSpi,2)
        d(iplot) = plot(sdf_split_NoSpi(iplot).spar_table(:,1)*1e3, sdf_split_NoSpi(iplot).data,markers{iplot},'Color',col(iplot,:));
        d(iplot).MarkerFaceColor = col(iplot,:);
        d(iplot).MarkerSize = 3;
        hold on;
    end
    
    % simulations
    g1 = plot(spar.gap_interval*1e3,squeeze(level_thresh(1,:,1)),'LineStyle','-','Color',col(1,:));
    g2 = plot(spar.gap_interval*1e3,squeeze(level_thresh(2,:,1)),'LineStyle','-','Color',col(2,:));
    g3 = plot(spar.gap_interval*1e3,squeeze(level_thresh(3,:,1)),'LineStyle','-','Color',col(3,:));


    %     g = plot([1:5],squeeze(level_thresh_snr(1,:,2)),'Color',[0 0 0],'LineStyle','-');
    %     plot([1:5],squeeze(level_thresh_snr(1,:,1)),'Color',[0 0 0],'LineStyle',':');
    %
    xlabel('Minimum signal/masker interval / ms')
    ylabel('Threshold / dB SPL')
    
    xlim([-10 210])
    
    grid on;
    set(gca,'GridLineStyle',':','LineWidth',1)
    
    
    annotation('textbox',[.85 .1 .1 .65],'String','$S_{0}$','interpreter','Latex','EdgeColor',[1 1 1])
    annotation('textbox',[.85 .1 .1 .25],'String','$S_{\pi}$','interpreter','Latex','EdgeColor',[1 1 1])

    
    style_plot_paper(f,8.2,'AxesSep',0.4,'OneLabelAxis',1,'OneTickAxis',1,'MoveTitle','none',...
        'extra_headroom_cm',0.2,'extra_footroom',1,'FigureRatio',16/20,'FontSize',9)
    
    
    lg = legend([d(1), d(2), d(3),g1], '$t1 = t2$', '$t1 < t2$', '$t1 > t2$', 'model','Location','Northeast', 'NumColumns',2,'FontSize',8,'Box','off');
    
    
    %     set(gca,'xscale','log')
    
    % 'Predictions, single-channel','Predictions, incl. interference'
    %     legend boxoff
    lg.Position(1) = 0.55;
    lg.Position(2) = 0.88;
    lg.ItemTokenSize(1) = 10;
    
    dir = '/home/eurich/Paper2_Plots';
        filename = [dir '/BH11_noframes' datestr(datetime) '_' num2str(mpar.bin_sigma) '_' num2str(mpar.mon_sigma)];
    %     exportgraphics(f,filename,'ContentType','Vector')
%         print(filename,'-dpng')
    
%     savefig([dir '/BussHall11'])
    
    save([filename '_thresh_spar_mpar.mat'],'level_thresh','spar','mpar')

   
    
end
