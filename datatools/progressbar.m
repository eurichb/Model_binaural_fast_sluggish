classdef progressbar
    properties
        num_iterations
        current_iteration
        reverse_str
        description
        start_time
    end
    methods
        function obj = progressbar(num_iterations, description)
            obj.num_iterations = num_iterations;
            obj.current_iteration = 0;
            obj.reverse_str = '';
            obj.description = description;
            obj.start_time = 0;
        end
        function obj = increment(obj)
            if obj.current_iteration == 0
                obj.start_time = tic;
            end
            obj.current_iteration = obj.current_iteration + 1;
            iter_percent = obj.current_iteration / ...
                obj.num_iterations;
            n_blocks = floor(iter_percent * 10);
            % Prvent an overflow if the number of iterations was set to a value
            % which is to small.
            if n_blocks > 9
                n_blocks = 9;
            end
            block_text = {'----------', ...
                          '#---------', ...
                          '##--------', ...
                          '###-------', ...
                          '####------', ...
                          '#####-----', ...
                          '######----', ...
                          '#######---', ...
                          '########--', ...
                          '#########-', ...
                          '##########'};
            msg = sprintf([obj.description, ': ', block_text{n_blocks+1}, ' ' ...
            '%3.1f'], iter_percent * 100);
            fprintf([obj.reverse_str, msg]);
            obj.reverse_str = repmat(sprintf('\b'), 1, ...
                                     length(msg));

            % if it is the last repition print the runtime
            if obj.current_iteration == obj.num_iterations
                d_s = floor(toc(obj.start_time));
                d_h = floor(d_s / 3600);
                d_m = floor(d_s / 60);
                d_s = d_s - d_m * 60;
                d_m = d_m - d_h * 60;

                fprintf(' %i:%i:%i h', [d_h, d_m, d_s]);
                disp(' ') %newline
            end
        end
    end

end