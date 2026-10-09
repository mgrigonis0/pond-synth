// pond.js — pond view + drag gestures for the Pond synth device (jsui, Max 8 / ES5).
//
// inlet 0: parameter bus ("<name> <value>") — updates the view only, never re-sent
// inlet 1: pond~ info ("frame ...", "orbit x y r", "voices n", randomized "s1x v" ...)
// outlet 0: "<name> <value>" for parameters the user changed (goes to the Live params)
//
// Gestures:
//   drag a stone's ring on the water ........ landing spot
//   drag a stone's ball up/down ............. drop height; sideways = mass (direction locks)
//   drag the orange dot of the selected stone  size
//   double-click water ...................... add a stone (max 4)
//   drag a stone off the pond ............... remove it (one always stays)
//   drag the orbit's cross .................. where you listen; edge dot = orbit size
//   whirlpool: drag the curl handle around the rim ... strength + direction
//   flow: drag the arrow handle .................... direction; further from centre = faster

inlets = 2;
outlets = 1;
mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

var T = 0.55;                // tilt (vertical squash)
var MAXST = 4;
var P = {
    corners: 5, walls: 0.2, visc: 0.25, refl: 1, current: 0.25, cmode: 0, cdir: 0,
    ox: 0.12, oy: -0.1, osize: 0.4, width: 0.5, nstones: 3, display: 1
};
var stones = [
    { x: 0.5, y: -0.22, h: 0.55, s: 0.35, m: 0.5 },
    { x: -0.45, y: 0.3, h: 0.25, s: 0.2, m: 0.85 },
    { x: 0.12, y: 0.55, h: 0.8, s: 0.55, m: 0.3 },
    { x: -0.3, y: -0.4, h: 0.4, s: 0.3, m: 0.5 }
];
var live = { x: 0.12, y: -0.1, r: 0.3, have: false };   // where pond~ says the orbit is
var frameData = null, frameN = 36, voices = 0;
var R = null;            // boundary radius table
var ANG = 360;
var sel = 0;             // selected stone index, -1 = none / orbit
var drag = null;         // current gesture
var outside = false;

// ---------------- geometry (mirrors pond_engine.h) ----------------
function boundaryFor(m, walls) {
    var Rr = 0.92, out = [], hit = [], b, i, k;
    for (b = 0; b < ANG; b++) { out[b] = 0; hit[b] = 0; }
    for (i = 0; i < m; i++) {
        var a0 = -Math.PI / 2 + i * 2 * Math.PI / m, a1 = a0 + 2 * Math.PI / m, am = (a0 + a1) / 2;
        var ap = Rr * Math.cos(Math.PI / m), sag = Rr - ap;
        var off = walls >= 0 ? ap + walls * 2 * sag : ap + walls * ap * 0.85;
        var p0x = Rr * Math.cos(a0), p0y = Rr * Math.sin(a0), p1x = Rr * Math.cos(a1), p1y = Rr * Math.sin(a1);
        var qx = off * Math.cos(am), qy = off * Math.sin(am);
        for (k = 0; k < 96; k++) {
            var t = k / 96, u = 1 - t;
            var x = u * u * p0x + 2 * u * t * qx + t * t * p1x, y = u * u * p0y + 2 * u * t * qy + t * t * p1y;
            var th = Math.atan2(y, x); if (th < 0) th += 2 * Math.PI;
            var bin = Math.min(ANG - 1, Math.floor(th / (2 * Math.PI) * ANG));
            var r = Math.sqrt(x * x + y * y);
            if (!hit[bin] || r > out[bin]) out[bin] = r;
            hit[bin] = 1;
        }
    }
    for (b = 0; b < ANG; b++) {
        if (hit[b]) continue;
        var l = b, rr = b;
        while (!hit[(l + ANG) % ANG]) l--;
        while (!hit[rr % ANG]) rr++;
        var fl = out[(l + ANG) % ANG], fr = out[rr % ANG];
        out[b] = fl + (fr - fl) * (b - l) / (rr - l);
    }
    return out;
}
function rebuildShape() {
    var c = Math.max(3, Math.min(12, P.corners)), m0 = Math.floor(c), m1 = Math.min(12, m0 + 1), f = c - m0;
    var A = boundaryFor(m0, P.walls), B = boundaryFor(m1, P.walls);
    R = [];
    for (var b = 0; b < ANG; b++) R[b] = A[b] + (B[b] - A[b]) * f;
    fitDirty = true;
}
function radiusAt(th) {
    if (th < 0) th += 2 * Math.PI;
    var fb = th / (2 * Math.PI) * ANG, b0 = Math.floor(fb) % ANG, b1 = (b0 + 1) % ANG, t = fb - Math.floor(fb);
    return R[b0] + (R[b1] - R[b0]) * t;
}
function inside(x, y) { return Math.sqrt(x * x + y * y) < radiusAt(Math.atan2(y, x)); }
function wallDist(x, y) {
    var best = 9;
    for (var b = 0; b < ANG; b += 3) {
        var th = (b + 0.5) / ANG * 2 * Math.PI, bx = R[b] * Math.cos(th), by = R[b] * Math.sin(th);
        best = Math.min(best, Math.sqrt((bx - x) * (bx - x) + (by - y) * (by - y)));
    }
    return best;
}
function orbitCap(x, y) { return Math.max(0.04, wallDist(x, y) - P.width * 0.08 - 0.05); }
function orbitRadius() { var cap = orbitCap(P.ox, P.oy); return 0.04 + P.osize * (cap - 0.04); }
function stoneRingR(st) { var sigma = 0.8 + Math.pow(st.s, 1.5) * 11; return 2 * sigma * 2 / 108; }

