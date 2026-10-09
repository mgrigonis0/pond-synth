# Pond synth

A Max for Live instrument that plays a simulated pond. Stones disturb the water, an
orbit listens to it, and each note travels through the pond's life. Pitch comes from how
fast the orbit goes round; the timbre is the moving water under it.

**To try it:** download `pond-synth-mac.zip` from Releases → "Latest build" and follow
[docs/INSTALL.md](docs/INSTALL.md).

## Layout

| Path | What |
|---|---|
| `source/engine/pond_engine.h` | the sound engine (pure C++17, no Max dependencies) |
| `source/projects/pond_tilde/` | the `pond~` Max external wrapping the engine |
| `device/` | the Live device: `PondSynth.amxd`, `PondSynth.maxpat`, `pond.js`, `pads.js` |
| `tools/build_device.py` | generates the device patch |
| `tools/render.cpp` | offline renderer to test the engine without Max |
| `docs/` | spec and install guide |

## Building

Every push to `main` builds a universal `pond~.mxo` (Intel + Apple Silicon) on GitHub
Actions and publishes it with the device as the "latest" release.

Locally on a Mac:

```
git clone https://github.com/Cycling74/max-sdk-base max-sdk-base
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64"
cmake --build build
```

The external lands in `externals/`. After editing the device generator:
`python3 tools/build_device.py`.

Engine test anywhere (Linux/Mac):

```
g++ -std=c++17 -O3 -o render tools/render.cpp -lpthread
./render out.wav melody      # also: chord, sweep, cpu
```
