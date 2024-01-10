%% Results plot as presented in Eurich & Dietz (2023, JASA)
close all; clear;

col = colororder;

addpath(genpath('/home/eurich/git/modeling_temporal_binaural_processing'));
addpath(genpath('/home/eurich/git/experiment_materials'));

export_graphics = 0;

headroom = 0.5;
lg_fontsize =9;
lb_fontsize = 11;
t_fontsize = 11;


path_to_save_figs = '/home/eurich/git/Eurich&Dietz2023/Figures/';


f1 = figure('Position',[0.3 0.3 1000 750]);
T = tiledlayout(3,3);
T.TileSpacing = 'compact';
T.Padding = 'compact';
grid_linewidth = 1.4;


% Hint: To make it look as nice as in the article Eurich & Dietz (2023, JASA), all interpreters have to be set to 'LaTeX'.

%% KG90

load('./Results/KG90_noframes_15-May-2023 11:48:24_12_500_0.03_1_thresh_spar_mpar.mat')


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



vylim = [-20 5];
MarkerSize = 3;
Markers = {'o','v','^','d'};

thresh_rel(1,:,1) = squeeze(level_thresh(1,:,1) - max(level_thresh(1,end,1)));
thresh_rel(1,:,2) = squeeze(level_thresh(1,:,2) - max(level_thresh(1,1,2)));
thresh_rel(2,:,1) = squeeze(level_thresh(2,:,1) - max(level_thresh(2,end,1)));
thresh_rel(2,:,2) = squeeze(level_thresh(2,:,2) - max(level_thresh(2,1,2)));


vxlim = [-200 200];
vylim = [-20 5];

vxticks = [-200 -100 0 100 200];
vylim = [-20 5];
vyticks = [-20:5:5];
vxticks0 = [];
vyticks0 = [];


scattersize = 20;
scatterlinewidth0 = 1.4;
scatterlinewidth = 0.8;

t1 = tiledlayout(T,2,2);
t1.Layout.Tile = 1;
t1.Layout.TileSpan = [2 2];
t1.TileSpacing = 'compact';


nexttile(t1);
hold on;

s(2) = scatter(sdf_split_a(1).spar_table(:,1)*1e3,sdf_split_a(1).data,scattersize,'MarkerEdgeColor',col(1,:),'Marker',Markers{1},'MarkerFaceColor',col(1,:),'LineWidth',scatterlinewidth,'Displayname', 'subj.\,1');
s(4) = scatter(sdf_split_b(1).spar_table(:,1)*1e3,sdf_split_b(1).data,scattersize,'MarkerEdgeColor',col(2,:),'Marker',Markers{2},'MarkerFaceColor',col(2,:),'LineWidth',scatterlinewidth,'Displayname', '2');
s(6) = scatter(sdf_split_c(1).spar_table(:,1)*1e3,sdf_split_c(1).data,scattersize,'MarkerEdgeColor',col(3,:),'Marker',Markers{3},'MarkerFaceColor',col(3,:),'LineWidth',scatterlinewidth,'Displayname', '3');
s(8) = scatter(sdf_split_d(1).spar_table(:,1)*1e3,sdf_split_d(1).data,scattersize,'MarkerEdgeColor',col(4,:),'Marker',Markers{4},'MarkerFaceColor',col(4,:),'LineWidth',scatterlinewidth,'Displayname', '4');

xlim(vxlim)
ylim(vylim)



% simulations
plot(spar.delay_time*1e3,squeeze(thresh_rel(1,:,2)),'k','DisplayName','');

% ylabel('Threshold / dB')
grid on;
set(gca,'GridLineStyle',':','LineWidth',grid_linewidth)


nexttile(t1)
hold on;

