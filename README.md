beyondchroma
============

Matlab code for experiments with extended chroma features.

Use with Colin's npys/ directory, and Matt's chordlabs organized by album in mattlabs/

    >> TrainFileList = listfileread('trainfilelist.txt');
    >> params.use_npy = 1;
    >> params.rawsemis = 0;
    >> params.lda_size = 0;
    >> [Models,Transitions,Priors,WLDA] = train_chord_models(TrainFileList,params);
    training data: 48113 frames
    >> TestFileList = listfileread('testfilelist.txt');
    >> [S,C] = test_chord_models(TestFileList,Models,Transitions,Priors,WLDA,1);
    testing data: 11683 frames
    Overall recognition accuracy = 82.2%
    >>

Or, full 4-fold testing:

    >> cut1 = listfileread('cut1.txt');
    >> cut2 = listfileread('cut2.txt');
    >> cut3 = listfileread('cut3.txt');
    >> cut4 = listfileread('cut4.txt');
    >> cuts = {cut1,cut2,cut3,cut4};
    >> tcuts = {[cut2,cut3,cut4],[cut1,cut3,cut4],[cut1,cut2,cut4],[cut1,cut2,cut3]};
    >> C = zeros(25,25); for i = 1:4; [M,T,P,W] = train_chord_models(tcuts{i},params); [S,c] = test_chord_models(cuts{i},M,T,P,W,params); C = C+c; end
    training data: 40205 frames
    testing data: 19591 frames
    Overall recognition accuracy = 72.4%
    training data: 45314 frames
    testing data: 14482 frames
    Overall recognition accuracy = 76.5%
    training data: 45756 frames
    testing data: 14040 frames
    Overall recognition accuracy = 76.9%
    training data: 48113 frames
    testing data: 11683 frames
    Overall recognition accuracy = 82.2%
    >> sum(diag(C))/sum(sum(C))

    ans =

	0.7657
    >>

Use LDA on full-sized features

    >> params.lda_size = 16;
    >> params.rawsemis = 1;
    ...
    Overall recognition accuracy = 75.2%

