function SMR = siveke_get_SMR(spar)


flev = -20:1:0;

for fl = 1:length(flev)
    
    f_ratio = 10^(flev(fl)/20);
    testsig = randn(spar.dur*spar.fs,2);
    testsig_spl = set_dbspl(testsig,spar.spl);
    l_uncorr = get_dbspl( testsig_spl(:,1) * (1-f_ratio));
    l_mod = get_dbspl(testsig_spl(:,2) * f_ratio);
    
    SMR(fl) = l_mod - l_uncorr;
end