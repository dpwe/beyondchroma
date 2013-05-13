function [Chroma,Times] = load_chroma_dpwe(Track, params)
% [Chroma,Times] = load_chroma(Track, params)
%     Read in features for data items defined by a track ID string Track.
%     Chroma returns the 12xN matrix of chroma features, one per beat.
%     Times returns the start times of each beat.
% 2010-04-07 Dan Ellis dpwe@ee.columbia.edu after loadftrs_mirex.m

if nargin < 2; params.empty = []; end

if isfield(params, 'use100') == 0
  % use low-spectrum chroma too
  params.use100 = 1;
end


% Common filename prefix
%fn = fullfile('data','chroma', Track);
fn = fullfile('data','chroma', [Track,'-400']);
Data = load(fn);

Times = Data.bts;

if params.use100

  % load in low-band chroma
  fn2 = fullfile('data','chroma', [Track,'-100']);
  Data2 = load(fn2);

  Chroma = [Data.F;Data2.F];

else
  Chroma = Data.F;
end


% Normalize chroma to have maximum value 1 in each column
Chroma = Chroma.^.25;
MaxVals = max(Chroma);
Chroma = Chroma.*repmat(1./MaxVals, size(Chroma,1), 1);
