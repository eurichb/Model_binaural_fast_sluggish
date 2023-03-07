function [dbspl_val] = get_dbspl(signal_in)
%get_dbspl returns the SPL for each signal channel
% DBSPL_VAL = get_dbspl(SIGNAL_IN)
% SIGNAL_IN      preassure waveform, multi channels in colums
%
% see also set_dbspl, add_dbgain, audio_signal_info

p0 = 20e-6; %ref value

val = sqrt(mean(signal_in.^2));
    
dbspl_val = 20 * log10(val/p0);

end
