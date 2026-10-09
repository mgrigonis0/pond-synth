# Pond synth v0.3 — install and first test

For Live 11 with Max 8 on a Mac (Intel or Apple Silicon).

## 1. Download

Get **pond-synth-mac.zip** from the repository's Releases page ("Latest build"), and unzip it.
You'll get a folder `pond-synth` with:

- `pond~.mxo` — the sound engine
- `PondSynth.amxd` — the Live device
- `pond.js`, `pads.js` — the pond view and the Shape/Medium pads

## 2. Put the files where Max can find them

1. Open Finder, press **Cmd+Shift+G**, and go to `~/Documents/Max 8/Library`
   (create the `Library` folder if it isn't there).
2. Copy the whole `pond-synth` folder into it.

## 3. Let macOS open the engine (once)

macOS blocks files downloaded from the internet that aren't from an identified developer.
Open **Terminal** and paste:

```
xattr -dr com.apple.quarantine ~/Documents/Max\ 8/Library/pond-synth
```

Press Enter. Nothing is printed when it works.

## 4. Load it in Live

1. Drag `PondSynth.amxd` from that folder onto a MIDI track (or into your User Library first).
2. Play some notes.

If the device opens but shows a red `pond~` box or stays silent, open the device editor
(the small Max button on the device), then **Max window** (Cmd+M) and copy any red error lines.

## 5. Freeze (optional, later)

Once it works, you can make the device self-contained: open it in the editor, click the
**Freeze** button (snowflake), then save. The frozen `.amxd` carries `pond~.mxo` and the
scripts inside it.

## Fallback if the .amxd won't open

`PondSynth.maxpat` in the repository is the same patch as plain text:

1. In Live, add an empty **Max Instrument** to a MIDI track and click its edit button.
2. In Max, open `PondSynth.maxpat` (File > Open), select all (Cmd+A), copy.
3. Switch to the empty device's editor, select all, delete, paste, and save.

## Controls

On the pond:

| Gesture | Does |
|---|---|
| Drag a stone's ring on the water | where it lands |
| Drag a stone's ball up/down | drop height (when + how hard) |
| Drag a stone's ball sideways | mass (darker = heavier) |
| Drag the orange dot on the selected stone | size: tiny = restless, huge = calm |
| Double-click the water | add a stone (up to 4) |
| Drag a stone off the pond | remove it |
| Drag the orbit's cross | where you listen |
| Drag the dot on the orbit's edge | orbit size (turns orange at the wall) |
| Drag the curl handle around the rim | **Swirl** mode: whirlpool strength + direction |
| Drag the arrow handle | **Flow** mode: direction the water flows; further from the centre = faster |

Pads (stacked, next to the pond):

- **Shape:** x = corners (3 to 12, whole numbers), y = walls bent in ↔ bulging.
- **Medium:** x = water ↔ near solid, y = absorb ↔ reflect.
- **Material:** x = water ↔ stiff plate (cleaner pitch, colour that moves more), y = even ↔ grained like wood.

**Swirl / Flow** (under the pond) picks the current type.

Knobs, colour-coded by section:

| Section | Controls |
|---|---|
| **Time** | Speed, Key (pond speed follows the note), Clarity (0% = alive and shimmering, 100% = clean, steady pitch even at high Speed) |
| **Orbit** | Wander, Width, Detune, Drift |
| **Freeze** | Freeze holds a moment of the pond's life. While frozen, changing stones, shape, medium or material re-runs the pond to that same moment, so you hear every change. Breathe: 0 = nearly still, up = the water keeps moving around that moment |
| **Rain** | Rain (how many drops, 0 = off) and Drop (drop size). Rain keeps the pond moving, so notes sustain |
| **Amp** | Attack, Release, Velocity, Volume |

**Loop** (bottom row): the strip shows how loud the pond is over its first 6 pond-seconds.

| On the strip | Does |
|---|---|
| Drag the blue flag (or click an empty spot) | where notes start |
| Drag a pink bracket | loop start / end |
| Drag inside the brackets | move the whole loop |

**Off** plays the pond's life once. **Fwd** jumps back to the loop start each time it reaches the end
(with a short crossfade). **Ping** runs the pond backwards to the loop start and forwards again: the ripples
really run in reverse. White lines are the notes' playheads (pink = running backwards).

**Randomize** gives fresh stones. **View** turns the moving water display on and off.

Every control is a Live parameter, so it's saved with your set and can be automated.

## Known limits in v0.1

- Pond shape, medium, current, start point and stone changes apply to the **next** notes
  (notes already playing keep their pond).
- 8 voices. When a 9th note comes in, the oldest note fades out over ~15 ms first.
- CPU (test machine): about 4-5% of one core per note; an 8-note chord ~25%.
  Speed x key tracking is capped at 4x (more water steps = more CPU).
  Release tails that are 40 dB under their peak stop simulating and play on from a held
  snapshot, so long releases cost far less. Freeze and Material at the plate end cost about
  twice as much per note.
