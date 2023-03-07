%automatic gen cfg file
spar = get_spar_calibration;

afc_fields = fields(spar.afc);
% general measurement procedure
for i_field = 1:length(afc_fields)
    
    def.(afc_fields{i_field}) = spar.afc.(afc_fields{i_field});
end

def.samplerate = spar.fs;
spar = rmfield(spar,'afc');
spar = rmfield(spar,'fs');
var_fields = fields(spar);

def.expvar = spar.(var_fields{1});
def.expvardescription = var_fields{1};
def.expvarunit = '';

i_field = 0;
for ii = 2:length(var_fields)
    
    par_name = var_fields{ii};
    
    if strcmp(par_name,'combi')
        
        combi_fields = fields(spar.combi);
        build_control_file(expname,vpname);
        for jj = 1:length(combi_fields)
            
            combi_name = combi_fields{jj};
            i_field = i_field +1;
            def.(['exppar',num2str(i_field)]) = 0;
            def.(['exppar',num2str(i_field),'description']) = combi_name;
            def.(['exppar',num2str(i_field),'unit'])  = '';
        end
    else
        i_field = i_field +1;
        def.(['exppar',num2str(i_field)]) = spar.(par_name);
        def.(['exppar',num2str(i_field),'description']) = par_name;
        def.(['exppar',num2str(i_field),'unit'])  = '';
    end
    
end


%def.externSoundCommand = '';    % to run without soundmex
% eof