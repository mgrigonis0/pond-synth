// loop.js — pond-life strip for the Pond synth device (jsui, Max 8 / ES5).
//
// Shows how loud the pond is over its first LIFE_T pond-seconds, where notes start (flag),
// the loop region (brackets) and the sounding notes' playheads.
//   drag the flag ............... where notes start (click empty strip = put the flag there)
//   drag a bracket .............. loop start / end
//   drag inside the region ...... move the whole loop
// inlet 0: parameter bus (start, lstart, lend, lmode) — view only
// inlet 1: pond~ info: "life <120 values 0..1>", "heads <t ...>" (negative t = running backwards)
// outlet 0: "<name> <value>" for start / lstart / lend

inlets = 2;
outlets = 1;
mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

var LIFE_T = 6;
var P = { start: 0, lstart: 0.3, lend: 1.2, lmode: 0 };
var life = null, heads = [];
var drag = null;

var C_TIME = [0.45, 0.66, 0.95], C_LOOP = [0.90, 0.50, 0.74], C_POND = [0.33, 0.78, 0.81];

function clamp(a, lo, hi) { return a < lo ? lo : (a > hi ? hi : a); }
function geo() {
    var sz = mgraphics.size;
    return { w: sz[0], h: sz[1], x0: 3, x1: sz[0] - 3, y0: 2, y1: sz[1] - 10 };
}
function tx(g, t) { return g.x0 + (g.x1 - g.x0) * clamp(t / LIFE_T, 0, 1); }
function xt(g, x) { return clamp((x - g.x0) / (g.x1 - g.x0), 0, 1) * LIFE_T; }
function rgba(c, a) { mgraphics.set_source_rgba(c[0], c[1], c[2], a); }

function paint() {
    var g = geo(), i;
    mgraphics.select_font_face("Arial");
    mgraphics.set_source_rgba(0.1, 0.11, 0.12, 1);
    mgraphics.rectangle(0, 0, g.w, g.h); mgraphics.fill();

    // loop region
    var la = tx(g, P.lstart), lb = tx(g, P.lend), on = P.lmode > 0;
    rgba(C_LOOP, on ? 0.2 : 0.07);
    mgraphics.rectangle(la, g.y0, lb - la, g.y1 - g.y0); mgraphics.fill();

    // pond life
    if (life && life.length > 1) {
        var n = life.length, hgt = g.y1 - g.y0 - 2;
        mgraphics.move_to(g.x0, g.y1);
        for (i = 0; i < n; i++) {
            var v = Math.sqrt(clamp(life[i], 0, 1));          // sqrt: quiet tails stay visible
            mgraphics.line_to(g.x0 + (g.x1 - g.x0) * (i + 0.5) / n, g.y1 - v * hgt);
        }
        mgraphics.line_to(g.x1, g.y1); mgraphics.close_path();
        rgba(C_POND, 0.22); mgraphics.fill();
        for (i = 0; i < n; i++) {
            var v2 = Math.sqrt(clamp(life[i], 0, 1)), px = g.x0 + (g.x1 - g.x0) * (i + 0.5) / n, py = g.y1 - v2 * hgt;
            if (i === 0) mgraphics.move_to(px, py); else mgraphics.line_to(px, py);
        }
        rgba(C_POND, 0.75); mgraphics.set_line_width(1); mgraphics.stroke();
    }

    // brackets [ ]
    rgba(C_LOOP, on ? 1 : 0.45); mgraphics.set_line_width(1.5);
    mgraphics.move_to(la + 3, g.y0 + 0.5); mgraphics.line_to(la, g.y0 + 0.5); mgraphics.line_to(la, g.y1 - 0.5); mgraphics.line_to(la + 3, g.y1 - 0.5);
    mgraphics.move_to(lb - 3, g.y0 + 0.5); mgraphics.line_to(lb, g.y0 + 0.5); mgraphics.line_to(lb, g.y1 - 0.5); mgraphics.line_to(lb - 3, g.y1 - 0.5);
    mgraphics.stroke();

    // playheads
    mgraphics.set_line_width(1);
    for (i = 0; i < heads.length; i++) {
        var hx = tx(g, Math.abs(heads[i]));
        if (heads[i] < 0) rgba(C_LOOP, 0.95); else mgraphics.set_source_rgba(0.93, 0.94, 0.95, 0.8);
        mgraphics.move_to(hx, g.y0 + 2); mgraphics.line_to(hx, g.y1); mgraphics.stroke();
    }

    // start flag
    var sx = tx(g, P.start);
    rgba(C_TIME, 1); mgraphics.set_line_width(1.2);
    mgraphics.move_to(sx, g.y0); mgraphics.line_to(sx, g.y1); mgraphics.stroke();
    mgraphics.move_to(sx, g.y0); mgraphics.line_to(sx + 6, g.y0 + 3); mgraphics.line_to(sx, g.y0 + 6); mgraphics.close_path(); mgraphics.fill();

    // time ticks
    mgraphics.set_font_size(7);
    for (var s = 0; s <= LIFE_T; s++) {
        var kx = tx(g, s);
        mgraphics.set_source_rgba(0.6, 0.62, 0.64, 0.5);
        mgraphics.rectangle(kx - 0.5, g.y1, 1, 2); mgraphics.fill();
        mgraphics.set_source_rgba(0.6, 0.62, 0.64, 0.85);
        var lbl = s + (s === LIFE_T ? " s" : "");
        mgraphics.move_to(clamp(kx - 2, 0, g.w - 10), g.h - 1); mgraphics.show_text(lbl);
    }
}

function send(name, v) { P[name] = v; outlet(0, name, v); }

function onclick(x, y, but, cmd, shift, capslock, option, ctrl) {
    var g = geo(), sx = tx(g, P.start), la = tx(g, P.lstart), lb = tx(g, P.lend), t = xt(g, x);
    drag = null;
    if (Math.abs(x - sx) <= 4) drag = { kind: "start" };
    else if (Math.abs(x - la) <= 4) drag = { kind: "lstart" };
    else if (Math.abs(x - lb) <= 4) drag = { kind: "lend" };
    else if (x > la && x < lb) drag = { kind: "move", t0: t, a0: P.lstart, b0: P.lend };
    else { drag = { kind: "start" }; send("start", Math.round(t * 100) / 100); }
    mgraphics.redraw();
}

function ondrag(x, y, but, cmd, shift, capslock, option, ctrl) {
    if (!drag) return;
    if (!but) { drag = null; return; }
    var g = geo(), t = xt(g, x), MIN = 0.02;
    if (drag.kind === "start") send("start", t);
    else if (drag.kind === "lstart") send("lstart", clamp(t, 0, P.lend - MIN));
    else if (drag.kind === "lend") send("lend", clamp(t, P.lstart + MIN, LIFE_T));
    else if (drag.kind === "move") {
        var len = drag.b0 - drag.a0, a = clamp(drag.a0 + (t - drag.t0), 0, LIFE_T - len);
        send("lstart", a); send("lend", a + len);
    }
    mgraphics.redraw();
}

function anything() {
    var args = arrayfromargs(arguments), name = messagename;
    if (inlet === 1) {
        if (name === "life") { life = args; mgraphics.redraw(); }
        else if (name === "heads") { heads = args; mgraphics.redraw(); }
        return;
    }
    if (P.hasOwnProperty(name) && args.length) { P[name] = args[0]; mgraphics.redraw(); }
}
function heads_clear() { heads = []; }
function bang() { mgraphics.redraw(); }
function onresize() { mgraphics.redraw(); }
