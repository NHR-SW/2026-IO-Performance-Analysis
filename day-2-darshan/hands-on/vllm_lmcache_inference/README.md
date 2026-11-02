# Setup PyDarshan on your local machine
```
# python environment
python3 -m venv .darshan-venv
source .darshan-venv/bin/activate
pip install darshan # this works only for python < 3.14, for the newest you have to build darshan yourself

## only for python 3.14
  git clone https://github.com/darshan-hpc/darshan.git
  git checkout 3.5.0
  cd darshan && autoreconf -i && ./prepare.sh
  ./configure --enable-darshan-util --disable-darshan-runtime
  make -j
  DARSHAN_UTIL=$(realpath darshan-util/.libs)
  export LD_LIBRARY_PATH=$DARSHAN_UTIL:$LD_LIBRARY_PATH   # also lets pydarshan find it
```

## Analyse the vllm logs
This is the Darshan DXT log of a short LLM inference run with KV Caching and Weight loading

```
export LOG=vllm_lmcache_inference/darshan/vllm_engine_core.darshan
python -m darshan summary $LOG --enable_dxt_heatmap
```

## For seeing read separate from write
```
# rw_heatmaps.py   usage: python rw_heatmaps.py <log>.darshan
import sys
import darshan
from darshan.experimental.plots.plot_dxt_heatmap import plot_heatmap

r = darshan.DarshanReport(sys.argv[1], read_all=True)

for op in ("read", "write"):
    # runtime HEATMAP module: all POSIX I/O, coarse bins
    plot_heatmap(r, mod="HEATMAP", submodule="POSIX", ops=[op]).savefig(f"heatmap_posix_{op}.png", dpi=150)
    # DXT trace: only files passing the DXT filter, finer bins
    plot_heatmap(r, mod="DXT_POSIX", ops=[op]).savefig(f"heatmap_dxt_{op}.png", dpi=150)
```

