function sdf_template_set

global setup

load('calib.mat');

if exist('calib_vals','var')
    setup.calib_const = calib_vals;
else
    setup.calib_const = start_calib_const;
end

[spar,setup.stimfct] = get_spar_calibration;

exp_name = 'sdf_template';
spar_string = ['experiment_files/',exp_name,'/spar_save_',exp_name '.mat'];


%check if spar has changed
if exist(spar_string,'file')
    load(spar_string,'spar_save')
    if ~isequal(spar_save,spar)
        del_controle_files(exp_name)        
    end 
end

setup.spar = spar;
spar_save = spar;
save(spar_string,get_var_name(spar_save))

end