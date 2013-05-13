beyondchroma
============

Matlab code for experiments with extended chroma features.

Use with Colin's npys/ directory, and Matt's chordlabs organized by album in mattlabs/

  >> TrainFileList = textread('trainfilelist.txt','%s');
  >> [Models,Transitions,Priors] = train_chord_models(TrainFileList,1);
  training data: 48113 frames
  >> TestFileList = textread('testfilelist.txt','%s');
  >> [S,C] = test_chord_models(TestFileList,Models,Transitions,Priors,1);
  testing data: 11683 frames
  Overall recognition accuracy = 82.2%
  >>


