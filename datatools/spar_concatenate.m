function out = spar_concatenate(struct_a, struct_b)
% spar_concatenate stacks spar instances of 2 data sets
% OUT = spar_concatenate(STRUCT_A, STRUCT_B)
% STRUCT_A / STRUCT_B data (in rdf format) with same general spar space 
% If STRUCT_A is an empty strcut just return STRUCT_B
%
% see also add_spar_inst, sdf_info


    if isempty(struct_a)
        out = struct_b;
        return
    end

    a = struct_a;
    b = struct_b;

    % Check that mpar table is identical:
    if ~all(a.mpar_table == b.mpar_table, 'all')
        error('mpar table has to be identical')
    end

    % Check if the spar_table dimensions agree
    if size(a.spar_table, 2) ~= size(b.spar_table, 2)
        error('spar_table dimensions do not agree')
    end

    if length(a.spar_info) ~= length(b.spar_info)
        error('spars do not agree')
    end

    % overwrite / change indexed values if needed
    [a,b] = z_check_indexed_values(a,b);
    
    % walk through all spars of a and check if they also exist in
    % b
    % spar_fields = fields(a.spar_info);
    for i_field = 1 : length(a.spar_info)
            spar_subfields = fields(a.spar_info(i_field));
            for i_subfield = 1:length(spar_subfields)
                field_a = a.spar_info(i_field).(spar_subfields{i_subfield});
                field_b = b.spar_info(i_field).(spar_subfields{i_subfield});
                if ~isequal(field_a,field_b)
                    error([spar_subfields{i_subfield}, ' does not agree']);
                end
            end
    end

    % Check if spar dimension exists
    ndim_data = a.data_info.ndim;
    ndim_param = ndims(a.data) - ndim_data;

    if ndim_param == 0
        % no other dimension but data exists - add one
        ndim = ndim_data + 1;
    elseif ndim_param == 1
        % one extra dimension - need to check if it is spar or mpar
        if isfield(a, 'mpar_table')
            % the extra dimension is mpar - add another dimension
            % for spar
            ndim = ndim_data + 2;
        else
            % the extra dimension is spar so use it
            ndim = ndim_data + 1;
        end
    elseif ndim_param == 2
        % allready two param dimension so by definition the last one is spar
        ndim = ndim_data + 2;
    end

    % Adjust the first dimension of data to fit to each other - do
    % so by appending nans.
    max_a = size(a.data, 1);
    max_b = size(b.data, 1);
    max_all = max(max_a, max_b);

    if max_b < max_all
        newsize_b = size(b.data);
        newsize_b(1) = max_all - newsize_b(1);
        temp_b = nan * ones(newsize_b);
        temp_b = cat(1, b.data, temp_b);
        temp_a = a.data;
    elseif max_a < max_all
        newsize_a = size(a.data);
        newsize_a(1) = max_all - newsize_a(1);
        temp_a = nan * ones(newsize_a);
        temp_a = cat(1, a.data, temp_a);
        temp_b = b.data;
    else
        temp_a = a.data;
        temp_b = b.data;
    end


    out = a;
    out.data = cat(ndim, temp_a, temp_b);
    out.spar_table = cat(1, a.spar_table, b.spar_table);
end