// current handle: whirlpool = on the rim by strength; flow = along the flow direction
function handleWorld() {
    if (P.cmode == 1) {
        var r = 0.12 + 0.68 * Math.abs(P.current), sg = P.current >= 0 ? 1 : -1;
        return [sg * r * Math.cos(P.cdir), sg * r * Math.sin(P.cdir)];
    }
    var ca = -Math.PI / 2 + P.current * Math.PI * 0.9;
    return [0.8 * Math.cos(ca), 0.8 * Math.sin(ca)];
}

// ---------------- screen mapping ----------------
// Fit the actual pond + stones (+ the curl handle) into the box, centred, with a small
// margin. Cached: refitted when the shape or stone positions change, never mid-drag.
var fit = null, fitDirty = true, fitW = 0, fitH = 0;
var MARGIN = 6, MAXSTEM = 0.48;
function boundsFor(t) {
    var minx = 1e9, maxx = -1e9, miny = 1e9, maxy = -1e9, b, i;
    function add(x, y) { if (x < minx) minx = x; if (x > maxx) maxx = x; if (y < miny) miny = y; if (y > maxy) maxy = y; }
    for (b = 0; b < ANG; b += 2) {
        var th = (b + 0.5) / ANG * 2 * Math.PI;
        add(R[b] * Math.cos(th), R[b] * Math.sin(th) * t);
    }
    for (i = 0; i < P.nstones; i++) {           // room for the tallest possible stem at each stone
        var st = stones[i];
        add(st.x - 0.06, st.y * t - MAXSTEM - 0.07);
        add(st.x + 0.06, st.y * t);
    }
    var hw = handleWorld();
    add(hw[0], hw[1] * t);
    return [minx, maxx, miny, maxy];
}
function computeFit(w, h) {
    // largest tilt (0.5..0.7, keeps the tilted look) whose content still fits the box at full width
    var best = null;
    for (var t = 0.7; t >= 0.499; t -= 0.02) {
        var bb = boundsFor(t), spanX = Math.max(0.2, bb[1] - bb[0]), spanY = Math.max(0.2, bb[3] - bb[2]);
        var sc = Math.min((w - 2 * MARGIN) / spanX, (h - 2 * MARGIN) / spanY);
        if (!best || sc > best.sc + 0.5 || (Math.abs(sc - best.sc) <= 0.5 && t > best.t)) best = { t: t, sc: sc, bb: bb };
    }
    T = best.t;
    var b2 = best.bb;
    return { w: w, h: h, sc: best.sc, cx: w / 2 - best.sc * (b2[0] + b2[1]) / 2, cy: h / 2 - best.sc * (b2[2] + b2[3]) / 2 };
}
function view() {
    var sz = mgraphics.size, w = sz[0], h = sz[1];
    if (!R) rebuildShape();
    if (!fit || w !== fitW || h !== fitH || (fitDirty && !drag)) {
        fit = computeFit(w, h); fitW = w; fitH = h; fitDirty = false;
    }
    return fit;
}
function toScreen(v, x, y) { return [v.cx + x * v.sc, v.cy + y * v.sc * T]; }
function toWorld(v, sx, sy) { return [(sx - v.cx) / v.sc, (sy - v.cy) / (v.sc * T)]; }
function stemLen(v, st) { return (0.1 + st.h * 0.38) * v.sc; }
function clamp(a, lo, hi) { return a < lo ? lo : (a > hi ? hi : a); }

