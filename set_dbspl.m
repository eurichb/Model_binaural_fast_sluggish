function [signal_out] = set_dbspl(signal_in,dbspl_val)
%set_dbspl set SPL for each signal channel
% SIGNAL_OUT = set_dbspl(SIGNAL_IN, DBSPL_VAL)
% SIGNAL_IN     preassure waveform, multi channels in colums
% DBSPL_VAL     level in dB SPL (ref value is 20e-6 pa), per chanel 
%
% see also get_dbspl, add_dbgain, audio_signal_info


p0 = 20e-6; %ref value
    
val = sqrt(mean(signal_in.^2));   

factor = (p0 * 10.^(dbspl_val / 20)) ./ val;

signal_out = signal_in .* factor;

end
