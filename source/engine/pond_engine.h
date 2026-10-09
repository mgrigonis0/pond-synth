// Pond synth engine — pure C++17, no Max dependencies.
//
// Each voice owns its own copy of a 2D pond (leapfrog wave equation with
// viscosity, damping, soft reflective walls and an optional whirlpool current).
// Stones excite it; two "orbits" (left/right ears) read the water height along
// a circle at the note's lap rate. Reading is 4x oversampled and decimated.
//
// Threads:
//   - "main" thread: set*() parameter calls, rebuild() (shape + start snapshot),
//                    noteOn/noteOff (pushed into a lock-free queue), readDisplay().
//   - audio thread:  process().
#pragma once

#include <algorithm>
#include <array>
#include <atomic>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <mutex>
#include <vector>
#if defined(__SSE__) || defined(_M_X64)
#include <xmmintrin.h>
#endif

namespace pond {

constexpr int G = 108;                 // pond grid (cells per side)
constexpr int NCELLS = G * G;
constexpr double STEPS_PER_POND_SEC = 1500.0;  // water clock at speed 1 (C3)
constexpr float C2 = 0.2f;             // wave speed^2 (stable < 0.5)
constexpr int MAX_STONES = 4;
constexpr float FLOW_MAX = 0.2f;       // flow current at full strength: cells per pond step (~2.8 pond widths per pond-second)
constexpr float MAX_POND_RATE = 4.f;   // cap on Speed x key tracking (water steps = CPU)
constexpr double POND_LOSS = 0.5;      // amplitude kept per pond-second with hard walls (-60 dB in ~10 pond-s)
constexpr float SPONGE_CELLS = 20.f;   // width of the absorbing band along the walls
constexpr float SPONGE_MAX = 0.35f;    // friction at the wall when Reflect = 0
constexpr int MAX_VOICES = 8;
constexpr int OS = 4;                  // oversampling factor for the orbit read
constexpr int FIR_TAPS = 64;
constexpr int ANG = 720;               // boundary samples (polar table)
constexpr int DISP = 36;               // display grid (G / 3)
constexpr double kPi = 3.14159265358979323846;

struct Stone {
    float x = 0.f, y = 0.f;   // landing spot, world coords -1..1
    float h = 0.5f;           // drop height 0..1
    float size = 0.3f;        // 0..1  (tiny = restless, huge = calm)
    float mass = 0.5f;        // 0..1
};

struct Params {
    // pond
    std::atomic<float> corners{5.f}, walls{0.2f}, visc{0.25f}, refl{1.f}, current{0.25f};
    std::atomic<int> cmode{0};            // 0 = whirlpool, 1 = flow (one direction to another)
    std::atomic<float> cdir{0.f};         // flow direction, radians (0 = towards +x)
    // time
    std::atomic<float> speed{1.f}, start{0.f};
    std::atomic<int> keytrack{1}, freeze{0};
    // orbit
    std::atomic<float> ox{0.12f}, oy{-0.1f}, osize{0.4f};
    std::atomic<float> wander{0.f}, width{0.5f}, detune{6.f}, drift{0.2f};
    // playing
    std::atomic<float> attack{8.f}, release{400.f}, velamt{0.7f}, volume{-6.f};
    std::atomic<float> clarity{0.f};      // 0 = continuous (alive), 1 = water held per wave cycle (clean)
};

// --------------------------------------------------------------------------
// Shape: soft mask, per-cell damping (sponge near walls) and the polar boundary.
struct Shape {
    std::vector<float> mask = std::vector<float>(NCELLS, 0.f);
    std::vector<float> damp = std::vector<float>(NCELLS, 1.f);
    std::vector<float> sponge = std::vector<float>(NCELLS, 0.f);   // wall friction on motion (absorbing walls)
    std::array<float, ANG> R{};      // boundary radius per angle (world units)
    float viscCoef = 0.008f;
};

inline float worldToGrid(float w) { return (w + 1.f) * 0.5f * G - 0.5f; }
inline float gridToWorld(float g) { return (g + 0.5f) / G * 2.f - 1.f; }

// Boundary radius table for an integer corner count (quadratic-Bezier sides,
// walls -1 concave .. 0 straight .. 1 bulging), radius scale 0.92.
inline void boundaryForCorners(int m, float walls, std::array<float, ANG>& out) {
    const float Rr = 0.92f;
    std::array<float, ANG> acc{};
    std::array<int, ANG> hit{};
    const int per = 256;
    for (int i = 0; i < m; i++) {
        double a0 = -kPi / 2 + i * 2 * kPi / m, a1 = a0 + 2 * kPi / m, am = (a0 + a1) / 2;
        double ap = Rr * std::cos(kPi / m), sag = Rr - ap;
        double off = walls >= 0 ? ap + walls * 2 * sag : ap + walls * ap * 0.85;
        double p0x = Rr * std::cos(a0), p0y = Rr * std::sin(a0);
        double p1x = Rr * std::cos(a1), p1y = Rr * std::sin(a1);
        double qx = off * std::cos(am), qy = off * std::sin(am);
        for (int k = 0; k < per; k++) {
            double t = (double)k / per, u = 1 - t;
            double x = u * u * p0x + 2 * u * t * qx + t * t * p1x;
            double y = u * u * p0y + 2 * u * t * qy + t * t * p1y;
            double th = std::atan2(y, x);
            if (th < 0) th += 2 * kPi;
            int bin = std::min(ANG - 1, (int)(th / (2 * kPi) * ANG));
            float r = (float)std::sqrt(x * x + y * y);
            if (!hit[bin] || r > acc[bin]) acc[bin] = r;
            hit[bin] = 1;
        }
    }
    // fill any empty bins by interpolating neighbours
    for (int b = 0; b < ANG; b++) {
        if (hit[b]) { out[b] = acc[b]; continue; }
        int l = b, r = b;
        while (!hit[(l + ANG) % ANG]) l--;
        while (!hit[r % ANG]) r++;
        float fl = acc[(l + ANG) % ANG], fr = acc[r % ANG];
        out[b] = fl + (fr - fl) * (float)(b - l) / (float)(r - l);
    }
}

inline void buildShape(float corners, float walls, float refl, float visc, Shape& s) {
    corners = std::clamp(corners, 3.f, 12.f);
    walls = std::clamp(walls, -1.f, 1.f);
    int m0 = (int)std::floor(corners), m1 = std::min(12, m0 + 1);
    float fr = corners - m0;
    std::array<float, ANG> A{}, B{};
    boundaryForCorners(m0, walls, A);
    boundaryForCorners(m1, walls, B);
    for (int b = 0; b < ANG; b++) s.R[b] = A[b] + (B[b] - A[b]) * fr;

    const float d0 = (float)std::pow(POND_LOSS, 1.0 / STEPS_PER_POND_SEC);
    const float cell = 2.f / G;
    // absorbing walls: friction on the water's motion in a wide band along the wall.
    // Reflect 1 = no friction (hard wall); 0 = strong friction that soaks waves up.
    const float absorb = std::pow(1.f - std::clamp(refl, 0.f, 1.f), 2.5f) * SPONGE_MAX;
    for (int gy = 0; gy < G; gy++) {
        for (int gx = 0; gx < G; gx++) {
            int i = gy * G + gx;
            float wx = gridToWorld((float)gx), wy = gridToWorld((float)gy);
            float r = std::sqrt(wx * wx + wy * wy);
            double th = std::atan2(wy, wx);
            if (th < 0) th += 2 * kPi;
            float fb = (float)(th / (2 * kPi) * ANG);
            int b0 = (int)fb % ANG, b1 = (b0 + 1) % ANG;
            float t = fb - std::floor(fb);
            float Rb = s.R[b0] + (s.R[b1] - s.R[b0]) * t;
            float edgeCells = (Rb - r) / cell;                      // distance inside the wall, in cells
            float m = std::clamp(edgeCells / 1.5f + 0.5f, 0.f, 1.f); // soft edge ~1.5 cells
            bool border = gx == 0 || gy == 0 || gx == G - 1 || gy == G - 1;
            s.mask[i] = border ? 0.f : m;
            float band = std::clamp(1.f - edgeCells / SPONGE_CELLS, 0.f, 1.f);
            s.damp[i] = d0;
            s.sponge[i] = absorb * band * band;
        }
    }
    // Viscosity: water (0.002) .. 0.13 (the leapfrog scheme goes unstable above 0.15),
    // exponential so the whole knob is usable, plus a drag on all motion over the top
    // third so the far end behaves like a near-solid: ripples barely spread and die fast.
    const float vv = std::clamp(visc, 0.f, 1.f);
    s.viscCoef = 0.002f * std::pow(65.f, vv);
    // Stability of the scheme needs 16*visc + 2*friction < 2.4 (fastest grid mode);
    // keep a margin so near-solid + absorbing walls can never run away.
    s.viscCoef = std::min(s.viscCoef, (2.0f - 2.f * absorb) / 16.f);
    float t = std::clamp((vv - 0.6f) / 0.4f, 0.f, 1.f); t = t * t * (3 - 2 * t);
    const float drag = (float)std::pow(1.0 - 0.995 * t, 1.0 / STEPS_PER_POND_SEC);   // up to 99.5% loss per pond-second
    for (int i = 0; i < NCELLS; i++) s.damp[i] *= drag;
}

// Distance from a world point to the nearest boundary sample.
inline float wallDistance(const std::array<float, ANG>& R, float x, float y) {
    float best = 9.f;
    for (int b = 0; b < ANG; b += 2) {
        double th = (b + 0.5) / ANG * 2 * kPi;
        float bx = R[b] * (float)std::cos(th), by = R[b] * (float)std::sin(th);
        best = std::min(best, std::hypot(bx - x, by - y));
    }
    return best;
}
inline bool insidePond(const std::array<float, ANG>& R, float x, float y) {
    double th = std::atan2(y, x);
    if (th < 0) th += 2 * kPi;
    int b = std::min(ANG - 1, (int)(th / (2 * kPi) * ANG));
    return std::sqrt(x * x + y * y) < R[b];
}


// Whirlpool rotation as a precomputed gather (semi-Lagrangian, bilinear).
constexpr int ADVECT_EVERY = 8;
struct AdvectTable {
    // mode 0 = whirlpool (omega: per-step angle), 1 = flow (vx, vy: cells per step)
    int mode = 0; float omega = 1e9f, vx = 0.f, vy = 0.f;
    std::vector<int> idx = std::vector<int>(NCELLS, -1);
    std::vector<float> fx = std::vector<float>(NCELLS, 0.f), fy = std::vector<float>(NCELLS, 0.f);
    bool active() const { return mode == 0 ? std::fabs(omega) > 1e-7f : (std::fabs(vx) + std::fabs(vy)) > 1e-6f; }
    bool same(int m, float a, float b, float c) const { return m == mode && a == omega && b == vx && c == vy; }
    // where a point sits after `k` (fractional) steps of not-yet-applied motion
    void pending(float k, float gc, float& x, float& y) const {
        if (mode == 0) {
            float th = k * omega, c = std::cos(th), s = std::sin(th), px = x - gc, py = y - gc;
            x = gc + c * px + s * py; y = gc - s * px + c * py;
        } else { x -= k * vx; y -= k * vy; }
    }
    void build(int m, float om, float fvx, float fvy) {
        mode = m; omega = om; vx = fvx; vy = fvy;
        const float a = om * ADVECT_EVERY, ca = std::cos(a), sa = std::sin(a), c = (G - 1) * 0.5f;
        for (int y = 0; y < G; y++)
            for (int x = 0; x < G; x++) {
                int i = y * G + x; float sx, sy;
                if (m == 0) { float dx = x - c, dy = y - c; sx = c + ca * dx + sa * dy; sy = c - sa * dx + ca * dy; }
                else { sx = x - fvx * ADVECT_EVERY; sy = y - fvy * ADVECT_EVERY; }   // flow: water arrives from upstream
                int x0 = (int)std::floor(sx), y0 = (int)std::floor(sy);
                if (x < 1 || y < 1 || x >= G - 1 || y >= G - 1 || x0 < 0 || y0 < 0 || x0 >= G - 1 || y0 >= G - 1) { idx[i] = -1; continue; }
                idx[i] = y0 * G + x0; fx[i] = sx - x0; fy[i] = sy - y0;
            }
    }
};

// --------------------------------------------------------------------------
// One pond's water state + the simulation step (shared by voices and baking).
struct Water {
    std::vector<float> u = std::vector<float>(NCELLS, 0.f);   // current height
    std::vector<float> p = std::vector<float>(NCELLS, 0.f);   // previous height
    std::vector<float> lp = std::vector<float>(NCELLS, 0.f);  // previous laplacian (viscosity)
    std::vector<float> tmp = std::vector<float>(NCELLS, 0.f);

