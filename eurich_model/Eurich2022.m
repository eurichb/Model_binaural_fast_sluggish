%% Eurich binaural detection model to be applied for audio quality predictions

% This requires Auditory Modeling Toolbox (because it involves the Hohmann 2002 Gammatone filterbank
% It also needs datatools (as submodule 

function dprime = eurich2022(mRef, mTest)


% model parameters
mpar = Eurich2022mpar;

sRef.data = mRef;
sTest.data = mTest;

processed_mRef = Eurich_model_2022_processing(sRef,mpar);
processed_mTest = Eurich_model_2022_processing(sTest,mpar);

stack.data = cat(2,processed_mTest.data, processed_mRef.data);

if mpar.prior_fcidx
    mpar.fcidx = find(round(processed_mRef.data_info.filter_frequencies) == mpar.fbase);
end

out = Eurich_model_2022_decision(stack,mpar);
dprime = out.data;