s(10) = scatter(sdf_split_e(1).spar_table(:,1)*1e3,sdf_split_e(1).data,scattersize,'MarkerEdgeColor',col(1,:),'Marker',Markers{1},'MarkerFaceColor',col(1,:),'LineWidth',scatterlinewidth,'Displayname', 'subj.\,1');
s(12) = scatter(sdf_split_f(1).spar_table(:,1)*1e3,sdf_split_f(1).data,scattersize,'MarkerEdgeColor',col(2,:),'Marker',Markers{2},'MarkerFaceColor',col(2,:),'LineWidth',scatterlinewidth,'Displayname', '2');
s(14) = scatter(sdf_split_g(1).spar_table(:,1)*1e3,sdf_split_g(1).data,scattersize,'MarkerEdgeColor',col(3,:),'Marker',Markers{3},'MarkerFaceColor',col(3,:),'LineWidth',scatterlinewidth,'Displayname', '3');
s(16) = scatter(sdf_split_h(1).spar_table(:,1)*1e3,sdf_split_h(1).data,scattersize,'MarkerEdgeColor',col(4,:),'Marker',Markers{4},'MarkerFaceColor',col(4,:),'LineWidth',scatterlinewidth,'Displayname', '4');

plot(spar.delay_time*1e3,squeeze(thresh_rel(1,:,1)),'k','Displayname','none');
xlim(vxlim)
ylim(vylim)


grid on;
set(gca,'GridLineStyle',':','LineWidth',grid_linewidth)
lg = legend(s([10 12 14 16]),'NumColumns',4,'Box','off','Location','Southeast');



nexttile(t1)

hold on;

s(1) = scatter(sdf_split_a(2).spar_table(:,1)*1e3,sdf_split_a(2).data,scattersize,'MarkerEdgeColor',col(1,:),'Marker',Markers{1},'MarkerFaceColor','none','LineWidth',scatterlinewidth0,'Displayname','');
s(3) = scatter(sdf_split_b(2).spar_table(:,1)*1e3,sdf_split_b(2).data,scattersize,'MarkerEdgeColor',col(2,:),'Marker',Markers{2},'MarkerFaceColor','none','LineWidth',scatterlinewidth0,'Displayname','');
s(5) = scatter(sdf_split_c(2).spar_table(:,1)*1e3,sdf_split_c(2).data,scattersize,'MarkerEdgeColor',col(3,:),'Marker',Markers{3},'MarkerFaceColor','none','LineWidth',scatterlinewidth0,'Displayname','');
s(7) = scatter(sdf_split_d(2).spar_table(:,1)*1e3,sdf_split_d(2).data,scattersize,'MarkerEdgeColor',col(4,:),'Marker',Markers{4},'MarkerFaceColor','none','LineWidth',scatterlinewidth0,'Displayname','');

plot(spar.delay_time*1e3,squeeze(thresh_rel(2,:,2)),'k','LineStyle','--','DisplayName','None');
xlim(vxlim)
ylim(vylim)



grid on;
set(gca,'GridLineStyle',':','LineWidth',grid_linewidth)
set(gca, 'TickLength', [0 0]);


nexttile(t1)
hold on;
s(9) = scatter(sdf_split_e(2).spar_table(:,1)*1e3,sdf_split_e(2).data,scattersize,'MarkerEdgeColor',col(1,:),'Marker',Markers{1},'MarkerFaceColor','none','LineWidth',scatterlinewidth0,'Displayname', 'sub.\,1');
s(11) = scatter(sdf_split_f(2).spar_table(:,1)*1e3,sdf_split_f(2).data,scattersize,'MarkerEdgeColor',col(2,:),'Marker',Markers{2},'MarkerFaceColor','none','LineWidth',scatterlinewidth0,'Displayname', '2');
s(13) = scatter(sdf_split_g(2).spar_table(:,1)*1e3,sdf_split_g(2).data,scattersize,'MarkerEdgeColor',col(3,:),'Marker',Markers{3},'MarkerFaceColor','none','LineWidth',scatterlinewidth0,'Displayname', '3');
s(15) = scatter(sdf_split_h(2).spar_table(:,1)*1e3,sdf_split_h(2).data,scattersize,'MarkerEdgeColor',col(4,:),'Marker',Markers{4},'MarkerFaceColor','none','LineWidth',scatterlinewidth0,'Displayname', '4');


ylim(vylim)
xlim(vxlim)


grid on;
set(gca,'GridLineStyle',':','LineWidth',grid_linewidth)

% simulations
plot(spar.delay_time*1e3,squeeze(thresh_rel(2,:,1)),'k','LineStyle','--');


grid on;
set(gca,'GridLineStyle',':','LineWidth',grid_linewidth)

