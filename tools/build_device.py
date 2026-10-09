#!/usr/bin/env python3
"""Generate the Pond synth Max for Live device.

Writes device/PondSynth.maxpat (plain patcher) and device/PondSynth.amxd (the same
patcher wrapped as an unfrozen Live instrument).

Signal flow:   notein -> pack -> [prepend note] -> pond~ -> plugout~
Parameter bus: every Live parameter -> [prepend <name>] -> [s ---pp]
               [r ---pp] -> pond~, pond.js (view), pads.js (view)
UI edits:      pond.js / pads.js -> [route names...] -> the matching Live parameter
"""
import json
import struct
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "device"

boxes, lines = [], []
_n = [0]


def box(maxclass, rect, text=None, ins=1, outs=1, outtypes=None, pres=None, **extra):
    _n[0] += 1
    bid = f"obj-{_n[0]}"
    b = {"id": bid, "maxclass": maxclass, "numinlets": ins, "numoutlets": outs,
         "patching_rect": list(rect)}
    if outs:
        b["outlettype"] = outtypes if outtypes is not None else [""] * outs
    if text is not None:
        b["text"] = text
    if pres is not None:
        b["presentation"] = 1
        b["presentation_rect"] = list(pres)
    b.update(extra)
    boxes.append({"box": b})
    return bid


def obj(text, rect, ins=1, outs=1, outtypes=None, **extra):
    return box("newobj", rect, text=text, ins=ins, outs=outs, outtypes=outtypes, **extra)


def wire(src, so, dst, di):
    lines.append({"patchline": {"source": [src, so], "destination": [dst, di]}})


def valueof(longname, short, ptype, lo, hi, init, unitstyle=1, exponent=1.0, units=None, enum=None):
    v = {"parameter_longname": longname, "parameter_shortname": short, "parameter_type": ptype,
         "parameter_mmin": lo, "parameter_mmax": hi, "parameter_initial": [init],
         "parameter_initial_enable": 1, "parameter_unitstyle": unitstyle}
    if exponent != 1.0:
        v["parameter_exponent"] = exponent
    if units:
        v["parameter_units"] = units
    if enum:
        v["parameter_enum"] = enum
    return {"valueof": v}


# --------------------------------------------------------------------------- params
# name, longname, shortname, type(0 float,1 int,2 enum), min, max, init, unitstyle, exponent, units
# unitstyle: 0 int, 1 float, 2 time, 4 dB, 5 %, 9 custom
DIALS = [
    ("start", "Start", "Start", 0, 0.0, 4.0, 0.0, 9, 1.0, "%.2f s"),
    ("speed", "Pond Speed", "Speed", 0, 0.1, 4.0, 1.0, 9, 2.0, "%.2fx"),
    ("wander", "Wander", "Wander", 0, 0.0, 100.0, 0.0, 5, 1.0, None),
    ("width", "Width", "Width", 0, 0.0, 100.0, 50.0, 5, 1.0, None),
    ("detune", "Detune", "Detune", 0, 0.0, 30.0, 6.0, 9, 1.0, "%.1f ct"),
    ("drift", "Drift", "Drift", 0, 0.0, 100.0, 20.0, 5, 1.0, None),
    ("attack", "Attack", "Attack", 0, 1.0, 2000.0, 8.0, 2, 3.0, None),
    ("release", "Release", "Release", 0, 10.0, 5000.0, 400.0, 2, 3.0, None),
    ("velamt", "Velocity", "Velocity", 0, 0.0, 100.0, 70.0, 5, 1.0, None),
    ("volume", "Volume", "Volume", 0, -36.0, 6.0, -6.0, 4, 1.0, None),
]
TOGGLES = [  # name, longname, short, init, off text, on text
    ("keytrack", "Key Tracking", "Key", 1, "Key", "Key"),
    ("freeze", "Freeze", "Freeze", 0, "Freeze", "Freeze"),
    ("display", "Pond View", "View", 1, "View", "View"),
]
STONE_DEF = [(0.5, -0.22, 0.55, 0.35, 0.5), (-0.45, 0.3, 0.25, 0.2, 0.85),
             (0.12, 0.55, 0.8, 0.55, 0.3), (-0.3, -0.4, 0.4, 0.3, 0.5)]
