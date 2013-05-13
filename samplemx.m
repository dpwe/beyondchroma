function Y = samplemx(X, colpos, samplepos)
% Y = samplemx(X, colpos, samplepos)
%   Rebuild a uniformly-sampled matrix.  X is a matrix 
%   where each column corresponds to time colpos.  Each col of Y 
%   corresponds to a time from samplepos, which is taken as the 
%   column of X in effect.
%   Integer samplepos finds that many uniformly spaced samples
%   Sort-of reverses beatavg.m
% 2007-11-10 dpwe@ee.columbia.edu

if length(samplepos) == 1
  samplepos = linspace(min(colpos),max(colpos),samplepos)
end

[nr,nc] = size(X);
Y = zeros(nr,length(samplepos));

% assume colpos, samplepos are monotonic
OX = [zeros(nr,1),X];

Y = OX(:, 1+sum(repmat(colpos',1,length(samplepos)) ...
                <= repmat(samplepos,length(colpos),1)));
