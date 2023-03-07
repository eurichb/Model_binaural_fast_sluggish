function [window] = cosine_fade_window(signal, rise_time, fs)
%cosine_fade_window returns a weighting vector for windowing (fade-in + fade-out) a signal
%WINDOW = cosine_fade_window(SIGNAL, RISE_TIME, FS)
% SIGNAL    preassure waveform, multi channels in colums
% RISE_TIME time in seconds
% FS        sampling frequency
% WINDOW    vector with the length of SIGNAL
%   
%           ................
%        .                    .
%     .                          .
%  .                                .
% |rise_time|              |rise_time|
% |          signal_time             | 
%
% EXAMPLE:
%       fs = 48e3;
%       sig = generate_tone(100,.5,fs);
%       window = cosine_fade_window(sig,.1,fs);
%       ramped_sig = sig .* window;


n_ramp = nsamples(rise_time, fs);
n_signal = size(signal,1);

window = ones(1, n_signal);
flank = 0.5 * (1 + cos(pi / n_ramp * (-n_ramp:-1)));
window(1:n_ramp) = flank;
window(end-n_ramp+1:end) = fliplr(flank);
window = window';

end
