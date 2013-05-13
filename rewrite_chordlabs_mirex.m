function opfiles = rewrite_chordlabs_mirex(listfile,srcprepend,srcext, ...
                                     dstprepend,dstext, ...
                                     ftrprepend,ftrext, ...
                                     skip, isharte, ruleset)
% rewrite_chordlabs_mire(listfile,srcprepend,srcext,dstprepend,dstext,
%                   ftrprepend,ftrext, skip)
%   Convert label files in time-based format and resample them into 
%   beat-synchronous frames.  Each line of listfile specifies a
%   file, the source time-label files are <srcprepend>/<id><srcext>, 
%   the output matlab files are written to <dstprepend>/<id><dstext> 
%   (with the beat times in a vector "bts" and corresponding label 
%   strings in cell array "L").  The beat times are read from
%   matlab file <ftrprepend>/<id><ftrext>, from a variable "bts".
%   Return a cell array of the output files written.
%   * MIREX VERSION * - labels are 0..24
%   isharte = 1 means treat label files as Harte 0.000 0.314 D:min style.
% 2008-08-10 dpwe@ee.columbia.edu  after coversongs/src/calclistftrs

if nargin < 2; srcprepend = ''; end
if nargin < 3; srcext = ''; end
if nargin < 4; dstprepend = ''; end
if nargin < 5; dstext = ''; end
if nargin < 6; ftrprepend = ''; end
if nargin < 7; ftrext = ''; end
if nargin < 8; skip = 0; end
if nargin < 9; isharte = 0; end
if nargin < 10; ruleset = 0; end

if iscell(listfile)
  files = listfile;
  listfile = 'passed in cell array';
else
  files = listfileread(listfile);
end
nfiles = length(files);

if nfiles < 1
  error(['No sound file names read from list file "',listfile,'"']);
end

% preallocate to placate mlint
opfiles{nfiles} = '';

% Process every input file
for songn = 1:nfiles
  tline = files{songn};

  % figure out input file names
  if length(srcext) > 0
    if strcmp(tline(end-length(srcext)+1:end), srcext)
      % chop off srcext already there
      tline = tline(1:end-length(srcext));
    end
  else
    % no srcext specified - must be part of input file name
    % separate name and extension for input file
    [srcpath, srcname, srcext] = fileparts(tline);
    tline = fullfile(srcpath,srcname);
  end

  % special case: if tline still ends in an extension (e.g. .wav)
  % optionally remove it
  [srcpath, tline2, dummy] = fileparts(tline);
  tline2 = fullfile(srcpath,tline2);
  
  % So file names are:
  ifname = fullfile(srcprepend,[tline,srcext]);
  ffname = fullfile(ftrprepend,[tline2,ftrext]);
  ofname = fullfile(dstprepend,[tline,dstext]);
  % if we can't find that label file, try without the extension
  if exist(ifname,'file')==0
    ifname = fullfile(srcprepend,[tline2,srcext]);
  end
  
  % info for output file
  vsn = 20080821.1;
  desc = 'MIREX 0..24 labels sampled onto precalculated beat matrix';

  if songn > skip
  
    if isharte
      [ts,ll] = readharte(ifname, ruleset);
      %ts = ts + 0.033;  %%% fixed offset to make like mattilabs (gained 0.1% abs)
    else % pre-collapsed numeric label files
      [ts,ll] = textread(ifname);
    end
    
    % get beats
    F = load(ffname);
    % maybe apply totally global time shift?  (Naah)
    bts = F.bts;

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
    L = lll(Cd+1);
    
    % Make sure the parent directory exists
    ofdir = fileparts(ofname);
    mymkdir(ofdir)

    % Write output file
    save(ofname,'ifname','ffname','bts','L','vsn','desc');
    
    opfiles{songn} = ofname;
  
    disp([datestr(rem(now,1),'HH:MM:SS'), ' song ',num2str(songn),' ', ...
          tline]);

  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = mymkdir(dir)
% r = mymkdir(dir)
%   Ensure that dir exists by creating all its parents as needed.
% 2006-08-06 dpwe@ee.columbia.edu

[x,m,i] = fileattrib(dir);
if x == 0
  [pdir,nn] = fileparts(dir);
  disp(['creating ',dir,' ... ']);
  mymkdir(pdir);
  % trailing slash results in empty nn
  if length(nn) > 0
    mkdir(pdir, nn);
  end
end
