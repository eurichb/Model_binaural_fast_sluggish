function [out,mpar] = stim_model_function(spar,mpar,template)


% write temporary varibles because spar.xxx is redefined between template and target
bmld_out = [];
tone_level = spar.tone_level;
general_itd = spar.itd;

%% choose right stim generation function
if isequal(spar.experiment,2)
    gen_stim_func = @gen_stim_MqMc09;
elseif isequal(spar.experiment,3)
    gen_stim_func = @gen_stim_KolCul10;
elseif isequal(spar.experiment,4)
    gen_stim_func = @gen_stim_SoGu66;
elseif isequal(spar.experiment,5)
    gen_stim_func = @gen_stim_KollmeierGilkey90;
elseif isequal(spar.experiment,6)
    gen_stim_func = @gen_stim_Kolarik09;
elseif isequal(spar.experiment,7)
    gen_stim_func = @gen_stim_BT99;
elseif isequal(spar.experiment,8)
    gen_stim_func = @gen_stim_lnn;
elseif isequal(spar.experiment,9)
    gen_stim_func = @gen_stim_siveke2008;
    temp_f_level = spar.f_level;
    spar.f_level = -inf;
elseif isequal(spar.experiment,10)
    gen_stim_func = @gen_stim_Reed_vdP_15;
elseif isequal(spar.experiment,11)
    gen_stim_func = @gen_stim_Buss_Hall_2011;
elseif isequal(spar.experiment,12)
    gen_stim_func = @gen_stim_Grantham_Wightman_1979;
elseif isequal(spar.experiment,13)
    gen_stim_func = @gen_stim_dietz2008;
    temp_mod_depth = spar.mod_depth;
    spar.mod_depth = -inf;
elseif isequal(spar.experiment,14)
    gen_stim_func = @gen_stim_NoSpi_relative_Spi_position;
    
else
    gen_stim_func = @gen_stim_bmld;
end



%% stimulus generation template + interval
temp_tone_level = spar.tone_level;
spar.tone_level = -inf;

stim_template = gen_stim_func(spar);

if isequal(spar.experiment,9)
    spar.f_level = temp_f_level;
elseif isequal(spar.experiment,13)
    spar.mod_depth = temp_mod_depth;
end

spar.tone_level = temp_tone_level;
stim_interval = gen_stim_func(spar);

stim_template_interval = stim_interval;
stim_template_interval.data = cat(2,stim_template.data,stim_interval.data);


mpar_loopfunc = @(stim_template,mpar)compute_mpar_loop(stim_template_interval,@Eurich_model_2022_processing,mpar);

% Processing model receives tokens to be template (alsways without target) and such to be stimulus (can hold target)
interval_processed = feval(mpar_loopfunc,stim_interval,mpar);


%% output
interval_processed.data_info.ndim = 2;

out = interval_processed;

   
end