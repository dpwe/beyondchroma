function [T,L] = readharte(X, ruleset)
% [T,L] = readharte(X, ruleset)
%    Read the Harte-format chord label file X 
%    and return its contents in T (start times) and L (chord index,
%    0..24, 24 = no chord).  
%    If L is omitted, return T as a two-column matrix of 
%    [time labelix] rows.
% 2009-10-02 Dan Ellis dpwe@ee.columbia.edu

if nargin < 2; ruleset = 0; end

if exist(X,'file') == 0
  error(['harte file ',X,' not found']);
end

[ts,te,ll] = textread(X,'%f %f %s');

lx = normalize_labels(ll, ruleset)';

NOCHORD = 0;

if lx(end) ~= NOCHORD
  ts = [ts;te(end)];
  lx = [lx;NOCHORD];
end

if nargout == 1
  T = [ts,lx];
elseif nargout > 1
  T = ts;
  L = lx;
end