// ---------------- drawing ----------------
function ellipseAt(cx, cy, rx, ry) { mgraphics.ellipse(cx - rx, cy - ry, rx * 2, ry * 2); }
function pondPath(v) {
    for (var b = 0; b <= ANG; b += 4) {
        var th = (b % ANG) / ANG * 2 * Math.PI, r = R[b % ANG], p = toScreen(v, r * Math.cos(th), r * Math.sin(th));
        if (b === 0) mgraphics.move_to(p[0], p[1]); else mgraphics.line_to(p[0], p[1]);
    }
    mgraphics.close_path();
}

function paint() {
    if (!R) rebuildShape();
    var v = view(), i;
    mgraphics.set_source_rgba(0.12, 0.13, 0.15, 1);
    mgraphics.rectangle(0, 0, v.w, v.h); mgraphics.fill();

    // water body (tint follows viscosity)
    var vi = P.visc;
    mgraphics.set_source_rgba(0.11 + 0.25 * vi, 0.38 - 0.11 * vi, 0.45 - 0.32 * vi, 1);
    pondPath(v); mgraphics.fill();

    // live water heights
    if (P.display && frameData) {
        var n = frameN, cw = 2 / n;
        for (var gy = 0; gy < n; gy++) {
            for (var gx = 0; gx < n; gx++) {
                var hgt = frameData[gy * n + gx];
                if (hgt > -0.04 && hgt < 0.04) continue;
                var wx = (gx + 0.5) / n * 2 - 1, wy = (gy + 0.5) / n * 2 - 1;
                if (!inside(wx, wy)) continue;
                var p = toScreen(v, wx - cw / 2, wy - cw / 2);
                if (hgt > 0) mgraphics.set_source_rgba(0.75, 0.92, 0.95, Math.min(0.8, hgt * 0.9));
                else mgraphics.set_source_rgba(0.02, 0.08, 0.12, Math.min(0.8, -hgt * 0.9));
                mgraphics.rectangle(p[0], p[1], cw * v.sc + 0.6, cw * v.sc * T + 0.6);
                mgraphics.fill();
            }
        }
    }

    // walls (thicker = more reflective)
    mgraphics.set_source_rgba(0.66, 0.86, 0.89, 0.35 + 0.6 * P.refl);
    mgraphics.set_line_width(0.6 + 1.6 * P.refl);
    pondPath(v); mgraphics.stroke();

    // current arrows
    var c = P.current, dir = c >= 0 ? 1 : -1;
    mgraphics.set_source_rgba(0.81, 0.91, 0.93, 0.12 + Math.abs(c) * 0.6);
    mgraphics.set_line_width(1);
    if (P.cmode == 1) {                        // flow: parallel arrows across the pond
        var fx = dir * Math.cos(P.cdir), fy = dir * Math.sin(P.cdir), nx = -fy, ny = fx;
        for (var j2 = -2; j2 <= 2; j2++) {
            for (var r2 = -1; r2 <= 1; r2 += 2) {
                var bx = nx * j2 * 0.28 + fx * r2 * 0.3, by = ny * j2 * 0.28 + fy * r2 * 0.3;
                if (!inside(bx, by)) continue;
                var A0 = toScreen(v, bx - fx * 0.12, by - fy * 0.12), A1 = toScreen(v, bx + fx * 0.12, by + fy * 0.12);
                var H1 = toScreen(v, bx + fx * 0.06 + nx * 0.05, by + fy * 0.06 + ny * 0.05), H2 = toScreen(v, bx + fx * 0.06 - nx * 0.05, by + fy * 0.06 - ny * 0.05);
                mgraphics.move_to(A0[0], A0[1]); mgraphics.line_to(A1[0], A1[1]);
                mgraphics.move_to(H1[0], H1[1]); mgraphics.line_to(A1[0], A1[1]); mgraphics.line_to(H2[0], H2[1]);
                mgraphics.stroke();
            }
        }
    } else for (var j = 0; j < 3; j++) {
        var a0 = j * 2 * Math.PI / 3 + 0.4, a1 = a0 + dir * 0.75;
        for (var q = 0; q <= 10; q++) {
            var a = a0 + (a1 - a0) * q / 10, pp = toScreen(v, 0.6 * Math.cos(a), 0.6 * Math.sin(a));
            if (q === 0) mgraphics.move_to(pp[0], pp[1]); else mgraphics.line_to(pp[0], pp[1]);
        }
        mgraphics.stroke();
    }

    // stone rings (on the water)
    for (i = 0; i < P.nstones; i++) {
        var st = stones[i], L = toScreen(v, st.x, st.y), rr = stoneRingR(st) * v.sc;
        mgraphics.set_source_rgba(0.04, 0.16, 0.19, 0.5);
        ellipseAt(L[0], L[1], rr, rr * T); mgraphics.fill();
        if (i === sel) mgraphics.set_source_rgba(0.9, 0.64, 0.24, 1); else mgraphics.set_source_rgba(0.81, 0.91, 0.93, 0.8);
        mgraphics.set_line_width(i === sel ? 1.6 : 0.8);
        ellipseAt(L[0], L[1], rr, rr * T); mgraphics.stroke();
    }

    // orbits (two ears)
    var ox = live.have ? live.x : P.ox, oy = live.have ? live.y : P.oy, orad = live.have ? live.r : orbitRadius();
    var cap = orbitCap(P.ox, P.oy), atCap = orbitRadius() >= cap - 0.005;
    var ow = P.width * 0.08;
    for (var e = 0; e < 2; e++) {
        var C = toScreen(v, ox + (e ? ow : -ow), oy);
        if (atCap) mgraphics.set_source_rgba(0.91, 0.53, 0.35, e ? 0.6 : 0.95);
        else mgraphics.set_source_rgba(0.91, 0.92, 0.93, e ? 0.5 : 0.9);
        mgraphics.set_line_width(1);
        ellipseAt(C[0], C[1], orad * v.sc, orad * v.sc * T); mgraphics.stroke();
    }
    var OC = toScreen(v, P.ox, P.oy), k = 4;
    mgraphics.set_source_rgba(0.91, 0.92, 0.93, 1); mgraphics.set_line_width(1.4);
    mgraphics.move_to(OC[0] - k, OC[1]); mgraphics.line_to(OC[0] + k, OC[1]);
    mgraphics.move_to(OC[0], OC[1] - k * T); mgraphics.line_to(OC[0], OC[1] + k * T); mgraphics.stroke();
    var RH = toScreen(v, P.ox + orbitRadius(), P.oy);
    ellipseAt(RH[0], RH[1], 2.6, 2.6); mgraphics.fill();

    // stones: stems + balls
    for (i = 0; i < P.nstones; i++) {
        var s2 = stones[i], Ls = toScreen(v, s2.x, s2.y), top = Ls[1] - stemLen(v, s2);
        mgraphics.set_source_rgba(0.72, 0.74, 0.76, 0.8); mgraphics.set_line_width(0.8);
        mgraphics.move_to(Ls[0], Ls[1]); mgraphics.line_to(Ls[0], top); mgraphics.stroke();
        var br = 2.4 + s2.s * 3.2, m = s2.m;
        mgraphics.set_source_rgba((242 + (150 - 242) * m) / 255, (196 + (88 - 196) * m) / 255, (128 + (30 - 128) * m) / 255, 1);
        ellipseAt(Ls[0], top, br, br); mgraphics.fill();
        if (i === sel) {
            mgraphics.set_source_rgba(0.9, 0.64, 0.24, 1); mgraphics.set_line_width(1.2);
            ellipseAt(Ls[0], top, br + 1.2, br + 1.2); mgraphics.stroke();
            var H = toScreen(v, s2.x + stoneRingR(s2), s2.y);
            ellipseAt(H[0], H[1], 2.8, 2.8); mgraphics.fill();
        }
    }

    // current handle (whirlpool: on the rim; flow: along the flow, with a line from the centre)
    var hw0 = handleWorld(), CP = toScreen(v, hw0[0], hw0[1]);
    if (P.cmode == 1) {
        var C0 = toScreen(v, 0, 0);
        mgraphics.set_source_rgba(0.81, 0.91, 0.93, 0.6); mgraphics.set_line_width(1);
        mgraphics.move_to(C0[0], C0[1]); mgraphics.line_to(CP[0], CP[1]); mgraphics.stroke();
    }
    mgraphics.set_source_rgba(0.15, 0.16, 0.18, 1); ellipseAt(CP[0], CP[1], 4.5, 4.5); mgraphics.fill();
    mgraphics.set_source_rgba(0.81, 0.91, 0.93, 1); mgraphics.set_line_width(1); ellipseAt(CP[0], CP[1], 4.5, 4.5); mgraphics.stroke();

    if (outside) {
        mgraphics.set_source_rgba(0.91, 0.53, 0.35, 1);
        mgraphics.select_font_face("Arial"); mgraphics.set_font_size(9);
        mgraphics.move_to(4, 11); mgraphics.show_text("release to remove");
    }
}

