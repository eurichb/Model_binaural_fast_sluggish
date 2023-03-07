function sdf_template_user

global def
global work
global setup

spar = setup.spar;

for i_exppar = 1:def.expparnum    
par_name = def.(['exppar',num2str(i_exppar),'description']);
spar.(par_name) =  work.(['exppar',num2str(i_exppar)]);
end

var_name = def.expvardescription;
spar.(var_name) = work.expvaract;

stim = feval(setup.stimfct,spar);

stim = stim.data(:,1:2*def.intervalnum);

%calibration
if isstruct(setup.calib_const)    
    calib_const = get_val_by_spar(setup.calib_const,'fc',spar.fc);
    calib_const = repmat( calib_const ,[1,def.intervalnum]);
else
    calib_const = setup.calib_const;
end

stim = add_dbgain(stim,calib_const);

work.signal = stim;	

% pre-, post- and pausesignals (all zeros)
work.presig = zeros(def.presiglen,2);
work.postsig = zeros(def.postsiglen,2);
work.pausesig = zeros(def.pauselen,2);

end