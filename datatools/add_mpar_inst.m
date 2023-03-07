function [struct] = add_mpar_inst(struct,varargin)
%add_mpar_inst adds a model parameter (mpar) instance to struct
%
%struct = add_mpar_inst(struct,varargin) returns in result-data-format.
%
%Parameters:
%  struct:    is an input and output in result-data-format.
%  varargin:  contains info for new instance: combinations of name + value
%
%Example:
%::   
%  struct = add_mpar_inst(struct,'nr_of_input_fibers',12,'cf',200);
%
%see also add_spar, add_spar_inst, sdf_info

struct = z_add_par_inst('m',0,struct,varargin{:});

end