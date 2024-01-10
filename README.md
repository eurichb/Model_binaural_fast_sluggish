# Model_binaural_fast_sluggish
Matlab code for model that accounts for psychoacoustic data on both fast and sluggish processing.
To run this, you need experiment_materials, audio_tools, data_tools.

The scripts "simulate_<AuthorYear>" each...
* load the stimulus parameters using "get_spar_..." (in Repo experiment_materials)
* load the model default parameters  (Eurich2023mpar)
* run the experiment using run_exp (from data_tools, delivered code version from 2022 here) -- see below
* convert the abstract representations to d' using the model backend and different helper functions
* convert the d' to threshold levels that can be plotted here or elsewhere


The model:
* For each experimental condition, the stim_model_function is called
* there, the stimulus is created and the model is called for 1) a two-channel audio without target (template) to be internally comapared to the interval WITHOUT target; and 2) a two-channel audio without target (template) to be internally comapared to the interval WITH target
* the processing from audio to the difference between the representations happens in "EurichDietz2023processing.m"
* the processing from the difference between the representations from audio to d' happens in "EurichDietz2023decision.m" (here, the two intervals are compared)
