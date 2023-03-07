function [result_struct,l_percept] =  calc_lr_percept(result_struct,tolerance)

if nargin == 1
    tolerance = 0;
end

[rate] = calc_firing_rate(result_struct);

l_percept = (rate.data(1,:,:) < rate.data(2,:,:)) + .5 * (rate.data(1,:,:) == rate.data(2,:,:));

% n_dim = length(size(l_percept));
% l_percept = permute(l_percept,[1,3:n_dim,2]);
result_struct.data = squeeze(l_percept);
result_struct.data_info.ndim = 0;
result_struct.data_info.name = 'right percept';
result_struct.data_info.unit = '';
end