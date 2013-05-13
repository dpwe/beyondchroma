function [Chroma,Times] = load_chroma(Track,use_npy)

if use_npy
  [Chroma, Times] = load_chroma_npy(Track);
else
  [Chroma, Times] = load_chroma_dpwe(Track);
end
