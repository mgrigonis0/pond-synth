# Pond synth — spec (working title)

Max for Live instrument. Status: v0.1 build in progress.
Target: Live 11, Max 8.6.4, Intel Mac (the build also covers Apple Silicon).
Code: github.com/mgrigonis0/pond-synth
Last updated: 2026-10-09.

---

## 1. Concept

A simulated pond of water. **Stones** disturb it, an **orbit** listens to it, and each **note** travels through the pond's life.

- The sound comes from reading the water's height along a circle (the orbit).
- **Pitch = how many times per second the orbit goes round.** It's always in tune.
- **Timbre = the shape of the water under the orbit.** It changes as the ripples move, reflect and die down.
- Still water = silence. Sound exists only when the water is disturbed.

**Why it's worth building:** in a blind A/B test against a carefully matched wavetable with LFOs, the pond was picked out immediately as "way more alive." The water moves *within* each wave cycle, which spreads every harmonic into a shimmering halo around the note while the pitch stays clear. A wavetable can't do this, because its frames are perfectly periodic.

---

## 2. Engine

- **Each voice runs its own copy of the pond.** Every voice gets the same stones and settings, so the copies behave identically; each one just sits at its own moment in the pond's life. (Storing the pond's whole life for shared use would take hundreds of MB; four copies cost about 1% of a core each.)
- **Raw orbit reading:** the height under the orbit becomes the output, sample by sample. There's no FFT, no added partials, no pitch anchor and no auto-gain.
- **Two orbits, left and right**, on the same water give the stereo image.
- **Rule: the orbit must stay fully on the water.** An orbit crossing the walls reads flat zero and makes a harsh buzz. The orbit's maximum size is limited automatically to fit the pond shape.
- **Deterministic:** the same stones give the same pond every time.
- **Start point:** the pond state at the start time is computed in advance whenever stones or pond settings change, so a note can begin there instantly.
- **Oversampled 4×** to avoid digital fizz on high notes.
- **Shape changes are smoothed** so morphing the pond mid-note doesn't click.

---

## 3. Controls

### Pond
| Control | What it does |
|---|---|
| Shape: corners | 3 (triangle) up to 12 (near-circle), crossfading between whole numbers |
| Shape: walls | concave (bent in) ↔ straight ↔ bulging |
| Reflectivity | walls absorb ↔ walls reflect |
| Viscosity | water (bright, busy) ↔ syrup (dark, calm) |
| Current | whirlpool strength and direction. Stronger gives a cleaner pitch *and* more timbre movement |
| Pond speed | how fast the water's clock runs, separate from pitch. Slow = clean, normal = alive halo, fast = pitch breaks up |
| Key tracking | pond speed follows the note (C3 = 1×), so every note gets the same amount of character. On by default |

### Stones (up to 4, dragged on the pond view)
Stones act as **strikes**: they set when, how hard and where the pond is disturbed. The color comes from the pond shape and the orbit.

| Control | What it does |
|---|---|
| Position | where it lands |
| Height | when it lands and how fast it hits (falling physics, gravity scaled so heights stay sensible) |
| Size | **restless ↔ calm**: tiny stones give a restless, shifting sound; huge stones a calm, steady slosh |
| Mass | strength = mass × impact speed |
| Randomize | a fresh set of stones in one click |

All stones are released together, and physics decides the timing. A much stronger stone near the orbit swallows weaker ones, so stones only combine when they're of similar strength.

### Orbit (dragged on the pond view)
| Control | What it does |
|---|---|
| Position | where on the water you listen. The most direct timbre control |
| Size | larger = brighter and hears more of the pond. The maximum is capped automatically |
| Wander | the orbit drifts across the water by itself |
| Stereo width | how far apart the left and right orbits are |
| Detune | left and right orbits slightly out of tune with each other |

### Time (each voice has its own playhead)
| Control | What it does | Version |
|---|---|---|
| Start point | where in the pond's life each note begins | v0.1 |
| Freeze | hold the current moment | v0.1 |
| Loop region + mode | start/end markers; one-shot / forward / ping-pong | v0.2 |

