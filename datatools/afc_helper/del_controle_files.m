function del_controle_files(exp_name)

close all
fclose('all');
disp(['This will delete all controle-files related to ',exp_name])
delete_decission = input('press ENTER to do so or anything else to keep the files');
%kill controle files
if isempty(delete_decission)
    lvl_string ={'*','*/*','*/*/*'};
    for i_lvl = 1:length(lvl_string)
        l = dir([lvl_string{i_lvl},'control_',exp_name ,'*.dat']);
        
        for i = 1:length(l)
            delete([l(i).folder,filesep,l(i).name])
        end
    end
end    
     pause(1)
    disp('check spar changes')
end