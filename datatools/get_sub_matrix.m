function m_out = get_sub_matrix(matrix_in,dim,element)

    n_dim = ndims(matrix_in);
    sz = size(matrix_in);
    inds = repmat({1},1,n_dim);
    
    for i_dim = 1:n_dim
        inds{i_dim} = 1:sz(i_dim);
    end

    inds{dim} = element;

    m_out = matrix_in(inds{:});

end