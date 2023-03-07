function [window] = gaussian_fade_window(signal, rise_time, fs, cutoff)

    if nargin < 4
        cutoff = -60;
    end

    cutoff_val = 10^(cutoff/ 20); % value at which to cut gaussian

    r = nsamples(rise_time, fs);
    window = ones(length(signal), 1);
    sigma = sqrt((-(rise_time)^2 / log(cutoff_val)) / 2);
    win_time = linspace(0, rise_time, r);
    flank = exp(-(win_time - rise_time) .^ 2 / (2 .* sigma .^ 2));

    window(1:r-1) = flank(1:end-1);
    window(end - r + 2:end) = fliplr(flank(1:end-1));
end
