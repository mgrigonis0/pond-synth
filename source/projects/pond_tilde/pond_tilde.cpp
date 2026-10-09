// pond~ — Max/MSP wrapper around the pond engine.
//
// Inlet (left): messages
//   note <pitch> <velocity>     (velocity 0 = note off), or a 2-item list
//   allnotesoff
//   <param> <value>             see kParams below, e.g. "visc 0.4", "s2x -0.3"
//   randomize                   fresh stones (outputs the new stone params)
// Outlets: 0 = left audio, 1 = right audio,
//          2 = info: "frame <36*36 heights -1..1>", "orbit <x> <y> <r>", "voices <n>",
//                    "<stone param> <value>" after randomize
#include "ext.h"
#include "ext_obex.h"
#include "z_dsp.h"

#include "../../engine/pond_engine.h"

#include <chrono>
#include <condition_variable>
#include <cstdio>
#include <cstring>
#include <random>
#include <string>
#include <thread>
#include <vector>

using pond::Engine;

struct Rebuilder {
    std::thread th;
    std::mutex m;
    std::condition_variable cv;
    bool dirty = false, quit = false;
};

typedef struct _pond {
    t_pxobject ob;
    Engine* eng;
    Rebuilder* rb;
    void* infoOut;
    void* displayClock;
    std::vector<float>* bufL;
    std::vector<float>* bufR;
    std::vector<float>* disp;
    std::vector<t_atom>* dispAtoms;
    float dispPeak;
    long displayOn;
} t_pond;

static t_class* s_pond_class = nullptr;

// ---------------------------------------------------------------------------
static void rebuild_worker(t_pond* x) {
    Rebuilder* rb = x->rb;
    for (;;) {
        std::unique_lock<std::mutex> lk(rb->m);
        rb->cv.wait(lk, [rb] { return rb->dirty || rb->quit; });
        if (rb->quit) return;
        lk.unlock();
        // debounce: let a drag gesture settle a little before the heavy rebuild
        std::this_thread::sleep_for(std::chrono::milliseconds(25));
        lk.lock();
        rb->dirty = false;
        lk.unlock();
        x->eng->rebuild();
    }
}

static void request_rebuild(t_pond* x) {
    {
        std::lock_guard<std::mutex> lk(x->rb->m);
        x->rb->dirty = true;
    }
    x->rb->cv.notify_one();
}

// ---------------------------------------------------------------------------
static bool set_stone_field(t_pond* x, const char* name, float v) {
    // s<1..4><x|y|h|s|m>
    if (std::strlen(name) != 3 || name[0] != 's' || name[1] < '1' || name[1] > '4') return false;
    int i = name[1] - '1';
    pond::Stone st = x->eng->getStone(i);
    switch (name[2]) {
        case 'x': st.x = std::clamp(v, -1.f, 1.f); break;
        case 'y': st.y = std::clamp(v, -1.f, 1.f); break;
        case 'h': st.h = std::clamp(v, 0.f, 1.f); break;
        case 's': st.size = std::clamp(v, 0.f, 1.f); break;
        case 'm': st.mass = std::clamp(v, 0.f, 1.f); break;
        default: return false;
    }
    x->eng->setStone(i, st);
    return true;
}

