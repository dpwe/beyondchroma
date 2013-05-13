function [Models, Transitions, Priors, WLDA] = train_chord_models(TrainFileList, params)
% [Models, Transitions, Priors, WLDA] = train_chord_models(TrainFileList, params)
%     Train single-Gaussian models of chords by loading the Chroma
%     features and the corresponding chord label data from each of
%     the items named in the TrainFileList cell array.  Return
%     Models as an array of Gaussian models (e.g. Models(i).mean
%     and Models(i).sigma as the covariance), and a transition
%     matrix in Transitions. 
%     params.use_npy means to use the CL npy data files.
%     params.lda_size is the number of LDA dimensions to compress to (0 =
%     don't use LDA).
% 2010-04-07 Dan Ellis dpwe@ee.columbia.edu  after extractFeaturesAndTrain.m

if nargin < 2
  params.use_npy = 1;
  params.lda_size = 0;
  params.rawsemis = 0;
end

% load training data
% Concatenate all the features and labels into one long list
nTrainFiles = length(TrainFileList);
Features = [];
Labels = [];
for i = 1:nTrainFiles
  F = load_chroma(TrainFileList{i}, params);
  L = load_labels(TrainFileList{i}, params);
  Features = [Features, F];
  Labels = [Labels, L];
end

disp(['training data: ',num2str(length(Features)),' frames']);

use_lda = (params.lda_size > 0);

if use_lda
  [WLDA,Y] = dpwe_lda(Features', Labels', params.lda_size);
  WLDA = WLDA';
  Features = WLDA*Features;
else
  WLDA = [];
end
  
nchrom = 12;
NOCHORD = 0;

% Build models

% We have a major and a minor chord model for each chroma, plus NOCHORD
nmodels = 2 * nchrom + 1;

% global mean/covariance used for empty models
globalmean = mean(Features')';
globalcov = cov(Features')';

% Individual models for all chords
for i = 1:nmodels
  examples = find(Labels == i-1);  % labels are 0..24
  if length(examples) > 0
    % mean and cov expect data in columns, not rows - transpose twice
    Models(i).mean = mean(Features(:,examples)')';
    Models(i).sigma = cov(Features(:,examples)')';
  else
    Models(i).mean = globalmean;
    Models(i).sigma = globalcov;
  end
  Models(i).N = length(examples);
end

% Count the number of transitions in the label set
% (transitions between tracks get factored in ... oh well)
% Each element of gtt is a 4 digit number indicating one transition 
% e.g. 2400 for 24 -> 0
gtt = 100*Labels(1:end-1)+Labels(2:end);
% arrange these into the transition matrix by counting each type
Transitions = zeros(nmodels,nmodels);
for i = 1:nmodels; 
  for j = 1:nmodels; 
    nn = 100*(i-1)+(j-1); 
    % Add one to all counts, so no transitions have zero probability
    Transitions(i,j) = 1+sum(gtt==nn);
  end
end

% priors of each chord
Priors = sum(Transitions,2);
% normalize each row
Transitions = Transitions./repmat(Priors,1,nmodels);
% normalize priors too
Priors = Priors/sum(Priors);

