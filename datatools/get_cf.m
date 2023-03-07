function cf = get_cf(spikes,index)
% helper function to return the cf (center frequency) of a specific neuron

colum_names = show_mpar_info(spikes);
cf = spikes.mpar_table(index,strcmp(colum_names,'cf'));
end