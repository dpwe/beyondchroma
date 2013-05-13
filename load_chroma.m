function [Chroma,Times] = load_chroma(Track, params)

if params.use_npy
  [Chroma, Times] = load_chroma_npy(Track, params);
else
  [Chroma, Times] = load_chroma_dpwe(Track, params);
end
