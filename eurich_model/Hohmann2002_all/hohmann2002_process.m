function [outsig, obj] = hohmann2002_process(obj, insig)
%hohmann2002_process  Process input signal by filterbank object
%   Usage: [outsig, obj] = hohmann2002_process(obj, insig);
%
%   Input parameters:
%     obj      : An object created within the HOHMANN2002 filterbank framework by
%                one of the following funtions: |hohmann2002|,
%                |hohmann2002_filter|, |hohmann2002_delay|,
%                |hohmann2002_synth|, |hohmann2002_mixer|.
%     insig    : Input signal to be processed [time channels].
%
%   Output parameters:
%     outsig   : A matrix containing the processed output signals [time channels].
%                The columns correspond to the filter bands.
%     obj      : The original object with updated filter states.
%
%   See also: exp_hohmann2002 demo_hohmann2002
%
%   References: hohmann2002

%

% author   : Universitaet Oldenburg, tp (Jan 2002, Jan, Sep 2003, Nov 2006, Jan 2007)
% Adapted to AMT (PM, Jan 2016) from function gfb_*_process

if ~isfield(obj,'type'), error('Type of the object missing'); end

switch(obj.type)
  case 'gfb_Filter'    
    factor = obj.normalization_factor;

    % for compatibility of the filter state with the MEX extension, we
    % have to multiply the filter state with the filter coefficient before the
    % call to filter:
    filter_state = obj.state * obj.coefficient;

    insig=insig.';
    
    for i = 1:obj.gamma_order
      [insig, filter_state(i)] = ...
          filter(factor, [1, -obj.coefficient], ...
                 insig, filter_state(i));
      factor = 1;
    end

    outsig = insig;

    % for compatibility of the filter state with the MEX extension, we
    % have to divide the filter state by the filter coefficient after the
    % call to filter:
    obj.state = filter_state / obj.coefficient;
    outsig=outsig.';

  case 'gfb_analyzer'
    if (obj.fast)
      % use matlab extension for fast computation.
%       [outsig, obj] = gfb_analyzer_fprocess(obj, insig);
      warning('fast computation not available');
    end
%     insig=insig';
    number_of_bands = length(obj.center_frequencies_hz);
    outsig = zeros(size(insig,1), number_of_bands);
    for band = 1:number_of_bands
      [tmp, obj.filters(band)] = hohmann2002_process(obj.filters(band), insig(:, min(band,size(insig,2))) );
      outsig(:,band) = tmp;
    end
%     outsig=outsig';

  case 'gfb_Delay'
    insig=insig.';
    [number_of_bands, number_of_samples] = size(insig);
    if (number_of_bands ~= length(obj.delays_samples))
      error('Input rows must match the number of bands');
    end
    outsig = zeros(number_of_bands, number_of_samples);
    for band = 1:number_of_bands
      if (obj.delays_samples(band) == 0)
        outsig(band,:) = real(insig(band,:) * obj.phase_factors(band));
      else
        tmp_out = [obj.memory(band,1:obj.delays_samples(band)), ...
                   real(insig(band,:) * obj.phase_factors(band))];
        obj.memory(band,1:obj.delays_samples(band)) = tmp_out(number_of_samples+1:length(tmp_out));
        outsig(band,:) = tmp_out(1:number_of_samples);
      end
    end
    outsig=outsig.';

  case 'gfb_Synthesizer'
    [outsig, obj.delay] = hohmann2002_process(obj.delay, insig);
    [outsig, obj.mixer] = hohmann2002_process(obj.mixer, outsig);

  case 'gfb_mixer'
    insig=insig.';
    outsig = obj.gains * insig;
    outsig=outsig.';
  otherwise
    error('Unknown type of HOHMANN2002 filter object');
end


