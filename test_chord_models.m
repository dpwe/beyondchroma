function [S,C] = test_chord_models(TestFileList, Models, Transitions, Priors, WLDA, params)
% [S,C] = test_chord_models(TestFileList, Models, Transitions, WLDA, Priors)
%     Test chord recognizer on multiple tracks
%     TestFileList is a cell array containing track ID strings for
%     the test file.
%     Models, Transitions, Priors define the chord recognition HMM
%     from train_chord_models.
%     WLDA is optional LDA mapping matrix to apply to features (or []).
%     S returns as the overall accuracy (between 0 and 1); 
%     C returns a confusion matrix (e.g. 25 x 25)
% 2010-04-07 Dan Ellis dpwe@ee.columbia.edu after score_chord_id.m

if nargin < 6
  params.use_npy = 1;
  params.lda_size = 0;
  params.rawsemis = 0;
end

% Total # labels = Total # models = {major,minor} x {all chroma} + NOCHORD
nchroma = 12;
nlabels = 2 * nchroma + 1;
NOCHORD = 0;

if length(WLDA) > 0
  use_lda = 1;
else
  use_lda = 0;
end

% Initialize confusion matrix
C = zeros(nlabels, nlabels);

% Run recognition on each file individually
nTestFiles = length(TestFileList);
nframes = 0;
for i = 1:nTestFiles
  Chroma = load_chroma(TestFileList{i}, params);
  if use_lda
    Chroma = WLDA * Chroma;
  end
  TrueLabels = load_labels(TestFileList{i}, params);
  HypLabels = recognize_chords(Chroma, Models, Transitions, Priors);
  [s,c] = score_chord_recognition(HypLabels, TrueLabels);
  C = C + c;  % cumulate actual seconds spent in each state
  nframes = nframes + length(TrueLabels);
end

disp(['testing data: ',num2str(nframes),' frames']);

% Actual accuracy %.  
% Exclude regions where both streams report No Chord (e.g. lead
% in/lead out)

XX = C(NOCHORD+1, NOCHORD+1);

S = (sum(diag(C))-XX) / (sum(C(:))-XX);

disp(['Overall recognition accuracy = ',sprintf('%.1f',100*S),'%']);
