function[keyname] =  get_key_name()
% get name of any key on keyboard 
% can be set as accepted answer for afc with keyboardResponseButtonMapping = [keyname1, keyname2, keyname3, ...]
k = waitforbuttonpress;
keyname = double(get(gcf,'CurrentCharacter'))
end