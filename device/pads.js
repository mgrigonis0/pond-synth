// pads.js — Shape, Medium and Material XY pads, stacked (jsui, Max 8 / ES5).
//   Shape:    x = corners 3..12 (whole numbers), y = walls (top bulging, bottom bent in)
//   Medium:   x = viscosity (water .. near solid), y = reflect (top) .. absorb (bottom)
//   Material: x = stiffness (water .. plate), y = grain (top grained like wood, bottom even)
// inlet 0: parameter bus "<name> <value>" (view only). outlet 0: "<name> <value>".

inlets = 1;
outlets = 1;
mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

var P = { corners: 5, walls: 0.2, visc: 0.25, refl: 1, stiff: 0, grain: 0 };
var active = -1;

// section colours (shared with the device: shape = teal, medium = amber, material = violet)
var COL = [[0.33, 0.78, 0.81], [0.89, 0.67, 0.31], [0.68, 0.58, 0.92]];
var NAMES = ["SHAPE", "MEDIUM", "MATERIAL"];
var HEAD = 11;          // label row height

function layout() {
    var sz = mgraphics.size, w = sz[0], h = sz[1];
    var cell = Math.floor(h / 3);
    var pads = [];
    for (var i = 0; i < 3; i++) pads.push({ x: 1, y: i * cell + HEAD, w: w - 2, h: cell - HEAD - 4 });
    return { w: w, h: h, cell: cell, pads: pads };
}
function clamp(a, lo, hi) { return a < lo ? lo : (a > hi ? hi : a); }
function wallName(w) { return w < -0.5 ? "bent in" : w < -0.15 ? "soft in" : w < 0.15 ? "straight" : w < 0.6 ? "soft out" : "bulging"; }
function viscName(v) { return v < 0.25 ? "water" : v < 0.5 ? "oil" : v < 0.7 ? "syrup" : v < 0.9 ? "jelly" : "solid"; }
function stiffName(s) { return s < 0.2 ? "water" : s < 0.45 ? "skin" : s < 0.75 ? "stiff" : "plate"; }

function txt(s, x, y, size, c, a) {
    mgraphics.set_source_rgba(c[0], c[1], c[2], a === undefined ? 1 : a);
    mgraphics.set_font_size(size);
    mgraphics.move_to(x, y); mgraphics.show_text(s);
}
function txtRight(s, xr, y, size, c, a) {
    mgraphics.set_font_size(size);
    var m = mgraphics.text_measure(s);
    txt(s, xr - m[0], y, size, c, a);
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
        for (var k = 1; k <= 10; k++) {
            var t = k / 10, u = 1 - t;
            mgraphics.line_to(u * u * p0x + 2 * u * t * qx + t * t * p1x, u * u * p0y + 2 * u * t * qy + t * t * p1y);
        }
    }
    mgraphics.close_path();
}

function puck(x, y, c) {
    mgraphics.set_source_rgba(c[0], c[1], c[2], 1);
    mgraphics.ellipse(x - 3.5, y - 3.5, 7, 7); mgraphics.fill();
    mgraphics.set_source_rgba(0.09, 0.1, 0.11, 1); mgraphics.set_line_width(1);
    mgraphics.ellipse(x - 3.5, y - 3.5, 7, 7); mgraphics.stroke();
}

function padFrame(p, c, fill) {
    mgraphics.set_source_rgba(fill[0], fill[1], fill[2], 1);
    mgraphics.rectangle(p.x, p.y, p.w, p.h); mgraphics.fill();
    mgraphics.set_source_rgba(c[0], c[1], c[2], 0.35); mgraphics.set_line_width(1);
    mgraphics.rectangle(p.x + 0.5, p.y + 0.5, p.w - 1, p.h - 1); mgraphics.stroke();
}

// value -> position inside a pad
function px(p, fx) { return p.x + 4 + fx * (p.w - 8); }
function py(p, fy) { return p.y + 4 + fy * (p.h - 8); }

