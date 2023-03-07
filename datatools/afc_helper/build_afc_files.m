function build_afc_files(exp_name)

if ~isfolder('./experiment_files')
    mkdir('./experiment_files')
end
if ~isfolder(['./experiment_files/',exp_name])
    mkdir(['./experiment_files/',exp_name])
end

%build cfg file
cfg_file = ['./experiment_files/',exp_name,'/',exp_name,'_cfg.m'];
copyfile('datatools/afc_helper/sdf_template_cfg.m',cfg_file);
fid = fopen(cfg_file,'r');
DataCell = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
C = DataCell{1};
C(1) = {['% config for ',exp_name,' experiment']};
C(2) = {['spar = get_spar_',exp_name,';']};
fid = fopen(cfg_file, 'w');
fprintf(fid, '%s\n', C{:});
fclose(fid);

%build user file
user_file = ['./experiment_files/',exp_name,'/',exp_name,'_user.m'];
copyfile('datatools/afc_helper/sdf_template_user.m',user_file);
fid = fopen(user_file,'r');
DataCell = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
C = DataCell{1};
C(1) = {['function ',exp_name,'_user']};
fid = fopen(user_file, 'w');
fprintf(fid, '%s\n', C{:});
fclose(fid);

%build set file
set_file = ['./experiment_files/',exp_name,'/',exp_name,'_set.m'];
copyfile('datatools/afc_helper/sdf_template_set.m',set_file);
fid = fopen(set_file,'r');
DataCell = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
C = DataCell{1};
C(1) = {['function ',exp_name,'_set']};
C(13) = {['[spar,setup.stimfct] = get_spar_',exp_name,';']};
C(15) = {['exp_name = ',char(39),exp_name,char(39),';']};
fid = fopen(set_file, 'w');
fprintf(fid, '%s\n', C{:});
fclose(fid);

addpath(genpath(pwd))
end
%eof