// ---------------- hit testing ----------------
function dist(ax, ay, bx, by) { return Math.sqrt((ax - bx) * (ax - bx) + (ay - by) * (ay - by)); }
function hitTest(x, y) {
    var v = view(), i;
    if (sel >= 0 && sel < P.nstones) {
        var s = stones[sel], H = toScreen(v, s.x + stoneRingR(s), s.y);
        if (dist(x, y, H[0], H[1]) < 6) return { kind: "size", i: sel };
    }
    var RH = toScreen(v, P.ox + orbitRadius(), P.oy);
    if (dist(x, y, RH[0], RH[1]) < 5) return { kind: "radius" };
    var OC = toScreen(v, P.ox, P.oy);
    if (dist(x, y, OC[0], OC[1]) < 5) return { kind: "orbit" };
    for (i = P.nstones - 1; i >= 0; i--) {
        var st = stones[i], L = toScreen(v, st.x, st.y), top = L[1] - stemLen(v, st);
        if (dist(x, y, L[0], top) < 7) return { kind: "ball", i: i };
    }
    var hwh = handleWorld(), CP = toScreen(v, hwh[0], hwh[1]);
    if (dist(x, y, CP[0], CP[1]) < 7) return { kind: "curl" };
    for (i = P.nstones - 1; i >= 0; i--) {
        var s3 = stones[i], L3 = toScreen(v, s3.x, s3.y), rr = stoneRingR(s3) * v.sc;
        var dx = (x - L3[0]) / Math.max(4, rr), dy = (y - L3[1]) / Math.max(3, rr * T);
        if (dx * dx + dy * dy < 1.2) return { kind: "stone", i: i };
    }
    return null;
}

