function [Chroma,Times] = load_chroma_npy(Track)
% [Chroma,Times] = load_chroma(Track)
%     Read in features for data items defined by a track ID string Track.
%     Chroma returns the 12xN matrix of chroma features, one per beat.
%     Times returns the start times of each beat.
%     Now with semisoff.
% 2010-04-07 Dan Ellis dpwe@ee.columbia.edu after loadftrs_mirex.m

global parm

% Should we try to append 100Hz-centered "bass" chroma?
use100 = 0;

rawsemis = 1;

% Read the beat times
Times = npyread(['npys/', Track,'-beats.npy']);

% Read the features
Data = npyread(['npys/', Track,'-CL.npy']);

if rawsemis
  %Chroma = Data(72+[1:120],:);
  Chroma = Data;
  Chroma = Chroma.^.25;
  %MaxVals = max(Chroma)+0.00001;
  MaxVals = sqrt(sum(Chroma.^2))+0.00001;
  Chroma = Chroma.*repmat(1./MaxVals, size(Chroma,1), 1);

else
  % Make chroma for CL features
  
  % Adapting tuning - find which eighth-tone has the most peaks
  [vv,xx] = max(Data);
  semisoff = 0.9 - (mean(mod(xx+1,4)) - 1.5);

  % Or use this for fixed tuning
  %semisoff = 1.5;

  % Build a mapping matrix to project 192 eighth-tone bins to 12 chroma
  MM = zeros(12,192);
  for i = 1:12
    % Two nonzero bins per note?
    %  MM(i,:) = rem(floor([0:191]),48)==4*(i-1);
    %  MM(i,:) = MM(i,:)+(rem(floor([1:192]),48)==4*(i-1));
    % Or a "soft" exponential bump per component
    MM(i, :) = exp(-0.5*((1-(0.5+0.5*cos(((-4*(i-1)+semisoff)+[0: ...
                        191])/48*2*pi)))/0.001).^2);
  end

  %wts = exp(-0.5 * (([0:191]-72)/72).^2);  % line search for best vals
  %Chroma = MM*diag(wts)*Data;
  % frequency-dependent weighting doesn't help
%  MMw = MM.*repmat(sum(MM,2),1,size(MM,2));
%  Chroma = MMw*Data;
  
  Chroma = MM*Data;

  if use100

    % Append bass-weighted chroma vector
    wts2 = exp(-0.5 * (([0:191]-12)/24).^2);

    wts2 = wts2/sum(wts2);

    % Compensate that bottom bin is only a half
    %wts2(1) = 2*wts2(1);

    MMw = MM*diag(wts2);
    MMw = MMw.*repmat(sum(MMw,2),1,size(MMw,2));

    Chroma = [Chroma;MMw*diag(wts2)*Data];

  end


  % Normalize chroma to have maximum value 1 in each column
  Chroma = Chroma.^.25;
  % Max-norm or norm-norm doesn't make much difference
  MaxVals = max(Chroma)+0.001;
  %MaxVals = sqrt(sum(Chroma.^2))+0.00001;
  Chroma = Chroma.*repmat(1./MaxVals, size(Chroma,1), 1);
end
