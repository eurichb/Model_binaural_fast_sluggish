%% Simulate Dietz 2008, experiment 2
% Bernhard Eurich, 2022
clc
clear
% close
% close all
% spar_split_by_name(p_correct_median,first_split);
addpath(genpath('/home/eurich/git/modeling_temporal_binaural_processing'))
addpath(genpath('/home/eurich/git/experiment_materials'))
% addpath(genpath('/home/eurich/git/amt_code'))
addpath(genpath('/home/eurich/git/amtoolbox-code'))
addpath(genpath('/home/eurich/git/medi-basic-methods'))

% amt_start;
% addpath(genpath('/home/eurich/ownCloud/Home-Cloud/Code/amtoolbox-full-0.10.0/code'));

addpath(genpath('/home/eurich/git/gammawarp_filterbank'))

plotting = 1;



%% SPAR

spar = get_spar_dietz2008;

%% paths, switches

parfor_flag = 1;
spar.parfor_flag = parfor_flag;

first_split = 'stim_type'; % Platzhalter, only need the second_split
second_split =  'f_mod';

third_split = [];%{'IPDnoise','mpar'}; %'flanking_phase';




%% Definitions
% pc_threshold = 0.707; % Proportion of correct responses to be defined as detection threshold
dprime_threshold = 1.28; % d' at threshold
mpar = Eurich2022mpar;
dprime0 = 1;
dprime1 = 10;%10^0.25;


% Parameter adjustment

% mit nur GT
mpar.bin_sigma = 0.18;%2.3;
mpar.mon_sigma = 2; % above around this it is not critical anymore, but keep in mind MP produces some noise

warning('model parameters have been overwritten')


mpar.end_evaluate = 40000;
% 
% base_name = [num2str(spar.itd(1)) '_-' num2str(spar.itd(end)) '_' num2str(spar.noise_mode) '_' num2str(spar.dbspl_tone(1)) ...
%     '_' num2str(spar.dbspl_tone(end)) '_' num2str(spar.rep(end)) '_' num2str(bmld_mpar.flow) '_' ...
%     num2str(bmld_mpar.fhigh) '_' num2str(bmld_mpar.GaussSigma) '_' num2str(bmld_mpar.IPDnoise) '_' num2str(bmld_mpar.d_stage.Dnoise) '_' num2str(bmld_mpar.d_stage.MPnoise)];
% plot_name = ['./plots/' base_name];
% % template_name = ['./templates/template_' base_name '.mat'];


%% processing + feature

stim_model_function = @(spar,mpar)stim_model_function(spar,mpar);

% template
temp_mod_depth = spar.mod_depth;
spar.mod_depth = -inf;
model_out_reference = run_exp(spar,stim_model_function,mpar,parfor_flag);

% stimulus
spar.mod_depth = temp_mod_depth;
model_out_stimulus = run_exp(spar,stim_model_function,mpar,parfor_flag);

%% Decision
close all;

[level_split, levels, level_indexes] = spar_split_by_name(model_out_stimulus,'mod_depth');

dprime = [];

for ilevel = level_indexes 
    sdf_temp = level_split(ilevel);
    sdf_temp.data = cat(2,sdf_temp.data, model_out_reference.data);
    sdf_temp = run_spar_space(sdf_temp,@Eurich_model_2022_decision,mpar,0);
    dprime = spar_concatenate(dprime,sdf_temp);
end

% Evaluation
clear split_data

% extract percent correct0
% [p_correct_median] = spar_mean_unique(bmld_ou,@nanmedian);

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
            
            
            idx0 = find((squeeze(split_data(:,c,b,a))) > dprime0 & (squeeze(split_data(:,c,b,a))) < dprime1);
%             idx0 = idx0(isfinite(spar.SMR(idx0)));
            
            d_eval = squeeze(log10(split_data(idx0,c,b,a)));
            
            level = spar.mod_depth(idx0);
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
    
% plotting
if plotting == 1
    
    figure
    
    subplot 211
    
    squeezed_split_data = squeeze(split_data);
    plot(spar.mod_depth,squeeze(squeezed_split_data(:,:,1)));
%     hold on;
%     plot(spar.mod_depth,squeeze(squeezed_split_data(:,:,2)));
    
    ylabel('modulation depth / dB')
    ylabel('$d''$')
    lgstr = num2str(spar.f_mod');
    lg = legend(lgstr,'Location','northwest','box','off');
    title(lg,'$f_m$ / Hz')
    title('Psychometric functions')
    
    subplot 212
    plot(spar.f_mod,level_thresh,'o','MarkerSize',10)
    xlabel('$f_m$ / Hz')
    ylabel('modulation depth / dB')
    xlim([spar.f_mod(1) spar.f_mod(end)])
    sgtitle('Predictions Dietz $et\ al$ 2008, Phasewarp $\leq 550$\,Hz')
    title('Modulation detection thresholds')
    
elseif plotting == 2
    
    % von Hand
    fm_all = [10 50 75];
    Dietz2008PWdata = [-7 -4 -1.8];
    
    % convert mod_depth to SMR
    m = 10.^(spar.mod_depth / 20);
    f_ratio = 1./(1+sqrt(1./m - 1));
    
    
for fl = 1:length(spar.mod_depth)
    
    testsig = randn(spar.dur*spar.fs,2);
    testsig_spl = set_dbspl(testsig,spar.spl);
    l_uncorr = get_dbspl( testsig_spl(:,1) * (1-f_ratio(fl)));
    l_mod = get_dbspl(testsig_spl(:,2) * f_ratio(fl));
    
    spar.SMR(fl) = l_mod - l_uncorr;
end

% plot stuff
    
    col = colororder;

    
    f = figure;
    % literature data

    plot( fm_all,Dietz2008PWdata,'x','MarkerSize',5)
    hold on;
    xticks(fm_all)
    xlabel('$f_m$ / Hz')
    ylabel('Modulation Depth / dB')
    
    % simulations
    plot(spar.f_mod,squeeze(level_thresh(1,:,1)),'color',col(1,:));
  
    
    
    style_plot_paper(f,8.2,'AxesSep',0.1,'OneLabelAxis',1,'OneTickAxis',1,'MoveTitle','none',...
        'extra_headroom_cm',0.2,'FigureRatio',16/10,'FontSize',9)
    
    
%     lg =legend('Oscor','Phasewarp','location','NorthWest','Box','Off');

    grid on;
    set(gca,'GridLineStyle',':','LineWidth',1)
    % 'Predictions, single-channel','Predictions, incl. interference'
%     legend boxoff
%     lg.Position(1) = 0.4;
%     lg.Position(2) = 0.65;
    lg.ItemTokenSize(1) = 10;
    
    dir = '/home/eurich/Paper2_Plots';
    filename = [num2str(dir) '/Dietz_' num2str(mpar.bin_sigma)];
%     exportgraphics(f,filename,'ContentType','Vector')
print(filename,'-dpng')

% savefig([dir '/Dietz08'])
save([filename '_thresh'],'level_thresh')

end