    void clear() {
        std::fill(u.begin(), u.end(), 0.f); std::fill(p.begin(), p.end(), 0.f);
        std::fill(lp.begin(), lp.end(), 0.f); npend = 0;
    }
    void copyFrom(const Water& o) {
        u = o.u; p = o.p; lp = o.lp; npend = o.npend;
        for (int i = 0; i < o.npend; i++) pend[i] = o.pend[i];
        advectCount = o.advectCount;
    }

    int advectCount = 0;

    // Stones land over DROP_STEPS pond steps (raised-cosine), not in one step: an
    // instant height jump under the orbit is heard as a click.
    static constexpr int DROP_STEPS = 12;
    struct Pending { Stone s; int k = 0; };
    Pending pend[8]; int npend = 0;
    void startDrop(const Stone& st) { if (npend < 8) { pend[npend].s = st; pend[npend].k = 0; npend++; } }
    void applyPending(const float* mask) {
        static const auto W = [] {
            std::array<float, DROP_STEPS> w{}; double sum = 0;
            for (int k = 0; k < DROP_STEPS; k++) { w[k] = (float)(1 - std::cos(2 * kPi * (k + 0.5) / DROP_STEPS)); sum += w[k]; }
            for (auto& x : w) x = (float)(x / sum);
            return w;
        }();
        for (int i = 0; i < npend;) {
            drop(pend[i].s, mask, W[pend[i].k]);
            if (++pend[i].k >= DROP_STEPS) pend[i] = pend[--npend]; else i++;
        }
    }