### Playing
- 4 voices, oldest note stolen first
- Amp envelope: attack and release (the pond's own decay continues while the key is held)
- Velocity → volume only
- Drift: micro-instability (slow pitch and orbit wobble)
- Volume

---

## 4. Key tracking (decided)

Pond speed scales with the note's frequency, with C3 = 1×.

| Note | Halo without key tracking | Halo with key tracking |
|---|---|---|
| C2 | 313 cents, falls apart | 162 cents |
| C3 | 177 | 177 |
| C4 | 96 | 175 |
| C5 | 49, nearly static | 168 |

Side effect: high notes ring out shorter in real time, like a real instrument. That's kept.

---

## 5. UI

Design canvas: "Pond synth UI" artifact (device strip at real size, pop-out editor, working pond).

**Rule:** anything spatial is a direct gesture on the pond. Only non-spatial controls get knobs.

**Gestures on the pond view**
- Drag a stone's ring on the water: where it lands
- Drag a stone's ball up/down: drop height. Sideways: mass (darker = heavier). The direction locks after a few pixels
- Drag the orange dot on the selected stone's ring: size
- Double-click water: add a stone. Drag a stone off the pond: remove it (at least one stays)
- Drag the orbit's cross: where you listen. Drag the dot on its edge: orbit size (turns orange at the wall)
- Drag the curl handle around the rim: current strength and direction

**Device strip, left to right:** pond view (with randomize, display on/off, pop-out) | Shape XY pad (corners × walls) | Medium XY pad (viscosity × reflectivity) | Time (start, freeze, key, speed) | knobs: Wander, Width, Detune, Drift, Attack, Release, Velocity, Volume

Every control is a Live parameter, so it can be automated and is saved with the set. Live device height is 169 px; the pop-out window gives a large pond for detail work (v0.2).

---

## 6. Tech

- **pond~**: a C++ Max external holding all audio (voices, ponds, stones, orbits, envelope, output).
- **Max patch:** MIDI in → pond~ → audio out, Live parameter objects, and two jsui views (pond view and XY pads) drawn from data pond~ sends out.
- **Build:** GitHub Actions compiles a universal `.mxo` (Intel + Apple Silicon) for Max 8. Freezing the device embeds the external.
- **CPU (measured, C, one core of a 2.1 GHz CPU):** about 0.7% per voice at a 72×72 pond, 1.3% at 108×108. Worst case (4 high notes at 4× pond speed, 108 grid) about 20%.

---

## 7. v0.1 scope

In: stones, orbit, shape, medium, current, speed + key tracking, start point, freeze, amp envelope, velocity, width, detune, drift, wander, volume, randomize stones, pond display, all gestures in the device strip.

Later (v0.2+): loops and ping-pong (snapshot + re-simulate for reverse), pop-out editor window, wind, dispersion, output section.

---

## 8. What we learned from prototyping

1. **A wavetable-style reading sounds digital.** Snapshots, partials and pitch anchors killed the life. The raw continuous reading is the one to use.
2. **Pitch stability depends on how much the water moves during one lap.** Slow water gives a stable pitch; fast water smears it. Low notes break first → key tracking.
3. **The pond acts like a bell.** It settles into its own vibration patterns, set by its **shape**.
4. **Extra stones add loudness, not color.** Tested with very different sizes, absorbing walls and dispersion: none made later stones change the color more than the pond's own drift. A huge stone swallows a tiny one completely.
5. **Stone size controls movement:** tiny = restless (color drift 0.16), huge = calm (0.05).
6. **Stones do cancel each other's harmonics,** but it flickers 16–20 times a second, so it's heard as grit, not a change of color.
7. **Symmetry locks the timbre.** A triangle pond with a centered orbit stayed on harmonic 3. An off-center orbit or irregular shape breaks the lock.
8. **The "detune" is the character.** Each harmonic splits into twin peaks around the note at a fixed spacing in Hz, set by the water's speed. It doesn't need fixing.
9. **Current:** 0.35 → 4 turns/s raised lap-to-lap similarity from 0.66 to 0.87 and color movement from 3.3 to 5.3.
10. **Wind alone gives a very clean, sustained, gusting drone,** not noise.

---

## 9. Tested and cut

- Orbit shape (ellipse, figure-8): an EQ does the same
- Rocks and islands: hardly audible, only added grit
- Lily pads (static or drifting): mostly just shortened the decay
- Tilt: only a momentary bend
- Sloped bottom: mostly a hidden pond-speed control; replaced by the detune knob
- Alternative readings (ripples as partials, ring per harmonic, pond as filter, FM, crest grains, audio-rate resonator): less alive, or not liked
- Scroll wheel for mass: replaced by sideways drag (trackpad-friendly)
- Audible splash: left out for now

---

## 10. Parked and open

**Parked:** output section (tone, reverb), drip (repeating stone), "click → wash body," taste-learning randomizer.

**Open:** wind with real speed and direction; nonlinear water (the only physics change left that could make stones change color); dispersion; Windows build.
