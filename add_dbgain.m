function signal_out = add_dbgain(signal_in, db_gain) 
% add_dbgain add a gain to a multi-channel signal
% SIGNAL_OUT = add_dbgain(SIGNAL_IN, DB_GAIN) returns re-gained signal
% SIGNAL_IN     preassure waveform, multi channels in colums
% DB_GAIN       gain in dB
% SIGNAL_OUT    preassure waveform with level = level(SIGNAL_IN) + DB_GAIN
%
% see also get_dbspl set_dbspl

[db_spl] = get_dbspl(signal_in);

db_new = db_spl + db_gain;

signal_out = set_dbspl(signal_in,db_new);

end