    // adv: precomputed whirlpool rotation (applied every ADVECT_EVERY steps), or null.
    void step(const float* mask, const float* damp, const float* sponge, float visc, const struct AdvectTable* adv);
    void advect(std::vector<float>& f, const AdvectTable& t);

    void drop(const Stone& s, const float* mask, float scale = 1.f) {
        // physics: fall time from height, strength = mass * impact speed
        float H = 0.2f + s.h * 2.8f;
        const float g = 4.2f;                                  // scaled gravity: 3 m lands at ~1.2 s
        float v = std::sqrt(2.f * g * H);
        float E = (0.2f + s.mass * 2.8f) * v;
        float sigma = 0.8f + std::pow(std::clamp(s.size, 0.f, 1.f), 1.5f) * 11.f;   // cells
        float amp = 0.6f * E * std::sqrt(1.7f / sigma) * scale;
        float cx = worldToGrid(s.x), cy = worldToGrid(s.y);
        int rad = (int)std::ceil(sigma * 3.5f);
        int x0 = std::max(1, (int)cx - rad), x1 = std::min(G - 2, (int)cx + rad);
        int y0 = std::max(1, (int)cy - rad), y1 = std::min(G - 2, (int)cy + rad);
        float inv = 1.f / (2.f * sigma * sigma);
        for (int y = y0; y <= y1; y++)
            for (int x = x0; x <= x1; x++) {
                float d2 = (x - cx) * (x - cx) + (y - cy) * (y - cy);
                u[y * G + x] += amp * std::exp(-d2 * inv) * mask[y * G + x];
            }
    }
};

inline void Water::step(const float* mask, const float* damp, const float* sponge, float visc, const AdvectTable* adv) {
    if (npend) applyPending(mask);
    float* U = u.data(); float* P = p.data(); float* L = lp.data();
    for (int y = 1; y < G - 1; y++) {
        int r = y * G;
        for (int x = 1; x < G - 1; x++) {
            int i = r + x;
            float l = U[i - 1] + U[i + 1] + U[i - G] + U[i + G] - 4.f * U[i];
            float n = (2.f * U[i] - P[i] + C2 * l + visc * (l - L[i]) - sponge[i] * (U[i] - P[i])) * damp[i] * mask[i];
            L[i] = l;
            P[i] = n;            // P now holds the NEW field
        }
    }
    u.swap(p);                   // u = new, p = previous
    if (adv && adv->active() && ++advectCount >= ADVECT_EVERY) {
        advectCount = 0;
        advect(u, *adv); advect(p, *adv);
        for (int i = 0; i < NCELLS; i++) { u[i] *= mask[i]; p[i] *= mask[i]; }
    }
}

inline void Water::advect(std::vector<float>& f, const AdvectTable& t) {
    const float* F = f.data(); float* T = tmp.data();
    const int* I = t.idx.data(); const float* FX = t.fx.data(); const float* FY = t.fy.data();
    for (int i = 0; i < NCELLS; i++) {
        int j = I[i];
        if (j < 0) { T[i] = 0.f; continue; }
        const float* a = F + j; float ax = FX[i], ay = FY[i];
        T[i] = (a[0] + (a[1] - a[0]) * ax) * (1 - ay) + (a[G] + (a[G + 1] - a[G]) * ax) * ay;
    }
    f.swap(tmp);
}

inline float fallTime(const Stone& s) {
    float H = 0.2f + s.h * 2.8f;
    return std::sqrt(2.f * H / 4.2f);
}
// Landing times are measured from 10 ms before the FIRST stone hits, so a note
// is never silent while stones are still falling; heights set the delays between them.
inline void landingTimes(const Stone* st, int n, float* out) {
    float first = 1e9f;
    for (int i = 0; i < n; i++) first = std::min(first, fallTime(st[i]));
    for (int i = 0; i < n; i++) out[i] = fallTime(st[i]) - first + 0.01f;
}

inline float bilinear(const float* F, float gx, float gy) {
    gx = std::clamp(gx, 0.f, G - 1.001f); gy = std::clamp(gy, 0.f, G - 1.001f);
    int x0 = (int)gx, y0 = (int)gy; float fx = gx - x0, fy = gy - y0;
    const float* a = F + y0 * G + x0;
    return (a[0] * (1 - fx) + a[1] * fx) * (1 - fy) + (a[G] * (1 - fx) + a[G + 1] * fx) * fy;
}

// sin/cos of a phase in 0..1 via a lookup table.
struct SinTable {
    static constexpr int N = 4096;
    float t[N + 1];
    SinTable() { for (int i = 0; i <= N; i++) t[i] = (float)std::sin(2 * kPi * i / N); }
};
inline const SinTable& sinTable() { static SinTable st; return st; }
inline void sincos01(float ph, float& s, float& c) {
    const SinTable& T = sinTable();
    float x = ph * SinTable::N; int i = (int)x; float f = x - i; i &= SinTable::N - 1;
    s = T.t[i] + (T.t[i + 1] - T.t[i]) * f;
    float xc = x + SinTable::N / 4; int j = (int)xc; float fc = xc - j; j &= SinTable::N - 1;
    c = T.t[j] + (T.t[j + 1] - T.t[j]) * fc;
}

// Smooth random wobble (for drift and wander), ~rate Hz, output -1..1.
struct Wobble {
    uint32_t seed = 1; float a = 0, b = 0, t = 1;
    float next() { seed = seed * 1664525u + 1013904223u; return ((seed >> 8) / 8388608.f) - 1.f; }
    float tick(float rate, float sr) {
        t += rate / sr;
        if (t >= 1.f) { t -= 1.f; a = b; b = next(); }
        float s = t * t * (3 - 2 * t);
        return a + (b - a) * s;
    }
};

// --------------------------------------------------------------------------
struct Biquad {
    float b0 = 1, b1 = 0, b2 = 0, a1 = 0, a2 = 0, x1 = 0, x2 = 0, y1 = 0, y2 = 0;
    void highpass(double fc, double q, double sr) {
        double w = 2 * kPi * fc / sr, cw = std::cos(w), al = std::sin(w) / (2 * q), a0 = 1 + al;
        b0 = (float)((1 + cw) / 2 / a0); b1 = (float)(-(1 + cw) / a0); b2 = b0;
        a1 = (float)(-2 * cw / a0); a2 = (float)((1 - al) / a0); x1 = x2 = y1 = y2 = 0;
    }
    float run(float x) { float y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2; x2 = x1; x1 = x; y2 = y1; y1 = y; return y; }
};
constexpr double BW4_Q1 = 0.5411961, BW4_Q2 = 1.3065630;   // 4th-order Butterworth sections

struct Voice {
    Water w;
    bool active = false, gate = false;
    int note = -1; float vel = 1.f;
    double pondTime = 0.0;        // pond seconds since the stones were released
    double stepAcc = 0.0;         // fractional pond step
    double phase[2] = {0, 0};     // orbit phase per ear (0..1)
    float env = 0.f;
    uint64_t startedAt = 0;
    bool landed[MAX_STONES] = {};
    float firBuf[2][2 * FIR_TAPS] = {};
    double dph[2] = {0, 0}; float rrf[2] = {1, 1};
    bool stealing = false, pendOff = false; uint8_t pendNote = 0, pendVel = 0;
    // per-ear high-pass just below the note: removes the slosh/thump "boom" under the pitch
    Biquad hp[2][2];               // [stage][ear]: 4th-order Butterworth high-pass under the note
    // Clarity: per-lap snapshots of the waveform along the orbit
    static constexpr int TAB = 128;
    float tabOld[2][TAB + 1] = {}, tabNew[2][TAB + 1] = {};
    bool tabInit = false;
    int lapCount[2] = {0, 0}, holdLaps[2] = {1, 1};
    int firPos = 0;
    Wobble wobP[2], wobR[2];
};

enum class EvType : uint8_t { NoteOn, NoteOff, AllOff };
struct Event { EvType type; uint8_t note; uint8_t vel; };

// Single-producer single-consumer queue (main -> audio).
template <int SIZE>
struct EventQueue {
    Event buf[SIZE];
    std::atomic<int> head{0}, tail{0};
    bool push(const Event& e) {
        int h = head.load(std::memory_order_relaxed), n = (h + 1) % SIZE;
        if (n == tail.load(std::memory_order_acquire)) return false;
        buf[h] = e; head.store(n, std::memory_order_release); return true;
    }
    bool pop(Event& e) {
        int t = tail.load(std::memory_order_relaxed);
        if (t == head.load(std::memory_order_acquire)) return false;
        e = buf[t]; tail.store((t + 1) % SIZE, std::memory_order_release); return true;
    }
};

class Engine {
public:
    Params prm;