function paint() {
    var L = layout(), i, dim = [0.62, 0.64, 0.66], val = [0.86, 0.87, 0.88];
    mgraphics.select_font_face("Arial");
    mgraphics.set_source_rgba(0.13, 0.14, 0.15, 1);
    mgraphics.rectangle(0, 0, L.w, L.h); mgraphics.fill();

    var values = [
        Math.round(P.corners) + " · " + wallName(P.walls),
        viscName(P.visc) + " · " + Math.round(P.refl * 100) + "%",
        stiffName(P.stiff) + " · " + (P.grain < 0.05 ? "even" : "grain " + Math.round(P.grain * 100))
    ];
    for (i = 0; i < 3; i++) {
        var p = L.pads[i], c = COL[i];
        txt(NAMES[i], p.x, p.y - 3, 7.5, c);
        txtRight(values[i], p.x + p.w, p.y - 3, 7.5, val);
        var fill = i === 1 ? [(31 + 27 * P.visc) / 255, (40 - 6 * P.visc) / 255, (46 - 20 * P.visc) / 255]
                 : [0.1, 0.11, 0.12];
        padFrame(p, c, fill);
    }

    // Shape: corner ticks, outline preview, puck
    var s = L.pads[0];
    mgraphics.set_source_rgba(COL[0][0], COL[0][1], COL[0][2], 0.25);
    for (var k = 3; k <= 12; k++) { var tx = px(s, (k - 3) / 9); mgraphics.rectangle(tx - 0.5, s.y + s.h - 3, 1, 2); mgraphics.fill(); }
    var R = (s.h - 8) * 0.42;
    mgraphics.set_source_rgba(COL[0][0], COL[0][1], COL[0][2], 0.18);
    shapeOutline(s.x + s.w / 2, s.y + s.h / 2 + 0.5, R); mgraphics.fill();
    mgraphics.set_source_rgba(COL[0][0], COL[0][1], COL[0][2], 0.75); mgraphics.set_line_width(1);
    shapeOutline(s.x + s.w / 2, s.y + s.h / 2 + 0.5, R); mgraphics.stroke();
    puck(px(s, (Math.round(P.corners) - 3) / 9), py(s, (1 - P.walls) / 2), COL[0]);

    // Medium
    var m = L.pads[1];
    txtRight("reflect", m.x + m.w - 3, m.y + 9, 7, dim, 0.55);
    txtRight("absorb", m.x + m.w - 3, m.y + m.h - 3, 7, dim, 0.55);
    puck(px(m, P.visc), py(m, 1 - P.refl), COL[1]);

    // Material: faint grain lines get denser with grain, plate sheen to the right
    var t = L.pads[2];
    mgraphics.set_source_rgba(COL[2][0], COL[2][1], COL[2][2], 0.06 + 0.12 * P.grain);
    for (var gy = t.y + 4; gy < t.y + t.h - 2; gy += 4) { mgraphics.rectangle(t.x + 2, gy, t.w - 4, 0.6); mgraphics.fill(); }
    txtRight("grain", t.x + t.w - 3, t.y + 9, 7, dim, 0.55);
    txtRight("even", t.x + t.w - 3, t.y + t.h - 3, 7, dim, 0.55);
    puck(px(t, P.stiff), py(t, 1 - P.grain), COL[2]);
}

function apply(x, y) {
    var L = layout();
    if (active < 0) return;
    var p = L.pads[active];
    var fx = clamp((x - p.x - 4) / (p.w - 8), 0, 1), fy = clamp((y - p.y - 4) / (p.h - 8), 0, 1);
    if (active === 0) {
        var c = 3 + Math.round(fx * 9);
        if (c !== P.corners) { P.corners = c; outlet(0, "corners", c); }
        P.walls = 1 - 2 * fy; outlet(0, "walls", P.walls);
    } else if (active === 1) {
        P.visc = fx; P.refl = 1 - fy;
        outlet(0, "visc", P.visc); outlet(0, "refl", P.refl);
    } else {
        P.stiff = fx; P.grain = 1 - fy;
        outlet(0, "stiff", P.stiff); outlet(0, "grain", P.grain);
    }
    mgraphics.redraw();
}

function onclick(x, y, but, cmd, shift, capslock, option, ctrl) {
    var L = layout();
    active = -1;
    for (var i = 0; i < 3; i++) {
        var p = L.pads[i];
        if (x >= p.x - 2 && x <= p.x + p.w + 2 && y >= p.y - 2 && y <= p.y + p.h + 2) active = i;
    }
    apply(x, y);
}
function ondrag(x, y, but, cmd, shift, capslock, option, ctrl) {
    if (!but) { active = -1; return; }
    apply(x, y);
}

function anything() {
    var args = arrayfromargs(arguments);
    if (P.hasOwnProperty(messagename) && args.length) {
        P[messagename] = messagename === "corners" ? Math.round(args[0]) : args[0];
        mgraphics.redraw();
    }
}
function bang() { mgraphics.redraw(); }
function onresize() { mgraphics.redraw(); }
