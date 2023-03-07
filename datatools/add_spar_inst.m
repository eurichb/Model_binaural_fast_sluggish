function [spikes] = add_spar_inst(spikes,varargin)
%add_spar_inst adds a stimulus parameter (spar) instance to struct
%
%struct = add_spar_inst(struct,varargin) returns in result-data-format.
%
%Parameters:
%  struct:    is an input and output in result-data-format.
%  varargin:  contains info for new instance: combinations of name + value
%
%Example:
%::   
%  struct = add_spar_inst(struct,'level_dB',20,'frequency',200)
%
%see also add_mpar, add_mpar_inst, sdf_info

spikes = z_add_par_inst('s',0,spikes,varargin{:}); 
    
    
end