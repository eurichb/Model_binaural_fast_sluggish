function [sine,time] = gen_tone(frequency, duration, fs, start_phase)
% gen_tone returns a cosine wave
% [SINE, TIME ] = gen_tone(FREQUENCY, DURATION, FS, START_PHASE)
% FREQUENCY     frequency in Hz
% DURATION      duration in seconds
% FS            sampling frequenc
% START_PHASE   default is 0
% SINE          sine wave
% TIME          time vector for the cosine-wave
%
% see also getAMS gen_sam audio_signal_info
    if nargin < 4
        start_phase = 0;
    end

    nsamp = nsamples(duration, fs);
    time = get_time(nsamp, fs);

    sine = cos(2 * pi * frequency * time + start_phase);

end