HIDDEN = [  # set by pond.js / pads.js gestures, stored + automatable in Live
    ("corners", "Corners", "Corners", 0, 3.0, 12.0, 5.0),
    ("walls", "Walls", "Walls", 0, -1.0, 1.0, 0.2),
    ("visc", "Viscosity", "Visc", 0, 0.0, 1.0, 0.25),
    ("refl", "Reflect", "Reflect", 0, 0.0, 1.0, 0.8),
    ("current", "Current", "Current", 0, -1.0, 1.0, 0.25),
    ("ox", "Orbit X", "Orbit X", 0, -1.0, 1.0, 0.12),
    ("oy", "Orbit Y", "Orbit Y", 0, -1.0, 1.0, -0.1),
    ("osize", "Orbit Size", "Orbit Sz", 0, 0.0, 1.0, 0.4),
    ("nstones", "Stones", "Stones", 1, 1, 4, 3),
]
for i, (x, y, h, s, m) in enumerate(STONE_DEF, start=1):
    for key, label, lo, hi, init in (("x", "X", -1.0, 1.0, x), ("y", "Y", -1.0, 1.0, y), ("h", "Height", 0.0, 1.0, h),
                                     ("s", "Size", 0.0, 1.0, s), ("m", "Mass", 0.0, 1.0, m)):
        HIDDEN.append((f"s{i}{key}", f"Stone {i} {label}", f"S{i} {label}", 0, lo, hi, init))

# --------------------------------------------------------------------------- core
notein = obj("notein", (30, 30, 50, 22), ins=1, outs=3, outtypes=["int", "int", "int"])
pack = obj("pack 0 0", (30, 60, 60, 22), ins=2, outs=1)
pnote = obj("prepend note", (30, 90, 80, 22))
pond = obj("pond~", (30, 140, 120, 22), ins=1, outs=3, outtypes=["signal", "signal", ""])
plugout = obj("plugout~", (30, 190, 60, 22), ins=2, outs=0)
wire(notein, 0, pack, 0); wire(notein, 1, pack, 1); wire(pack, 0, pnote, 0); wire(pnote, 0, pond, 0)
wire(pond, 0, plugout, 0); wire(pond, 1, plugout, 1)

rbus = obj("r ---pp", (200, 30, 60, 22), ins=0, outs=1)
wire(rbus, 0, pond, 0)

# load-time push of every parameter value
thisdev = obj("live.thisdevice", (900, 30, 90, 22), ins=1, outs=3, outtypes=["bang", "int", "int"])
initb = obj("t b", (900, 60, 30, 22), ins=1, outs=1, outtypes=["bang"])
wire(thisdev, 0, initb, 0)

# --------------------------------------------------------------------------- UI
DEV_H = 169
pondui = box("jsui", (200, 260, 172, 142), ins=2, outs=1, pres=(4, 4, 172, 142), filename="pond.js",
             parameter_enable=0, border=0)
padsui = box("jsui", (400, 260, 226, 161), ins=1, outs=1, pres=(182, 4, 222, 160), filename="pads.js",
             parameter_enable=0, border=0)
wire(rbus, 0, pondui, 0); wire(rbus, 0, padsui, 0)
wire(pond, 2, pondui, 1)             # frames, live orbit, randomized stones
wire(initb, 0, pondui, 0); wire(initb, 0, padsui, 0)

# randomize button (momentary) -> pond~ randomize
rnd = box("live.text", (200, 420, 70, 17), ins=1, outs=2, outtypes=["", ""], pres=(4, 149, 82, 16),
          text="Randomize", texton="Randomize", mode=0, varname="Randomize", parameter_enable=1,
          saved_attribute_attributes=valueof("Randomize", "Randomize", 2, 0, 1, 0, unitstyle=9, enum=["off", "on"]))