    Engine() {
        designFir();
        for (int v = 0; v < MAX_VOICES; v++)
            for (int e = 0; e < 2; e++) { voices[v].wobP[e].seed = 11 + v * 7 + e; voices[v].wobR[e].seed = 101 + v * 13 + e; }
        wanX.seed = 7777; wanY.seed = 9191;
        // default stones (same layout as the UI mock)
        stonesMain[0] = {0.5f, -0.22f, 0.55f, 0.35f, 0.5f};
        stonesMain[1] = {-0.45f, 0.3f, 0.25f, 0.2f, 0.85f};
        stonesMain[2] = {0.12f, 0.55f, 0.8f, 0.55f, 0.3f};
        stonesMain[3] = {-0.3f, -0.4f, 0.4f, 0.3f, 0.5f};
        nStonesMain = 3;
        rebuild();
    }

    // ---- main thread -------------------------------------------------------
    void setStone(int i, const Stone& s) { std::lock_guard<std::mutex> lk(stoneLock); if (i >= 0 && i < MAX_STONES) stonesMain[i] = s; }
    Stone getStone(int i) { std::lock_guard<std::mutex> lk(stoneLock); return stonesMain[std::clamp(i, 0, MAX_STONES - 1)]; }
    void setStoneCount(int n) { std::lock_guard<std::mutex> lk(stoneLock); nStonesMain = std::clamp(n, 1, MAX_STONES); }
    int stoneCount() { std::lock_guard<std::mutex> lk(stoneLock); return nStonesMain; }
    // where the orbit actually is right now (after wander and the wall cap), world units
    std::atomic<float> orbitX{0.f}, orbitY{0.f}, orbitR{0.3f};