lg.ItemTokenSize(1) = 10;
lg.FontSize = lg_fontsize;
lg.Position(1) = 0.71;
lg.Position(2) = 0.57;

annotation('textbox',[.08 .73 .01 .01],'String','$N_{\pi} N_0 S_{\pi}$','interpreter','Latex','EdgeColor',[1 1 1])
annotation('textbox',[.38 .73 .01 .01],'String','$N_0 N_{\pi} S_{\pi}$','interpreter','Latex','EdgeColor',[1 1 1])

annotation('textbox',[.08 .43 .01 .01],'String','$N_{\pi} N_{\pi}(-15\,\textrm{dB}) S_{\pi}$','interpreter','Latex','EdgeColor',[1 1 1])
annotation('textbox',[.38 .43 .01 .01],'String','$ N_{\pi}(-15\,\textrm{dB}) N_{\pi} S_{\pi}$','interpreter','Latex','EdgeColor',[1 1 1])


title(t1,'Kollmeier \& Gilkey, 1990','Interpreter','Latex','Fontsize',t_fontsize)
xlabel(t1,'Delay Time / ms','Interpreter','Latex','Fontsize',lb_fontsize)
ylabel(t1,'Threshold / dB','Interpreter','Latex','Fontsize',lb_fontsize)



%%%%%%%%%%%%%
load('matrix_KollmeierGilkey_1990.mat')
kg90 = NaN(20,4);


thresh_rel_NaN = NaN(size(kg90));
thresh_rel_NaN(1,1:size(thresh_rel,2),1) = level_thresh(1,:,1)';



%% GW79
nexttile(T,7)
load('./Results/GW79_noframes_15-May-2023 13:33:44_20_350.pdf_thresh_spar_mpar.mat')
load('/home/eurich/git/experiment_materials/Grantham_Wightman1979/sdf_Grantham_and_Wightman_1979_fig8_500Hz')

[sdf_split,modes] = spar_split_by_name(sdf_out,{'subject and interaural correlation'});

col = colororder;
markers = {'square','o','^'};
for iplot = 1:size(sdf_split,2)/2
    d(iplot) = scatter([1 2 3 4 5],sdf_split(2*iplot-1).data,20,'Marker',markers{iplot},'MarkerEdgeColor',col(iplot,:));
    
    d(iplot).MarkerFaceColor = col(iplot,:);
    hold on;
    e(iplot)= scatter([1 2 3 4 5],sdf_split(2*iplot).data,20,'Marker',markers{iplot},'MarkerEdgeColor',col(iplot,:));
end

level_thresh_snr = level_thresh - spar.spl

% simulations
g = plot([1:5],squeeze(level_thresh_snr(1,:,2)),'Color',[0 0 0],'LineStyle','-','Displayname','none');
plot([1:5],squeeze(level_thresh_snr(1,:,1)),'Color',[0 0 0],'LineStyle','--','Displayname','none');

xlabel('Modulation Frequency / Hz','Fontsize',lb_fontsize)
ylabel('Threshold SNR / dB','Fontsize',lb_fontsize)

xticks([1 2 3 4 5])
xticklabels({'0', '0.5','1','2','4'})
ylim([-15 12])
xlim([0.6 5.4])

title('Grantham \& Wightman, 1979','Fontsize',t_fontsize)

lg = legend([d(1), d(2), d(3),g], 'subj.\,KO', 'WG','PK','Location','Southeast', 'NumColumns',4,'Box','off');

%     set(gca,'xscale','log')
grid on;
set(gca,'GridLineStyle',':','LineWidth',grid_linewidth)

lg.Position(1) = 0.15;
lg.Position(2) = 0.07;
lg.ItemTokenSize(1) = 10;
lg.FontSize = lg_fontsize;

% statistics
p(:,1) = squeeze(level_thresh_snr(1,:,2));
p(:,2) = squeeze(level_thresh_snr(1,:,1));

for iplot = 1:size(sdf_split,2)/2
    raw_pi(:,iplot) = sdf_split(2*iplot-1).data;
    raw_0(:,iplot) = sdf_split(2*iplot).data;
end

clear p
data(:,2) = mean(raw_pi,2);
data(:,1) = mean(raw_0,2);
p = squeeze(level_thresh_snr);