rroute = obj("route bang", (200, 445, 70, 22), ins=2, outs=2)
rsel = obj("sel 1", (280, 470, 40, 22), ins=2, outs=2, outtypes=["bang", ""])
rmsg = box("message", (200, 500, 70, 22), text="randomize", ins=2, outs=1)
wire(rnd, 0, rroute, 0); wire(rroute, 0, rmsg, 0); wire(rroute, 1, rsel, 0); wire(rsel, 0, rmsg, 0); wire(rmsg, 0, pond, 0)

# --------------------------------------------------------------------------- parameters
sbus = obj("s ---pp", (700, 700, 60, 22), ins=1, outs=0)
param_obj = {}


def bus_out(name, src, x, y, init_bang=True, scale=None):
    pre = obj(f"prepend {name}", (x, y, 100, 22))
    if scale is not None:            # e.g. % dials (0..100) -> 0..1 for pond~
        sc = obj(f"* {scale}", (x, y - 22, 50, 22), ins=2, outs=1)
        wire(src, 0, sc, 0); wire(sc, 0, pre, 0)
    else:
        wire(src, 0, pre, 0)
    wire(pre, 0, sbus, 0)
    if init_bang:                   # bang -> dial/numbox re-outputs its value at load
        wire(initb, 0, src, 0)      # (not for toggles: a bang would flip them)