    void noteOn(int note, int vel) {
        if (vel <= 0) { noteOff(note); return; }
        queue.push({EvType::NoteOn, (uint8_t)std::clamp(note, 0, 127), (uint8_t)std::clamp(vel, 1, 127)});
    }
    void noteOff(int note) { queue.push({EvType::NoteOff, (uint8_t)std::clamp(note, 0, 127), 0}); }
    void allOff() { queue.push({EvType::AllOff, 0, 0}); }

    // Rebuild the shape and the start-point snapshot. Call after any change to
    // corners/walls/visc/refl/current/start or the stones. Heavy (up to ~30 ms).
    void rebuild() {
        Shape s;
        buildShape(prm.corners.load(), prm.walls.load(), prm.refl.load(), prm.visc.load(), s);
        // bake the pond state at the start point
        Water bake;
        Stone st[MAX_STONES]; int n;
        {
            std::lock_guard<std::mutex> lk(stoneLock);
            n = nStonesMain;
            for (int i = 0; i < MAX_STONES; i++) st[i] = stonesMain[i];
        }
        double start = std::clamp((double)prm.start.load(), 0.0, 8.0);
        long steps = (long)(start * STEPS_PER_POND_SEC);
        AdvectTable adv; { CurrentSpec c = currentSpec(); adv.build(c.mode, c.omega, c.vx, c.vy); }
        bool landed[MAX_STONES] = {};
        float lt[MAX_STONES] = {};
        landingTimes(st, n, lt);
        for (long k = 0; k <= steps; k++) {
            double t = k / STEPS_PER_POND_SEC;
            for (int i = 0; i < n; i++)
                if (!landed[i] && t >= lt[i]) { landed[i] = true; bake.startDrop(st[i]); }
            if (k < steps) bake.step(s.mask.data(), s.damp.data(), s.sponge.data(), s.viscCoef, &adv);
        }
        std::lock_guard<std::mutex> lk(shareLock);
        shared.shape = std::move(s);
        shared.snap.copyFrom(bake);
        shared.snapTime = steps / STEPS_PER_POND_SEC;
        for (int i = 0; i < MAX_STONES; i++) { shared.stones[i] = st[i]; shared.land[i] = lt[i]; }
        shared.nStones = n;
        shared.version++;
    }

    // Display: DISP x DISP heights (latest voice, or the start snapshot when idle).
    // Returns false if nothing new. Values are raw heights.
    bool readDisplay(float* out, int& activeVoices) {
        std::unique_lock<std::mutex> lk(dispLock, std::try_to_lock);
        if (!lk.owns_lock() || !dispFresh) return false;
        std::memcpy(out, disp, sizeof(disp));
        activeVoices = dispActive;
        dispFresh = false;
        return true;
    }