var_exp_GW79     = 1- nansum((data-p   ).^2) ./ nansum((data-mean(data)).^2);

RMSE_GW79 = mean(sqrt(mean((p - data).^2)));


%% Buss & Hall 2011
t2 = tiledlayout(T,2,1);
t2.Layout.Tile = 3;
t2.Layout.TileSpan = [2 1];
t2.TileSpacing = 'compact';

nexttile(t2)
col = colororder;
markers = {'o','^','v','o','d'};


load('./Results/BH11_noframes15-May-2023 13:44:54_20_200_thresh_spar_mpar.mat')


sNoSpi = load('home/eurich/git/experiment_materials/Buss_Hall2011/sdf_Buss_Hall2011_fig2_NoSpi');
sNoSo  = load('home/eurich/git/experiment_materials/Buss_Hall2011/sdf_Buss_Hall2011_fig2_NoSo');

[sdf_split_NoSpi,modes] = spar_split_by_name(sNoSpi.sdf_out,{'signal symmetry'});
[sdf_split_NoSo,modes]  = spar_split_by_name(sNoSo.sdf_out, {'signal symmetry'});

static_NoSpi = mean([ 39.6137 39.7405 40.5790]);
static_NoSo =  mean([54.2415 54.3790  55.0667]);


data_BH11 = NaN(4,6,2);

if find(spar.sphase == 1)
    
    % NOSO
    hold on;
    for iplot = 1:size(sdf_split_NoSo,2)
        d(iplot) = plot(sdf_split_NoSo(iplot).spar_table(:,1)*1e3, sdf_split_NoSo(iplot).data,markers{iplot},'Color',col(iplot,:));
        d(iplot).MarkerFaceColor = 'none';
        d(iplot).MarkerSize = 3;
        
        data_BH11(iplot,1:length(sdf_split_NoSpi(iplot).data),2) =  sdf_split_NoSo(iplot).data;
    end
    
    % simulations
    g1 = plot(spar.gap_interval*1e3,squeeze(level_thresh(1,:,2)),'LineStyle','--','Color',col(1,:));
    g2 = plot(spar.gap_interval*1e3,squeeze(level_thresh(2,:,2)),'LineStyle','--','Color',col(2,:));
    g3 = plot(spar.gap_interval*1e3,squeeze(level_thresh(3,:,2)),'LineStyle','--','Color',col(3,:));
    g4 = plot(0,static_NoSo,'o','Color','k');
    
    xlim([-10 210])
    
    grid on;
    set(gca,'GridLineStyle',':','LineWidth',grid_linewidth)
    
    
    nexttile(t2)
end


% N0Spi
for iplot = 1:size(sdf_split_NoSpi,2)
    d(iplot) = plot(sdf_split_NoSpi(iplot).spar_table(:,1)*1e3, sdf_split_NoSpi(iplot).data,markers{iplot},'Color',col(iplot,:));
    d(iplot).MarkerFaceColor = col(iplot,:);
    d(iplot).MarkerSize = 3;
    hold on;
    
    data_BH11(iplot,1:length(sdf_split_NoSpi(iplot).data),1) =  sdf_split_NoSpi(iplot).data;
end

% simulations
g1 = plot(spar.gap_interval*1e3,squeeze(level_thresh(1,:,1)),'LineStyle','-','Color',col(1,:));
g2 = plot(spar.gap_interval*1e3,squeeze(level_thresh(2,:,1)),'LineStyle','-','Color',col(2,:));
g3 = plot(spar.gap_interval*1e3,squeeze(level_thresh(3,:,1)),'LineStyle','-','Color',col(3,:));
g4 = plot(0,static_NoSpi,'o','Color','k');


xlim([-10 210])

grid on;
set(gca,'GridLineStyle',':','LineWidth',grid_linewidth)


annotation('textbox',[.9 .68 .1 .1],'String','$S_{0}$','interpreter','Latex','EdgeColor',[1 1 1])
annotation('textbox',[.9 .40 .1 .1],'String','$S_{\pi}$','interpreter','Latex','EdgeColor',[1 1 1])


lg = legend([d(1), d(2), d(3),d(4)], '$t1 = t2$', '$t1 < t2$', '$t1 > t2$', 'non-transient','Location','Northeast', 'NumColumns',2,'Box','off');

