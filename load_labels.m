function [Labels,Times] = load_labels(Track, usenpy)
% [Chroma,Times] = load_labels(Track)
%     Read in labels for data items defined by a track ID string Track.
%     Labels returns an N-element vector of integer labels (0..24)
%     for each beat.
%     Times returns the start times of each beat.
% 2010-04-07 Dan Ellis dpwe@ee.columbia.edu after loadftrs_mirex.m

%usenpy = 1;

% Common filename prefix
if usenpy
  fn = fullfile('mattlabs', Track);
else
  fn = fullfile('data','labels', Track);
end

if exist([fn,'.mat'])
  % Have pre-sampled label file in mat format
  Data = load(fn);
  Times = Data.bts;
  % Labels are written as a column, return as a row
  Labels = Data.L';

elseif exist([fn,'.lab'])
  % Have raw labels file, have to sample
  ruleset = 0; % labels 0..24
  [ts,ll] = readharte([fn,'.lab'], ruleset);
  % get beats
  if usenpy
    bfname = fullfile('npys',[Track,'-beats.npy']);
    bts = npyread(bfname);
  else
    bfname = fullfile('data','chroma',[Track,'-400']);
    F = load(bfname);
    bts = F.bts;
  end
  % figure time-to-beats mapping
  nlabs = length(ts);
  nbts = length(bts);
  % full array of time offsets
  dd = repmat(ts,1,nbts)-repmat(bts,nlabs,1);
  % label time - beat time, so how long after the beat the label occurs
  % find nearest PRECEDING times .. by nuking all the +ve values
  toolate = dd(:) > 0.1;
  dd(toolate) = dd(toolate)+2*max(abs(dd(:)));
  %
  % find nearest times
  [vv,ix] = min(abs(dd'));
  ix = [ix,nbts];
  Cd = zeros(1,nbts);
  for i = 1:nlabs
    Cd(ix(i):ix(i+1)) = i;
  end
  % Actual labels (set any labels where Cd is zero to NOCHORD)
  NOCHORD = 0;
  lll = [NOCHORD;ll];
  Labels = lll(Cd+1)';

else
  error(['Cannot find lab or mat file for ',fn]);
end