static void pond_param(t_pond* x, t_symbol* s, long argc, t_atom* argv) {
    if (argc < 1) return;
    const char* n = s->s_name;
    float v = (float)atom_getfloat(argv);
    pond::Params& p = x->eng->prm;
    bool rebuild = true;   // pond-shaping params need a new shape/start snapshot
    if (!std::strcmp(n, "corners")) p.corners = v;
    else if (!std::strcmp(n, "walls")) p.walls = v;
    else if (!std::strcmp(n, "visc")) p.visc = v;
    else if (!std::strcmp(n, "refl")) p.refl = v;
    else if (!std::strcmp(n, "current")) p.current = v;
    else if (!std::strcmp(n, "cmode")) p.cmode = v != 0.f;
    else if (!std::strcmp(n, "cdir")) p.cdir = v;
    else if (!std::strcmp(n, "start")) p.start = v;
    else if (!std::strcmp(n, "nstones")) x->eng->setStoneCount((int)std::lround(v));
    else if (set_stone_field(x, n, v)) {}
    else {
        rebuild = false;
        if (!std::strcmp(n, "speed")) p.speed = v;
        else if (!std::strcmp(n, "keytrack")) p.keytrack = v != 0.f;
        else if (!std::strcmp(n, "freeze")) p.freeze = v != 0.f;
        else if (!std::strcmp(n, "ox")) p.ox = v;
        else if (!std::strcmp(n, "oy")) p.oy = v;
        else if (!std::strcmp(n, "osize")) p.osize = v;
        else if (!std::strcmp(n, "wander")) p.wander = v;
        else if (!std::strcmp(n, "width")) p.width = v;
        else if (!std::strcmp(n, "detune")) p.detune = v;
        else if (!std::strcmp(n, "drift")) p.drift = v;
        else if (!std::strcmp(n, "attack")) p.attack = v;
        else if (!std::strcmp(n, "release")) p.release = v;
        else if (!std::strcmp(n, "velamt")) p.velamt = v;
        else if (!std::strcmp(n, "volume")) p.volume = v;
        else if (!std::strcmp(n, "clarity")) p.clarity = v;
        else if (!std::strcmp(n, "display")) x->displayOn = v != 0.f;
        else { object_error((t_object*)x, "unknown message %s", n); return; }
    }
    if (rebuild) request_rebuild(x);
}

static void pond_note(t_pond* x, t_symbol*, long argc, t_atom* argv) {
    if (argc < 2) return;
    int pitch = (int)atom_getlong(argv), vel = (int)atom_getlong(argv + 1);
    if (vel > 0) x->eng->noteOn(pitch, vel); else x->eng->noteOff(pitch);
}
static void pond_list(t_pond* x, t_symbol* s, long argc, t_atom* argv) { pond_note(x, s, argc, argv); }
static void pond_allnotesoff(t_pond* x) { x->eng->allOff(); }

static void pond_randomize(t_pond* x) {
    static std::mt19937 rng{std::random_device{}()};
    std::uniform_real_distribution<float> U(0.f, 1.f);
    int n = x->eng->stoneCount();
    for (int i = 0; i < n; i++) {
        // pick a spot inside the pond: rejection-sample within radius 0.7
        float px, py;
        do { px = U(rng) * 1.4f - 0.7f; py = U(rng) * 1.4f - 0.7f; } while (px * px + py * py > 0.49f);
        pond::Stone st{px, py, U(rng), U(rng) * 0.8f + 0.1f, U(rng)};
        x->eng->setStone(i, st);
        const char f[5] = {'x', 'y', 'h', 's', 'm'};
        float vals[5] = {st.x, st.y, st.h, st.size, st.mass};
        for (int k = 0; k < 5; k++) {
            char name[4] = {'s', (char)('1' + i), f[k], 0};
            t_atom a; atom_setfloat(&a, vals[k]);
            outlet_anything(x->infoOut, gensym(name), 1, &a);   // so the patch/UI can store it
        }
    }
    request_rebuild(x);
}

// ---------------------------------------------------------------------------
static void pond_display_tick(t_pond* x) {
    if (x->displayOn) {
        int active = 0;
        std::vector<float>& d = *x->disp;
        if (x->eng->readDisplay(d.data(), active)) {
            float peak = 1e-6f;
            for (float v : d) peak = std::max(peak, std::fabs(v));
            // slow-falling peak so the picture doesn't pump
            x->dispPeak = std::max(peak, x->dispPeak * 0.92f);
            float k = 1.f / std::max(1e-6f, x->dispPeak);
            std::vector<t_atom>& at = *x->dispAtoms;
            for (size_t i = 0; i < d.size(); i++) atom_setfloat(&at[i], std::clamp(d[i] * k, -1.f, 1.f));
            outlet_anything(x->infoOut, gensym("frame"), (long)at.size(), at.data());
            t_atom o[3];
            atom_setfloat(o, x->eng->orbitX.load()); atom_setfloat(o + 1, x->eng->orbitY.load()); atom_setfloat(o + 2, x->eng->orbitR.load());
            outlet_anything(x->infoOut, gensym("orbit"), 3, o);
            t_atom nv; atom_setlong(&nv, active);
            outlet_anything(x->infoOut, gensym("voices"), 1, &nv);
        }
    }
    clock_fdelay(x->displayClock, 40.);
}

