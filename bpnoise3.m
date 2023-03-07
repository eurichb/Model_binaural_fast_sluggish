% bpnoise.m - generates spectrally rectangular shaped band-pass noise.
%
% Usage: out = bpnoise(len,flow,fhigh,fs)
%
% len    = output length in samples
% flow   = lower cutoff frequency in Hz
% fhigh  = upper cutoff frequency in Hz 
% fs     = sampling rate in Hz 
% make_pink = if exist and not 0 noise will be 1/f spectrum
%
% out    = output vector

function out = bpnoise3(len,flow,fhigh,fs,make_pink)

bb_noise = randn(len,1);

if exist('make_pink','var')
    if make_pink
        bb_noise=lowpass3dB(bb_noise);
    end
end

out = real(ifft(scut(fft(bb_noise),flow,fhigh,fs)));

out = out/(norm(out,2)/sqrt(len));

% eof
