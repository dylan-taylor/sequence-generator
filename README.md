# sequence-generator
The sequence generator functions are written to allow researchers to balance trials, where sequences of trials is of interest. This allows for easy testing of congruency effects in Cognitive/Neuro Science, for example producing the Gratton effect.

The function is written in MATLAB and Python making it easy to use in Psychopy or Psychtoolbox experiments, and in either case you have the option to export a csv containing the trials

## MATLAB
The main function is the *generatetrials* function. This function takes the input of trial types, along with number of trials per block, number of blocks and the length of the sequence effect you wish to examine. The function then returns a trials by block matrix of trial types, with trial types and sequence effects balanced.

## Python 
The function generate_trials is used to create the trial blocks. This takes a list of trial types, number of blocks, number of sequence effects to be repeated and the length of the sequence that you wish to examine. The function returns a list of lists containing the trials for each block, and if required will return a csv.
