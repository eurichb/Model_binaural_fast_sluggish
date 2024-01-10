% generate mpar

function mpar = bmld_eurich2022mpar

mpar = [];

mpar.fs         = 48000;
mpar.GT_filters_per_ERBaud    = [1]; % filters per ERB
mpar.GT_bwfactor   = 1;
mpar.GT_flow       = 500; %Hz
mpar.GT_fbase      = 500; % one filter will be centered here --> fc
mpar.GT_fhigh      = 500; % just central channel for now
mpar.GT_gtorder    = 4;
mpar.GW_num_filters = 5;
mpar.hc_lp_n    = 5;
mpar.hc_lp_fc   = 750;
mpar.AcrChannel_sigma = [0]; % 0.8 3.8
mpar.iKernelThresh = 1e-3; % treshold above which a value of the Gaussian filter window is used
mpar.window        = [2]; % 1: Gauss; 2: Double-Exponential
% bmld.GaussPad   = 20;
mpar.rho_max   = [0.9]; 
mpar.mon_sigma  = [53];%0.2
mpar.bin_sigma  = [20]; %
mpar.FrameLen = 1;
mpar.start_evaluate = 1000;
mpar.tau =      0.030;



