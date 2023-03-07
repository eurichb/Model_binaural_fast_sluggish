function [nsamp] = nsamples(duration, fs)

nsamp = round(duration * fs);

end