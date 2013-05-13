function Y = chromrot2(X,R,D)
% Y = chromrot2(X,R,D)
%    Rotate each column of chroma feature matrix X down by R
%    semitones, working in bands of D features; D must subdivide nrows(X).
% 2006-07-15, 2008-08-12, 2009-09-23  dpwe@ee.columbia.edu

if nargin < 3
  D = 12;
end

[nr,nc] = size(X);

ix0 = 0:nr-1;
ixs = 1 + mod(ix0+R, D) + D*floor(ix0/D);

% Last block is special
lastblockstart = D*floor(nr/D);
lastblocksize = rem(nr,D);
lastblockixs = lastblockstart:(lastblockstart+lastblocksize-1);
ixs(lastblockixs+1) = 1+lastblockstart+mod(lastblockixs-lastblockstart+R,lastblocksize);

Y = X(ixs,:);
