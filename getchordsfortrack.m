function [d,sr,ss] = getchordsfortrack(T,C,DISP)
% [d,sr,ss] = getchordsfortrack(T,C,DISP)
%    Load audio for all chords C in track T
%    ss provides start sample (in d) for each distinct sound excerpt
% 2013-04-26 Dan Ellis dpwe@ee.columbia.edu

if nargin < 3; DISP = 0; end

% load audio
[d,sr] = audioread(fullfile('mp3s-32k',[T,'.mp3']), 0, 1);

% load labels
[ts,te,lb] = textread(fullfile('mattlabs/beatles',[T,'.lab']), '%f %f %s');

% find labels
xx = strmatch(C,lb,'exact');

dc = []; 
for i = 1:length(xx)
  ss(i) = length(dc)+1;
  dc = [dc ; d( round(sr*ts(xx(i))+1) : round(sr*te(xx(i))) )]; 
end

disp([num2str(length(xx)),' examples of ',C,' found in ',T]);

if DISP == 1
  [p,N,e] = fileparts(T);
  chromspec(dc, sr, [N, ' - ', C, ' (',num2str(length(xx)), ' exs)'], ...
            0.5);
end
