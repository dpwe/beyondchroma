function [O,U] = average_models(M, T)
% [O,U] = average_models(M,T)
%   Take 25 element model array M from train_chord_models and
%   average them, suitably rotated, across all root notes for both
%   major and minor.
%   Improves .^.25 chroma on beatles test set fro 75.5% to 76.1%
%   T is initial transition matrix, U is smoothed version.
% 2013-05-08 Dan Ellis dpwe@ee.columbia.edu

% Initialize output; copy N model
O = M;
U = T;

nchrm = 12;
nmodel = 25;

for bank = 1:2;
  
  % Form averages
  cmean = 0 * M(1).mean;
  ccov = 0 * M(1).sigma;
  ctran = 0 * T(2:end, 1);
  
  for i = 1:nchrm
    model = nchrm*(bank - 1) + i + 1; % +1 to skip M(1) = N
    cmean = cmean + chromrot2(M(model).mean, i-1);
    ccov  = ccov  + chromrot2(chromrot2(M(model).sigma, i-1)', i-1)';
    % Transitions
    ctran = ctran + chromrot2(T(2:end,model), i-1);
  end
  
  % averages
  cmean = cmean/nchrm;
  ccov = ccov/nchrm;
  ctran = ctran/nchrm;
  
  % Write back
  for i = 1:nchrm
    model = nchrm*(bank - 1) + i + 1;
    O(model).mean  = chromrot2(cmean, -(i-1));
    O(model).sigma = chromrot2(chromrot2(ccov, -(i-1))', -(i-1))';
    U(2:end,model) = chromrot2(ctran, -(i-1));
  end
  
  % Transitions
  
end
