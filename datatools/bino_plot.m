function h = bino_plot(sdf,par,marker,color,linestyle)
%bino_plot is a function used by sdf_auto_plot
%
%EXAMPLE:
% sdf = spar_mean_unique(sdf);
% sdf_auto_plot(sdf,@bino_plot,{'ipd','s'},{'vp_name','m'})
%see also sdf_auto_plot

[~,val1] = spar_split_by_name(sdf,par{1});
n_index = get_spar_index(sdf,'n_mean');
sdf.spar_table(:,n_index);
[a,b] = binofit(round(sdf.data.*sdf.spar_table(:,n_index)'),sdf.spar_table(:,n_index)');



h = errorbar(val1,a,b(:,1)-a',b(:,2)-a','Marker',marker,'LineStyle',linestyle{:},'color',color,'LineWidth',2);
hold all
xlabel(par{1})
ylabel(sdf.data_info.name);

ylim([.4 1.01])


end