// ---------------- output helpers ----------------
var F = ["x", "y", "h", "s", "m"];
function sendStone(i) {
    var st = stones[i];
    for (var k = 0; k < 5; k++) outlet(0, "s" + (i + 1) + F[k], st[F[k]]);
}
function send(name, val) { P[name] = val; outlet(0, name, val); }

// ---------------- mouse ----------------
function onclick(x, y, but, cmd, shift, capslock, option, ctrl) {
    var h = hitTest(x, y);
    drag = h;
    if (!h) { mgraphics.redraw(); return; }
    h.x0 = x; h.y0 = y;
    if (h.i !== undefined) { sel = h.i; h.h0 = stones[h.i].h; h.m0 = stones[h.i].m; h.axis = null; }
    else if (h.kind === "orbit" || h.kind === "radius") sel = -1;
    mgraphics.redraw();
}

function ondrag(x, y, but, cmd, shift, capslock, option, ctrl) {
    if (!drag) return;
    var v = view(), w = toWorld(v, x, y);
    if (!but) {                       // mouse released
        if (drag.kind === "stone" && outside && P.nstones > 1) removeStone(drag.i);
        outside = false; drag = null; fitDirty = true; mgraphics.redraw(); return;
    }
    var st = drag.i !== undefined ? stones[drag.i] : null;
    if (drag.kind === "stone") {
        st.x = clamp(w[0], -1, 1); st.y = clamp(w[1], -1.1, 1.1);
        outside = !inside(st.x, st.y);
        if (!outside) { outlet(0, "s" + (drag.i + 1) + "x", st.x); outlet(0, "s" + (drag.i + 1) + "y", st.y); }
    } else if (drag.kind === "ball") {
        var dx = x - drag.x0, dy = drag.y0 - y;
        if (!drag.axis && Math.sqrt(dx * dx + dy * dy) > 4) drag.axis = Math.abs(dx) > Math.abs(dy) ? "x" : "y";
        if (drag.axis === "y") { st.h = clamp(drag.h0 + dy / 60, 0, 1); outlet(0, "s" + (drag.i + 1) + "h", st.h); }
        if (drag.axis === "x") { st.m = clamp(drag.m0 + dx / 80, 0, 1); outlet(0, "s" + (drag.i + 1) + "m", st.m); }
    } else if (drag.kind === "size") {
        var d = dist(w[0], w[1] * 1, st.x, st.y * 1) ;
        var sigma = d / (4 / 108);
        st.s = clamp(Math.pow(Math.max(0, (sigma - 0.8) / 11), 1 / 1.5), 0, 1);
        outlet(0, "s" + (drag.i + 1) + "s", st.s);
    } else if (drag.kind === "orbit") {
        var nx = clamp(w[0], -0.95, 0.95), ny = clamp(w[1], -0.95, 0.95);
        if (inside(nx, ny) && wallDist(nx, ny) > 0.1) { send("ox", nx); send("oy", ny); live.have = false; }
    } else if (drag.kind === "radius") {
        var cap = orbitCap(P.ox, P.oy), r = dist(w[0], w[1], P.ox, P.oy);
        send("osize", clamp((r - 0.04) / Math.max(0.001, cap - 0.04), 0, 1)); live.have = false;
    } else if (drag.kind === "curl" && P.cmode == 1) {
        var len = Math.sqrt(w[0] * w[0] + w[1] * w[1]);
        send("cdir", Math.atan2(w[1], w[0]));
        send("current", clamp((len - 0.12) / 0.68, 0, 1));
    } else if (drag.kind === "curl") {
        var a = Math.atan2(w[1], w[0]) + Math.PI / 2; if (a > Math.PI) a -= 2 * Math.PI;
        send("current", clamp(a / (Math.PI * 0.9), -1, 1));
    }
    mgraphics.redraw();
}