    // ---- audio thread ------------------------------------------------------
    void process(float* outL, float* outR, int n, double sr) {
        denormalsOff();
        curSr = sr;
        pullShared();
        Event e;
        while (queue.pop(e)) handle(e, sr);
        smoothMask(n, sr);

        const float relS = std::max(0.005f, prm.release.load() / 1000.f);
        const float atkS = std::max(0.001f, prm.attack.load() / 1000.f);
        const float relK = std::exp(-1.f / (relS * 0.25f * (float)sr));   // ~-35 dB at the release time
        const float atkInc = 1.f / (atkS * (float)sr);
        const float stealK = std::exp(-1.f / (0.0025f * (float)sr));      // ~15 ms fade to -55 dB (longer than a low note's cycle)
        const float volG = std::pow(10.f, prm.volume.load() / 20.f);
        const float velAmt = std::clamp(prm.velamt.load(), 0.f, 1.f);
        const bool frozen = prm.freeze.load() != 0;
        if (frozen && !wasFrozen) captureFrozen();
        wasFrozen = frozen;
        frozenNow = frozen;
        const bool keytrack = prm.keytrack.load() != 0;
        const float speedK = std::clamp(prm.speed.load(), 0.f, 4.f);
        { CurrentSpec c = currentSpec(); if (!advTable.same(c.mode, c.omega, c.vx, c.vy)) advTable.build(c.mode, c.omega, c.vx, c.vy); }
        const float width = std::clamp(prm.width.load(), 0.f, 1.f) * 0.08f;
        const float detune = std::clamp(prm.detune.load(), 0.f, 50.f);
        const float drift = std::clamp(prm.drift.load(), 0.f, 1.f);
        const float wander = std::clamp(prm.wander.load(), 0.f, 1.f);
        const float clarity = std::clamp(prm.clarity.load(), 0.f, 1.f);

        // orbit centre with wander, kept inside the pond
        float ox = std::clamp(prm.ox.load(), -0.95f, 0.95f), oy = std::clamp(prm.oy.load(), -0.95f, 0.95f);
        for (int k = 0; k < n; k += 32) { wx = wanX.tick(0.12f, (float)sr / 32.f); wy = wanY.tick(0.1f, (float)sr / 32.f); }
        float cx = ox + wander * 0.35f * wx, cy = oy + wander * 0.35f * wy;
        if (!insidePond(local.shape.R, cx, cy)) { cx = ox; cy = oy; }
        if (!insidePond(local.shape.R, cx, cy)) { cx = 0.f; cy = 0.f; }
        float cap = std::max(0.04f, wallDistance(local.shape.R, cx, cy) - width - 0.05f);
        float rad = 0.04f + std::clamp(prm.osize.load(), 0.f, 1.f) * (cap - 0.04f);
        orbitX.store(cx, std::memory_order_relaxed); orbitY.store(cy, std::memory_order_relaxed); orbitR.store(rad, std::memory_order_relaxed);
        // one-pole glide (~15 ms) toward the targets, ramped linearly across this block
        if (!orbInit) { sm[0] = cx; sm[1] = cy; sm[2] = rad; sm[3] = width; orbInit = true; }
        const float tg[4] = {cx, cy, rad, width};
        const float ga = 1.f - std::exp(-(float)n / (0.015f * (float)sr));
        float o0[4], o1[4];
        for (int k = 0; k < 4; k++) { o0[k] = sm[k]; sm[k] += (tg[k] - sm[k]) * ga; o1[k] = sm[k]; }
        const float invN = 1.f / (float)n;
        std::fill(outL, outL + n, 0.f);
        std::fill(outR, outR + n, 0.f);
        const float* mask = maskCur.data();
        const float* damp = local.shape.damp.data();
        const float viscC = local.shape.viscCoef;
        int nActive = 0; int newest = -1; uint64_t newestT = 0;

        for (int vi = 0; vi < MAX_VOICES; vi++) {
            Voice& v = voices[vi];
            if (!v.active) continue;
            nActive++;
            if (v.startedAt >= newestT) { newestT = v.startedAt; newest = vi; }
            const float f0 = 440.f * std::pow(2.f, (v.note - 69) / 12.f);
            const float key = keytrack ? f0 / 130.8128f : 1.f;
            const float rate = std::min(MAX_POND_RATE, speedK * key);       // CPU grows with this, so it's capped
            const double stepsPerSample = frozen ? 0.0 : STEPS_PER_POND_SEC * rate / sr;
            const float velG = (1.f - velAmt) + velAmt * v.vel;
            for (int s = 0; s < n; s++) {
                // envelope
                if (v.stealing) {
                    v.env *= stealK;
                    if (v.env < 1e-3f) { startVoice(v, v.pendNote, v.pendVel); break; }   // new note starts next block
                } else if (v.gate) { v.env = std::min(1.f, v.env + atkInc); }
                else { v.env *= relK; if (v.env < 1e-4f) { v.active = false; v.env = 0.f; break; } }
                // advance the water
                v.stepAcc += stepsPerSample;
                while (v.stepAcc >= 1.0) {
                    v.stepAcc -= 1.0;
                    v.w.step(mask, damp, local.shape.sponge.data(), viscC, &advTable);
                    v.pondTime += 1.0 / STEPS_PER_POND_SEC;
                    for (int i = 0; i < local.nStones; i++)
                        if (!v.landed[i] && v.pondTime >= local.land[i]) { v.landed[i] = true; v.w.startDrop(local.stones[i]); }
                }
                const float blend = (float)v.stepAcc;
                // read both ears, 4x oversampled
                if ((s & 15) == 0) {
                    for (int ear = 0; ear < 2; ear++) {
                        float cents = (ear == 0 ? -0.5f : 0.5f) * detune + drift * 6.f * v.wobP[ear].tick(0.4f, (float)sr / 16.f);
                        v.dph[ear] = f0 * std::pow(2.f, cents / 1200.f) / (sr * OS);
                        v.rrf[ear] = 1.f + drift * 0.04f * v.wobR[ear].tick(0.25f, (float)sr / 16.f);
                    }
                }
                float y[2];
                const float* Pf = v.w.p.data(); const float* Uf = v.w.u.data();
                const float tt = (s + 1) * invN;
                const float scx = o0[0] + (o1[0] - o0[0]) * tt, scy = o0[1] + (o1[1] - o0[1]) * tt;
                const float srad = o0[2] + (o1[2] - o0[2]) * tt, swid = o0[3] + (o1[3] - o0[3]) * tt;
                const float rGs = srad * 0.5f * G;
                // the water only moves every ADVECT_EVERY steps; read where it WOULD be
                const float pk = advTable.active() ? (float)v.w.advectCount + blend : 0.f;
                const float gc = (G - 1) * 0.5f;
                const bool swirl = advTable.mode == 0;
                float prc = 1.f, prs = 0.f, pdx = 0.f, pdy = 0.f;
                if (pk != 0.f) {
                    if (swirl) { prc = std::cos(pk * advTable.omega); prs = std::sin(pk * advTable.omega); }
                    else { pdx = -pk * advTable.vx; pdy = -pk * advTable.vy; }
                }
                const float cG[2][2] = {{worldToGrid(scx - swid), worldToGrid(scy)}, {worldToGrid(scx + swid), worldToGrid(scy)}};
                for (int ear = 0; ear < 2; ear++) {
                    float* buf = v.firBuf[ear];
                    int wpos = v.firPos;
                    const float rr = rGs * v.rrf[ear];
                    // water height on this ear's orbit at phase ph (0..1)
                    auto sample = [&](float ph) {
                        float sn, cs; sincos01(ph, sn, cs);
                        float gx = cG[ear][0] + rr * cs, gy = cG[ear][1] + rr * sn;
                        if (pk != 0.f) {
                            if (swirl) { float px = gx - gc, py = gy - gc; gx = gc + prc * px + prs * py; gy = gc - prs * px + prc * py; }
                            else { gx += pdx; gy += pdy; }
                        }
                        return bilinear(Pf, gx, gy) * (1.f - blend) + bilinear(Uf, gx, gy) * blend;
                    };
                    auto capture = [&](float* t) { for (int i = 0; i < Voice::TAB; i++) t[i] = sample((float)i / Voice::TAB); t[Voice::TAB] = t[0]; };
                    if (clarity > 0.f && !v.tabInit) {
                        capture(v.tabNew[ear]); std::memcpy(v.tabOld[ear], v.tabNew[ear], sizeof(v.tabOld[ear]));
                        v.lapCount[ear] = 0; v.holdLaps[ear] = 1;
                        if (ear == 1) v.tabInit = true;
                    }
                    for (int k = 0; k < OS; k++) {
                        v.phase[ear] += v.dph[ear];
                        if (v.phase[ear] >= 1.0) {
                            v.phase[ear] -= 1.0;
                            if (clarity > 0.f && ++v.lapCount[ear] >= v.holdLaps[ear]) {
                                // next snapshot: the waveform glides old -> new over holdLaps cycles.
                                // Clarity sets how often it refreshes: ~60/s (low) down to ~10/s (full)
                                std::memcpy(v.tabOld[ear], v.tabNew[ear], sizeof(v.tabOld[ear]));
                                capture(v.tabNew[ear]);
                                const float rate = 60.f * std::pow(10.f / 60.f, clarity);
                                v.lapCount[ear] = 0;
                                v.holdLaps[ear] = std::max(1, (int)std::lround(f0 / rate));
                            }
                        }
                        const float ph = (float)v.phase[ear];
                        float h = clarity < 1.f ? sample(ph) : 0.f;
                        if (clarity > 0.f) {
                            // glide from last lap's snapshot to this lap's across the cycle: pitch stays clean
                            float x = ph * Voice::TAB; int i = (int)x; float f = x - i;
                            float a = v.tabOld[ear][i] + (v.tabOld[ear][i + 1] - v.tabOld[ear][i]) * f;
                            float b = v.tabNew[ear][i] + (v.tabNew[ear][i + 1] - v.tabNew[ear][i]) * f;
                            const float wgt = ((float)v.lapCount[ear] + ph) / (float)v.holdLaps[ear];
                            h = h * (1.f - clarity) + (a + (b - a) * wgt) * clarity;
                        }
                        buf[wpos] = h; buf[wpos + FIR_TAPS] = h;
                        if (++wpos == FIR_TAPS) wpos = 0;
                    }
                    // decimate: FIR over the last FIR_TAPS oversampled values (contiguous, oldest first)
                    const float* win = buf + wpos;
                    float a0 = 0.f, a1 = 0.f, a2 = 0.f, a3 = 0.f;
                    for (int t = 0; t < FIR_TAPS; t += 4) {
                        a0 += fir[t] * win[t]; a1 += fir[t + 1] * win[t + 1];
                        a2 += fir[t + 2] * win[t + 2]; a3 += fir[t + 3] * win[t + 3];
                    }
                    const float xin = (a0 + a1) + (a2 + a3);
                    const float yo = v.hp[1][ear].run(v.hp[0][ear].run(xin));
                    y[ear] = yo;
                }
                v.firPos = (v.firPos + OS) % FIR_TAPS;
                float g = v.env * velG * volG * OUT_GAIN;
                outL[s] += y[0] * g;
                outR[s] += y[1] * g;
            }
        }
        // steep 35 Hz high-pass (4th order) + soft clip
        if (sr != outHpSr) {
            for (int c = 0; c < 2; c++) { outHp[0][c].highpass(35.0, BW4_Q1, sr); outHp[1][c].highpass(35.0, BW4_Q2, sr); }
            outHpSr = sr;
        }
        for (int s = 0; s < n; s++) {
            outL[s] = std::tanh(outHp[1][0].run(outHp[0][0].run(outL[s])));
            outR[s] = std::tanh(outHp[1][1].run(outHp[0][1].run(outR[s])));
        }
        clock += (uint64_t)n;
        updateDisplay(newest, nActive, n, sr);
    }

