import sys, numpy as np, soundfile as sf
from scipy.signal import spectrogram
path=sys.argv[1]; bpm=float(sys.argv[2]); bars=int(sys.argv[3])
x,sr=sf.read(path); m=x.mean(1)
L=int(round(bars*4*60/bpm*sr)); assert abs(len(x)-L)<2,(len(x),L)
print("duracion %.1f s, pico %.3f, RMS %.1f dB, clipping(>0.99): %d"%(len(x)/sr,np.abs(x).max(),20*np.log10(np.sqrt((x**2).mean())),(np.abs(x)>0.99).sum()))
bl=L//bars
r=[20*np.log10(np.sqrt((m[i*bl:(i+1)*bl]**2).mean())+1e-9) for i in range(bars)]
print("RMS por compas (dB):"," ".join("%.0f"%v for v in r))
# costura del loop: salto entre ultimo y primer sample, y energia 50ms alrededor
w=int(0.05*sr)
print("salto en costura: %.4f (max |dif| normal %.4f)"%(abs(m[-1]-m[0]),np.abs(np.diff(m)).max()))
print("RMS ultimos 50ms %.1f dB / primeros 50ms %.1f dB"%(20*np.log10(np.sqrt((m[-w:]**2).mean())+1e-9),20*np.log10(np.sqrt((m[:w]**2).mean())+1e-9)))
f,t,S=spectrogram(m,sr,nperseg=4096)
P=S.sum(1); P/=P.sum()
bands=[(20,120),(120,500),(500,2000),(2000,6000),(6000,16000)]
print("energia por banda:"," | ".join("%d-%dHz %.0f%%"%(a,b,100*P[(f>=a)&(f<b)].sum()) for a,b in bands))
cen=(f[:,None]*S).sum(0)/(S.sum(0)+1e-12)
print("centroide espectral medio %.0f Hz"%cen.mean())
