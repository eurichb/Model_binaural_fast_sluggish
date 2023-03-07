% generate mpar

function bmld = bmld_eurich2022mpar

bmld = [];

bmld.fs         = 48000;
bmld.GT_filters_per_ERBaud    = [1]; % filters per ERB
bmld.GT_bwfactor   = 1;
bmld.GT_flow       = 500; %Hz
bmld.GT_fbase      = 500; % one filter will be centered here --> fc
bmld.GT_fhigh      = 500; % just central channel for now
bmld.GT_gtorder    = 4;
bmld.GW_num_filters = 5;
bmld.hc_lp_n    = 5;
bmld.hc_lp_fc   = 750;
bmld.AcrChannel_sigma = [0]; % 0.8 3.8
bmld.iKernelThresh = 1e-3; % treshold above which a value of the Gaussian filter window is used
bmld.window        = [2]; % 1: Gauss; 2: Double-Exponential
% bmld.GaussPad   = 20;
bmld.rho_max   = [0.99]; 
bmld.mon_sigma  = [1.6];%0.2
bmld.bin_sigma  = [0.2 ]; %
% bmld.prior_fcidx = 0; % backend gets information about "central" channel (1 or 0);
% bmld.fcidx       = [];
bmld.tau =      0.035;