function ondblclick(x, y, but, cmd, shift, capslock, option, ctrl) {
    var w = toWorld(view(), x, y);
    if (!inside(w[0], w[1]) || P.nstones >= MAXST) return;
    var i = P.nstones;
    stones[i] = { x: w[0], y: w[1], h: 0.5, s: 0.3, m: 0.5 };
    sel = i;
    sendStone(i);
    send("nstones", i + 1);
    mgraphics.redraw();
}

function removeStone(i) {
    for (var k = i; k < P.nstones - 1; k++) { stones[k] = stones[k + 1]; sendStone(k); }
    stones[P.nstones - 1] = { x: -0.3, y: -0.4, h: 0.4, s: 0.3, m: 0.5 };
    send("nstones", P.nstones - 1);
    sel = -1;
}

// ---------------- messages ----------------
function setParam(name, val, forward) {
    if (name.length === 3 && name.charAt(0) === "s" && "1234".indexOf(name.charAt(1)) >= 0) {
        var i = parseInt(name.charAt(1), 10) - 1, f = name.charAt(2);
        if (F.indexOf(f) >= 0) { stones[i][f] = val; if (f === "x" || f === "y") fitDirty = true; if (forward) outlet(0, name, val); }
        return;
    }
    if (P.hasOwnProperty(name)) {
        P[name] = val;
        if (name === "corners" || name === "walls") rebuildShape();
        if (name === "nstones" || name === "current" || name === "cmode" || name === "cdir") fitDirty = true;
        if (name === "ox" || name === "oy" || name === "osize" || name === "width") live.have = false;
        if (forward) outlet(0, name, val);
    }
}

function anything() {
    var name = messagename, args = arrayfromargs(arguments);
    if (inlet === 1) {
        if (name === "frame") { frameData = args; frameN = Math.round(Math.sqrt(args.length)); mgraphics.redraw(); return; }
        if (name === "orbit") { live.x = args[0]; live.y = args[1]; live.r = args[2]; live.have = !drag; return; }
        if (name === "voices") { voices = args[0]; if (!voices) { frameData = frameData; } return; }
        if (args.length) setParam(name, args[0], true);      // randomized stones from pond~
        mgraphics.redraw();
        return;
    }
    if (args.length) setParam(name, args[0], false);
    mgraphics.redraw();
}

function bang() { mgraphics.redraw(); }
function onresize() { mgraphics.redraw(); }
rebuildShape();