    // Output gain applied before the soft clip (calibrated with the test renderer).
    static constexpr float OUT_GAIN = 0.35f;

private:
    struct Shared {
        Shape shape; Water snap; double snapTime = 0;
        Stone stones[MAX_STONES]; float land[MAX_STONES] = {}; int nStones = 0; uint64_t version = 0;
    };
    Shared shared, local;      // local = audio thread's copy
    uint64_t localVersion = ~0ull;
    std::mutex shareLock;
    std::vector<float> maskCur = std::vector<float>(NCELLS, 0.f);
    bool maskInit = false;

    Stone stonesMain[MAX_STONES];
    int nStonesMain = 3;
    std::mutex stoneLock;
    EventQueue<256> queue;
    Voice voices[MAX_VOICES];
    float fir[FIR_TAPS] = {};
    Biquad outHp[2][2]; double outHpSr = 0;
    Wobble wanX, wanY; float wx = 0, wy = 0;
    float sm[4] = {0, 0, 0.3f, 0.04f}; bool orbInit = false;
    AdvectTable advTable;
    uint64_t clock = 0;
    double curSr = 44100.0;
    bool wasFrozen = false, frozenNow = false, haveFrozen = false;
    Water frozenWater; double frozenTime = 0, frozenBlend = 0; bool frozenLanded[MAX_STONES] = {};

    std::mutex dispLock;
    float disp[DISP * DISP] = {};
    bool dispFresh = false; int dispActive = 0; int dispCounter = 0;

    static void denormalsOff() {
#if defined(__SSE__) || defined(_M_X64)
        _mm_setcsr(_mm_getcsr() | 0x8040);           // flush-to-zero + denormals-are-zero
#elif defined(__aarch64__)
        uint64_t fpcr; __asm__ __volatile__("mrs %0, fpcr" : "=r"(fpcr));
        __asm__ __volatile__("msr fpcr, %0" :: "r"(fpcr | (1ull << 24)));
#endif
    }

    struct CurrentSpec { int mode; float omega, vx, vy; };
    CurrentSpec currentSpec() const {
        const float c = std::clamp(prm.current.load(), -1.f, 1.f);
        if (prm.cmode.load() == 1) {
            const float d = prm.cdir.load(), sp = c * FLOW_MAX;   // cells per step
            return {1, 0.f, sp * std::cos(d), sp * std::sin(d)};
        }
        return {0, omegaFor(c), 0.f, 0.f};
    }

    static float omegaFor(float current) {
        float turns = std::clamp(current, -1.f, 1.f) * 4.f;    // up to 4 turns per pond-second
        return (float)(2 * kPi * turns / STEPS_PER_POND_SEC);
    }

