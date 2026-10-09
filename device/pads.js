// pads.js — Shape and Medium XY pads for the Pond synth device (jsui, Max 8 / ES5).
//   Shape pad:  x = corners 3..12, y = walls (top bulging, bottom concave)
//   Medium pad: x = viscosity (water .. syrup), y = reflect (top) .. absorb (bottom)
// inlet 0: parameter bus "<name> <value>" (view only). outlet 0: "<name> <value>".

inlets = 1;
outlets = 1;
mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

var P = { corners: 5, walls: 0.2, visc: 0.25, refl: 0.8 };
var active = -1;

function layout() {
    var sz = mgraphics.size, w = sz[0], h = sz[1];
    var pad = Math.min((w - 12) / 2, h - 30);
    return { w: w, h: h, pad: pad, x0: 4, x1: 8 + pad, y: 14 };
}
function clamp(a, lo, hi) { return a < lo ? lo : (a > hi ? hi : a); }
function wallName(w) { return w < -0.5 ? "concave" : w < -0.15 ? "bent in" : w < 0.15 ? "straight" : w < 0.6 ? "soft bulge" : "bulging"; }
function viscName(v) { return v < 0.25 ? "water" : v < 0.5 ? "oil" : v < 0.7 ? "syrup" : v < 0.9 ? "jelly" : "near solid"; }

function text(s, x, y, size, r, g, b) {
    mgraphics.set_source_rgba(r, g, b, 1);
    mgraphics.set_font_size(size);
    mgraphics.move_to(x, y); mgraphics.show_text(s);
}

function shapeOutline(cx, cy, R) {
    var m = Math.round(P.corners), walls = P.walls;
    for (var i = 0; i < m; i++) {
        var a0 = -Math.PI / 2 + i * 2 * Math.PI / m, a1 = a0 + 2 * Math.PI / m, am = (a0 + a1) / 2;
        var ap = R * Math.cos(Math.PI / m), sag = R - ap;
        var off = walls >= 0 ? ap + walls * 2 * sag : ap + walls * ap * 0.85;
        var p0x = cx + R * Math.cos(a0), p0y = cy + R * Math.sin(a0), p1x = cx + R * Math.cos(a1), p1y = cy + R * Math.sin(a1);
        var qx = cx + off * Math.cos(am), qy = cy + off * Math.sin(am);
        if (i === 0) mgraphics.move_to(p0x, p0y);
        for (var k = 1; k <= 12; k++) {
            var t = k / 12, u = 1 - t;
            mgraphics.line_to(u * u * p0x + 2 * u * t * qx + t * t * p1x, u * u * p0y + 2 * u * t * qy + t * t * p1y);
        }
    }
    mgraphics.close_path();
}

function puck(x, y) {
    mgraphics.set_source_rgba(0.9, 0.64, 0.24, 1);
    mgraphics.ellipse(x - 4.5, y - 4.5, 9, 9); mgraphics.fill();
    mgraphics.set_source_rgba(0.11, 0.12, 0.13, 1); mgraphics.set_line_width(1.2);
    mgraphics.ellipse(x - 4.5, y - 4.5, 9, 9); mgraphics.stroke();
}

function paint() {
    var L = layout(), p = L.pad;
    mgraphics.select_font_face("Arial");
    mgraphics.set_source_rgba(0.15, 0.16, 0.18, 1);
    mgraphics.rectangle(0, 0, L.w, L.h); mgraphics.fill();

    // Shape pad
    text("Shape", L.x0, 10, 9, 0.6, 0.63, 0.65);
    text(Math.round(P.corners * 10) / 10 + " · " + wallName(P.walls), L.x0 + 36, 10, 9, 0.84, 0.85, 0.86);
    mgraphics.set_source_rgba(0.12, 0.13, 0.15, 1); mgraphics.rectangle(L.x0, L.y, p, p); mgraphics.fill();
    mgraphics.set_source_rgba(0.18, 0.56, 0.64, 0.3);
    shapeOutline(L.x0 + p / 2, L.y + p / 2 + 1, p * 0.31); mgraphics.fill();
    mgraphics.set_source_rgba(0.5, 0.76, 0.82, 1); mgraphics.set_line_width(1);
    shapeOutline(L.x0 + p / 2, L.y + p / 2 + 1, p * 0.31); mgraphics.stroke();
    puck(L.x0 + (P.corners - 3) / 9 * p, L.y + (1 - P.walls) / 2 * p);
    text("3", L.x0, L.y + p + 10, 8, 0.6, 0.63, 0.65);
    text("corners", L.x0 + p / 2 - 14, L.y + p + 10, 8, 0.6, 0.63, 0.65);
    text("12", L.x0 + p - 9, L.y + p + 10, 8, 0.6, 0.63, 0.65);

    // Medium pad
    var v = P.visc;
    text("Medium", L.x1, 10, 9, 0.6, 0.63, 0.65);
    text(viscName(v) + " · " + Math.round(P.refl * 100) + "%", L.x1 + 40, 10, 9, 0.84, 0.85, 0.86);
    mgraphics.set_source_rgba((31 + 27 * v) / 255, (48 - 6 * v) / 255, (56 - 28 * v) / 255, 1);
    mgraphics.rectangle(L.x1, L.y, p, p); mgraphics.fill();
    text("reflect", L.x1 + 3, L.y + 10, 8, 0.6, 0.63, 0.65);
    text("absorb", L.x1 + 3, L.y + p - 4, 8, 0.6, 0.63, 0.65);
    puck(L.x1 + v * p, L.y + (1 - P.refl) * p);
    text("water", L.x1, L.y + p + 10, 8, 0.6, 0.63, 0.65);
    text("solid", L.x1 + p - 22, L.y + p + 10, 8, 0.6, 0.63, 0.65);
}

function apply(x, y) {
    var L = layout(), p = L.pad;
    if (active === 0) {
        var fx = clamp((x - L.x0) / p, 0, 1), fy = clamp((y - L.y) / p, 0, 1);
        P.corners = 3 + fx * 9; P.walls = 1 - 2 * fy;
        outlet(0, "corners", P.corners); outlet(0, "walls", P.walls);
    } else if (active === 1) {
        var gx = clamp((x - L.x1) / p, 0, 1), gy = clamp((y - L.y) / p, 0, 1);
        P.visc = gx; P.refl = 1 - gy;
        outlet(0, "visc", P.visc); outlet(0, "refl", P.refl);
    }
    mgraphics.redraw();
}

function onclick(x, y, but, cmd, shift, capslock, option, ctrl) {
    var L = layout();
    active = (x >= L.x0 && x <= L.x0 + L.pad) ? 0 : (x >= L.x1 && x <= L.x1 + L.pad) ? 1 : -1;
    if (y < L.y - 2 || y > L.y + L.pad + 2) active = -1;
    apply(x, y);
}
function ondrag(x, y, but, cmd, shift, capslock, option, ctrl) {
    if (!but) { active = -1; return; }
    apply(x, y);
}

function anything() {
    var args = arrayfromargs(arguments);
    if (P.hasOwnProperty(messagename) && args.length) { P[messagename] = args[0]; mgraphics.redraw(); }
}
function bang() { mgraphics.redraw(); }
function onresize() { mgraphics.redraw(); }