# visible dials: time block + 4x2 knob grid
pres_pos = {"start": (412, 18), "speed": (458, 18)}
grid = ["wander", "width", "detune", "drift", "attack", "release", "velamt", "volume"]
for k, n in enumerate(grid):
    pres_pos[n] = (512 + (k % 4) * 48, 6 + (k // 4) * 80)
for k, (name, longn, short, ptype, lo, hi, init, ustyle, expo, units) in enumerate(DIALS):
    px, py = pres_pos[name]
    d = box("live.dial", (700 + (k % 5) * 90, 80 + (k // 5) * 90, 44, 48), ins=1, outs=2, outtypes=["", "float"],
            pres=(px, py, 44, 48), varname=longn, parameter_enable=1,
            saved_attribute_attributes=valueof(longn, short, ptype, lo, hi, init, ustyle, expo, units))
    param_obj[name] = d
    bus_out(name, d, 700 + (k % 5) * 90, 135 + (k // 5) * 90, scale=0.01 if ustyle == 5 else None)

# toggles under the time dials
tog_pres = {"keytrack": (412, 92, 44, 17), "freeze": (458, 92, 44, 17), "display": (90, 149, 40, 16)}
for k, (name, longn, short, init, off, on) in enumerate(TOGGLES):
    t = box("live.text", (700 + k * 90, 300, 44, 17), ins=1, outs=2, outtypes=["", ""], pres=tog_pres[name],
            text=off, texton=on, mode=1, varname=longn, parameter_enable=1,
            saved_attribute_attributes=valueof(longn, short, 2, 0, 1, init, unitstyle=9, enum=["off", "on"]))
    param_obj[name] = t
    bus_out(name, t, 700 + k * 90, 325, init_bang=False)

# hidden parameters driven by the pond / pad gestures
for k, (name, longn, short, ptype, lo, hi, init) in enumerate(HIDDEN):
    x, y = 700 + (k % 8) * 110, 400 + (k // 8) * 70
    nb = box("live.numbox", (x, y, 50, 15), ins=1, outs=2, outtypes=["", "float"], varname=longn, parameter_enable=1,
             saved_attribute_attributes=valueof(longn, short, ptype, lo, hi, init, unitstyle=0 if ptype == 1 else 1))
    param_obj[name] = nb
    bus_out(name, nb, x, y + 25)

# UI gestures -> the matching parameter object
hidden_names = [h[0] for h in HIDDEN]
route_ui = obj("route " + " ".join(hidden_names), (200, 560, 400, 22), ins=2, outs=len(hidden_names) + 1)
wire(pondui, 0, route_ui, 0)
wire(padsui, 0, route_ui, 0)
for k, name in enumerate(hidden_names):
    wire(route_ui, k, param_obj[name], 0)

# section labels
for txt, rect in (("Time", (412, 4, 60, 14)), ("Orbit", (512, 70, 60, 14)), ("Envelope", (512, 150, 80, 14))):
    pass  # kept minimal: knob names come from the Live parameter short names

DEVICE_W = 512 + 4 * 48 + 6

patcher = {
    "patcher": {
        "fileversion": 1,
        "appversion": {"major": 8, "minor": 6, "revision": 4, "architecture": "x64", "modernui": 1},
        "classnamespace": "box",
        "rect": [80.0, 80.0, 1700.0, 900.0],
        "openrect": [0.0, 0.0, float(DEVICE_W), float(DEV_H)],
        "bglocked": 0, "openinpresentation": 1,
        "default_fontsize": 10.0, "default_fontface": 0, "default_fontname": "Arial Bold",
        "gridonopen": 1, "gridsize": [8.0, 8.0], "gridsnaponopen": 1, "objectsnaponopen": 1,
        "statusbarvisible": 2, "toolbarvisible": 1, "boxanimatetime": 500, "enablehscroll": 1,
        "enablevscroll": 1, "devicewidth": float(DEVICE_W), "description": "Pond synth v0.1",
        "digest": "", "tags": "", "style": "", "subpatcher_template": "",
        "boxes": boxes, "lines": lines,
        "dependency_cache": [
            {"name": "pond.js", "bootpath": ".", "patcherrelativepath": ".", "type": "TEXT", "implicit": 1},
            {"name": "pads.js", "bootpath": ".", "patcherrelativepath": ".", "type": "TEXT", "implicit": 1},
            {"name": "pond~.mxo", "type": "iLaX"},
        ],
        "latency": 0, "is_mpe": 0, "minimum_live_version": "", "minimum_max_version": "",
        "platform_compatibility": 0,
        "project": {
            "version": 1, "creationdate": 3590052493, "modificationdate": 3590052493,
            "viewrect": [0.0, 0.0, 300.0, 500.0], "autoorganize": 1, "hideprojectwindow": 1,
            "showdependencies": 1, "autolocalize": 0, "contents": {"patchers": {}},
            "layout": {}, "searchpath": {}, "detailsvisible": 0,
            "amxdtype": 1768515945, "readonly": 0, "devpathtype": 0, "devpath": ".",
            "sortmode": 0, "viewmode": 0, "includepackages": 0,
        },
        "autosave": 0,
    }
}


def amxd(patch_json: bytes, devtype: bytes = b"iiii") -> bytes:
    """Unfrozen device container: ampf(type) + meta + ptch(JSON, NUL-terminated), little-endian lengths."""
    body = patch_json + b"\x00"
    return (b"ampf" + struct.pack("<I", 4) + devtype +
            b"meta" + struct.pack("<I", 4) + struct.pack("<I", 0) +
            b"ptch" + struct.pack("<I", len(body)) + body)


def main():
    OUT.mkdir(exist_ok=True)
    text = json.dumps(patcher, indent="\t").encode("utf-8")
    (OUT / "PondSynth.maxpat").write_bytes(text)
    (OUT / "PondSynth.amxd").write_bytes(amxd(text))
    ids = {b["box"]["id"] for b in boxes}
    for l in lines:
        s, d = l["patchline"]["source"], l["patchline"]["destination"]
        assert s[0] in ids and d[0] in ids, l
    print(f"{len(boxes)} boxes, {len(lines)} connections, {len(DIALS) + len(TOGGLES) + len(HIDDEN) + 1} Live parameters, "
          f"device {DEVICE_W}x{DEV_H}")


if __name__ == "__main__":
    main()
