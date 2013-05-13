function Y = chromspec(d,sr,T,whitenwin)
% Y = chromspec(d,sr,T)
%    Return an octave x chromabin array
%    averaged over the audio.
%    T is a title for the plot.
%    whitenwin, if > 0, whitens the spectra over this interval (in octaves)
% 2013-04-26 Dan Ellis dpwe@ee.columbia.edu

if nargin < 2; sr = 16000; end

if nargin < 3; T = ''; end

if nargin < 4; whitenwin = 0; end

%winlen = 2048;
minwinlen = 0.100; % window length is 100..200ms
%winlen = 2^nextpow2(round(minwinlen*sr)); 
%hoplen = winlen/2;
% Just one frame per sample
winlen = length(d);
hoplen = winlen;

%disp(['win dur = ', num2str(winlen/sr)]);

lowestfrq = 440/(2^4)*(2^(3/12));  % 3 semis above A0 = C1 (32.7032Hz)

binspersemi = 4;
binsperoct = 12*binspersemi;
% back off lowest freq by half a semi
backbins = floor(binspersemi/2);
lowestfrq = lowestfrq * 2^(-backbins/binsperoct);

nov = winlen-hoplen;

Y = logfsgram(d,winlen,sr,winlen,nov, lowestfrq, binsperoct);

if whitenwin > 0
   % normalize spectral amplitude by local average over whitenwin octaves
   lwin = whitenwin*binsperoct;
   MY = conv2(hann(lwin)/sum(hann(lwin)),Y);
   MY = MY(floor(lwin/2)+[1:size(Y,1)],:);
   %YMM = Y - MY;
   %YV = conv2(hann(lwin)/sum(hann(lwin)),YMM.^2);
   %YV = YV(floor(lwin/2)+[1:size(Y,1)],:);
   % subtract mean, divide by variance
   % discard negative part
   %Y = max(0, (Y - MY) ./ sqrt(YV));

   Y = Y./MY;
end

% discard any part-octave from the top
nocts = floor(size(Y,1)/binsperoct);
Y = Y(1:(nocts*binsperoct), :);

% average all time frames and
% reshape as octs x chroma bins
Y = reshape(mean(Y,2), binsperoct, nocts)';

% maybe plot?
if nargout == 0
  imagesc(20*log10(Y));
  caxis(max(caxis())+[-30 0]);
  colorbar
  axis xy
  set(gca,'XTick', 1+backbins+binspersemi*[0 2 4 5 7 9 11])
  set(gca,'XTickLabel','C|D|E|F|G|A|B')
  title(T, 'interpreter', 'none');
end
