# Pond synth v0.1 — install and first test

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
| Drag the curl handle around the rim | current strength + direction |

Pads: **Shape** (x = corners, y = walls bent in ↔ bulging) and **Medium**
(x = water ↔ syrup, y = absorb ↔ reflect).

Knobs: Start, Speed, Key (pond speed follows the note), Freeze, Wander, Width, Detune,
Drift, Attack, Release, Velocity, Volume. **Randomize** gives fresh stones; **View** turns
the moving water display on and off.

Every control is a Live parameter, so it's saved with your set and can be automated.

## Known limits in v0.1

- Pond shape, medium, current, start point and stone changes apply to the **next** notes
  (notes already playing keep their pond).
- No loops or ping-pong yet (v0.2).
- CPU: about 6% of one core for a single note on the test machine, up to ~33% for
  4 high notes with a strong current.