title(t2,'Buss \& Hall, 2011','Interpreter','Latex','Fontsize',t_fontsize)


lg.Position(1) = 0.4;
lg.Position(2) = 0.83;
lg.ItemTokenSize(1) = 10;
lg.FontSize = lg_fontsize;

box off


xlabel(t2,'signal/masker interval / ms','Interpreter','Latex','Fontsize',lb_fontsize)
ylabel(t2,'Threshold / dB SPL','Interpreter','Latex','Fontsize',lb_fontsize)

% Statistics
p = NaN(size(data_BH11));
p(1:size(level_thresh,1),1:size(level_thresh,2),:) = level_thresh;



%% Siveke
nexttile(T,8)
load('./Results/Siveke_noframes_15-May-2023 13:41:17_22_200_1_thresh_spar_mpar_xtended.mat')

load('home/eurich/git/experiment_materials/Siveke_et_al2008/sdf_Siveke_et_al._-_2008_Fig2_Panel_A.mat')

level_thresh_extended(1:5,:) = squeeze(level_thresh);
level_thresh_extended(5,1) = NaN;

[sdf_split,modes] = spar_split_by_name(sdf_out,'Stimulus Type');
Phasewarp_data = sdf_split(2).data;
Oscor_data = sdf_split(3).data;
fm_all = 2.^[3:10];
si(1) = semilogx( fm_all(1:5),Oscor_data,'o','MarkerSize',4);
si.MarkerFaceColor = col(1,:);
hold on;
semilogx( fm_all,Phasewarp_data,'x','MarkerSize',5)

% Dietz
fm_all_Dietz = [10 50 75];
Dietz2008PWdata = [-7 -4 -1.8];

% convert mod_depth to SMR
m = 10.^(Dietz2008PWdata / 20);
f_ratio = 1./(1+sqrt(1./m - 1));


for fl = 1:length(Dietz2008PWdata)
    
    testsig = randn(spar.dur*spar.fs,2);
    testsig_spl = set_dbspl(testsig,spar.spl);
    l_uncorr = get_dbspl( testsig_spl(:,1) * (1-f_ratio(fl)));
    l_mod = get_dbspl(testsig_spl(:,2) * f_ratio(fl));
    
    SMR_Dietz(fl) = l_mod - l_uncorr;
end

s(2) = semilogx( fm_all_Dietz,SMR_Dietz,'d','MarkerSize',4,'Color',col(2,:));
s(2).MarkerFaceColor = col(2,:);


xticks(fm_all)
xlim([6 100])
xlabel('Modulation Frequency / Hz','Fontsize',lb_fontsize)
ylabel('Threshold SNR / dB','Fontsize',lb_fontsize)
ylim([-6 10])

% simulations
plot(spar.f_mod,level_thresh_extended(:,1),'color',col(1,:));
plot(spar.f_mod,level_thresh_extended(:,2),'color',col(2,:));
box off


title('Siveke $et\ al.$, 2008','Fontsize',t_fontsize)

lg = legend('Siveke $et\ al.$, 2008: Oscor','Siveke $et\ al.$, 2008: Phasewarp', 'Dietz $et\ al.$, 2008: Phasewarp','Box','Off','Location','NorthWest');
lg.ItemTokenSize(1) = 10;
lg.FontSize = lg_fontsize;
grid on;
set(gca,'GridLineStyle',':','LineWidth',grid_linewidth)


annotation('textbox',[.02 .35 .01 .01],'String','\textbf{(A)}','interpreter','Latex','EdgeColor',[1 1 1],'FontSize',12)
annotation('textbox',[.02 .04 .01 .01],'String','\textbf{(B)}','interpreter','Latex','EdgeColor',[1 1 1],'FontSize',12)
annotation('textbox',[.68 .35 .01 .01],'String','\textbf{(C)}','interpreter','Latex','EdgeColor',[1 1 1],'FontSize',12)
annotation('textbox',[.35 .04 .01 .01],'String','\textbf{(D)}','interpreter','Latex','EdgeColor',[1 1 1],'FontSize',12)



%% export


if export_graphics
    exportgraphics(f1,[path_to_save_figs '/Figure4_multlooks2.pdf'],'ContentType','Vector')
end