    void designFir() {
        // windowed-sinc low-pass at 0.45 * output Nyquist... cutoff 0.45/OS of the oversampled rate
        double fc = 0.45 / OS, sum = 0;
        for (int t = 0; t < FIR_TAPS; t++) {
            double m = t - (FIR_TAPS - 1) / 2.0;
            double sinc = m == 0 ? 2 * fc : std::sin(2 * kPi * fc * m) / (kPi * m);
            double w = 0.42 - 0.5 * std::cos(2 * kPi * t / (FIR_TAPS - 1)) + 0.08 * std::cos(4 * kPi * t / (FIR_TAPS - 1));
            fir[t] = (float)(sinc * w); sum += fir[t];
        }
        for (int t = 0; t < FIR_TAPS; t++) fir[t] = (float)(fir[t] / sum);
    }

    void pullShared() {
        std::unique_lock<std::mutex> lk(shareLock, std::try_to_lock);
        if (!lk.owns_lock() || shared.version == localVersion) return;
        local.shape = shared.shape;     // copies (~100 KB), only after a change
        local.snap.copyFrom(shared.snap);
        local.snapTime = shared.snapTime;
        for (int i = 0; i < MAX_STONES; i++) { local.stones[i] = shared.stones[i]; local.land[i] = shared.land[i]; }
        local.nStones = shared.nStones;
        localVersion = shared.version;
        if (!maskInit) { maskCur = local.shape.mask; maskInit = true; }
    }

    void smoothMask(int n, double sr) {
        // glide the active mask toward the target (~30 ms) so shape changes don't click
        float a = 1.f - std::exp(-(float)n / (0.03f * (float)sr));
        const float* t = local.shape.mask.data();
        float* m = maskCur.data();
        for (int i = 0; i < NCELLS; i++) m[i] += (t[i] - m[i]) * a;
    }

    void handle(const Event& e, double sr) {
        if (e.type == EvType::AllOff) { for (auto& v : voices) v.gate = false; return; }
        if (e.type == EvType::NoteOff) {
            for (auto& v : voices) {
                if (v.active && v.gate && v.note == e.note) v.gate = false;
                if (v.active && v.stealing && v.pendNote == e.note) v.pendOff = true;
            }
            return;
        }
        // note on: free voice, else the oldest (which fades out first: an instant cut clicks)
        int pick = -1; uint64_t oldest = ~0ull;
        for (int i = 0; i < MAX_VOICES; i++) if (!voices[i].active) { pick = i; break; }
        if (pick < 0) for (int i = 0; i < MAX_VOICES; i++) if (voices[i].startedAt < oldest) { oldest = voices[i].startedAt; pick = i; }
        Voice& v = voices[pick];
        if (v.active && v.env > 1e-3f) {
            v.stealing = true; v.pendNote = e.note; v.pendVel = e.vel; v.gate = false;
            v.startedAt = clock + 1;   // counts as newest so it isn't picked again right away
            return;
        }
        startVoice(v, e.note, e.vel);
        (void)sr;
    }

    // Freeze: grab the water of the most recent note (playing or not) so new notes
    // play that exact moment instead of the (possibly still flat) start point.
    void captureFrozen() {
        int pick = -1; uint64_t newest = 0;
        for (int i = 0; i < MAX_VOICES; i++)
            if (voices[i].startedAt > newest && !voices[i].stealing) { newest = voices[i].startedAt; pick = i; }
        if (pick < 0) { haveFrozen = false; return; }
        frozenWater.copyFrom(voices[pick].w);
        frozenTime = voices[pick].pondTime;
        frozenBlend = voices[pick].stepAcc;
        for (int i = 0; i < MAX_STONES; i++) frozenLanded[i] = voices[pick].landed[i];
        haveFrozen = true;
    }

    void startVoice(Voice& v, uint8_t note, uint8_t vel) {
        if (frozenNow && haveFrozen) {
            v.w.copyFrom(frozenWater);
            v.pondTime = frozenTime;
            v.stepAcc = frozenBlend;
            for (int i = 0; i < MAX_STONES; i++) v.landed[i] = frozenLanded[i];
        } else {
            v.w.copyFrom(local.snap);
            v.pondTime = local.snapTime;
            v.stepAcc = 0.0;
            for (int i = 0; i < MAX_STONES; i++) v.landed[i] = (i < local.nStones) && (local.land[i] <= local.snapTime);
        }
        v.active = true; v.gate = !v.pendOff; v.pendOff = false; v.stealing = false; v.note = note; v.vel = vel / 127.f;
        v.env = 0.f; v.phase[0] = v.phase[1] = 0.0; v.startedAt = clock + 1;
        std::memset(v.firBuf, 0, sizeof(v.firBuf)); v.firPos = 0;
        // 4th-order Butterworth high-pass at 0.7 x the fundamental: cuts slosh/thump/rumble cleanly
        {
            double f0 = 440.0 * std::pow(2.0, (note - 69) / 12.0), fc = std::max(20.0, 0.7 * f0);
            for (int e = 0; e < 2; e++) { v.hp[0][e].highpass(fc, BW4_Q1, curSr); v.hp[1][e].highpass(fc, BW4_Q2, curSr); }
        }
        v.tabInit = false;
    }

    void updateDisplay(int newest, int nActive, int n, double sr) {
        dispCounter += n;
        if (dispCounter < (int)(sr / 25.0)) return;   // ~25 fps
        dispCounter = 0;
        std::unique_lock<std::mutex> lk(dispLock, std::try_to_lock);
        if (!lk.owns_lock()) return;
        const float* src = newest >= 0 ? voices[newest].w.u.data() : local.snap.u.data();
        for (int dy = 0; dy < DISP; dy++)
            for (int dx = 0; dx < DISP; dx++) {
                float s = 0;
                for (int j = 0; j < 3; j++) for (int i = 0; i < 3; i++) s += src[(dy * 3 + j) * G + dx * 3 + i];
                disp[dy * DISP + dx] = s / 9.f;
            }
        dispActive = nActive;
        dispFresh = true;
    }
};

}  // namespace pond