// ---------------------------------------------------------------------------
static void pond_perform64(t_pond* x, t_object*, double**, long, double** outs, long numouts, long n, long, void*) {
    if (numouts < 2) return;
    std::vector<float>& L = *x->bufL; std::vector<float>& R = *x->bufR;
    if ((long)L.size() < n) return;   // resized in dsp64
    x->eng->process(L.data(), R.data(), (int)n, sys_getsr());
    for (long i = 0; i < n; i++) { outs[0][i] = L[i]; outs[1][i] = R[i]; }
}

static void pond_dsp64(t_pond* x, t_object* dsp64, short*, double, long maxvectorsize, long) {
    x->bufL->assign((size_t)std::max<long>(maxvectorsize, 64), 0.f);
    x->bufR->assign((size_t)std::max<long>(maxvectorsize, 64), 0.f);
    object_method(dsp64, gensym("dsp_add64"), x, pond_perform64, 0, NULL);
}

static void pond_assist(t_pond*, void*, long m, long a, char* s) {
    if (m == ASSIST_INLET) std::snprintf(s, 256, "note <pitch> <vel>, parameter messages");
    else {
        const char* t[3] = {"(signal) Left", "(signal) Right", "Info: frame, orbit, voices, randomized stones"};
        std::snprintf(s, 256, "%s", t[std::clamp<long>(a, 0, 2)]);
    }
}

static void* pond_new(t_symbol*, long, t_atom*) {
    t_pond* x = (t_pond*)object_alloc(s_pond_class);
    if (!x) return nullptr;
    dsp_setup((t_pxobject*)x, 1);
    x->infoOut = outlet_new((t_object*)x, NULL);   // rightmost
    outlet_new((t_object*)x, "signal");            // right audio
    outlet_new((t_object*)x, "signal");            // left audio (leftmost)
    x->ob.z_misc |= Z_NO_INPLACE;

    x->eng = new Engine();
    x->bufL = new std::vector<float>(4096, 0.f);
    x->bufR = new std::vector<float>(4096, 0.f);
    x->disp = new std::vector<float>(pond::DISP * pond::DISP, 0.f);
    x->dispAtoms = new std::vector<t_atom>(pond::DISP * pond::DISP);
    x->dispPeak = 1e-3f;
    x->displayOn = 1;
    x->rb = new Rebuilder();
    x->rb->th = std::thread(rebuild_worker, x);
    x->displayClock = clock_new(x, (method)pond_display_tick);
    clock_fdelay(x->displayClock, 100.);
    return x;
}

static void pond_free(t_pond* x) {
    dsp_free((t_pxobject*)x);
    clock_unset(x->displayClock);
    object_free(x->displayClock);
    {
        std::lock_guard<std::mutex> lk(x->rb->m);
        x->rb->quit = true;
    }
    x->rb->cv.notify_one();
    if (x->rb->th.joinable()) x->rb->th.join();
    delete x->rb;
    delete x->eng;
    delete x->bufL; delete x->bufR; delete x->disp; delete x->dispAtoms;
}

static const char* kParams[] = {
    "corners", "walls", "visc", "refl", "current", "cmode", "cdir", "start", "nstones",
    "speed", "keytrack", "freeze", "ox", "oy", "osize", "wander", "width", "detune", "drift",
    "attack", "release", "velamt", "volume", "clarity", "display",
    "s1x", "s1y", "s1h", "s1s", "s1m", "s2x", "s2y", "s2h", "s2s", "s2m",
    "s3x", "s3y", "s3h", "s3s", "s3m", "s4x", "s4y", "s4h", "s4s", "s4m",
};

void ext_main(void*) {
    t_class* c = class_new("pond~", (method)pond_new, (method)pond_free, (long)sizeof(t_pond), 0L, A_GIMME, 0);
    class_addmethod(c, (method)pond_dsp64, "dsp64", A_CANT, 0);
    class_addmethod(c, (method)pond_assist, "assist", A_CANT, 0);
    class_addmethod(c, (method)pond_note, "note", A_GIMME, 0);
    class_addmethod(c, (method)pond_list, "list", A_GIMME, 0);
    class_addmethod(c, (method)pond_allnotesoff, "allnotesoff", 0);
    class_addmethod(c, (method)pond_randomize, "randomize", 0);
    for (const char* p : kParams) class_addmethod(c, (method)pond_param, p, A_GIMME, 0);
    class_dspinit(c);
    class_register(CLASS_BOX, c);
    s_pond_class = c;
}
